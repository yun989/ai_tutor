/**
 * WebAudioPlayer - Gapless PCM audio streaming player using the Web Audio API.
 *
 * The key technique: use AudioBufferSourceNode.start(when) to schedule each
 * buffer to begin at the exact sample where the previous one ended.
 * This eliminates the gap that occurs with HTML5 Audio / audioplayers.
 */
class WebAudioPlayer {
  constructor(sampleRate) {
    this.inputSampleRate = sampleRate;
    // Use standard AudioContext with the browser's hardware sample rate for optimal performance
    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    this.audioContext = new AudioContextClass();
    this.nextPlayTime = 0;
    this.isPlaying = false;
    this.sources = [];

    // Resume immediately inside the synchronous user-gesture context
    if (this.audioContext.state === 'suspended') {
      this.audioContext.resume();
    }

    // Fallback: resume on any subsequent user interaction to satisfy autoplay policies
    const resumeHandler = () => {
      if (this.audioContext.state === 'suspended') {
        this.audioContext.resume();
      } else {
        document.removeEventListener('click', resumeHandler);
        document.removeEventListener('touchend', resumeHandler);
      }
    };
    document.addEventListener('click', resumeHandler);
    document.addEventListener('touchend', resumeHandler);
  }

  resume() {
    if (this.audioContext.state === 'suspended') {
      this.audioContext.resume();
    }
  }

  playPCMData(pcmBytes) {
    try {
      this.resume();

      // pcmBytes is a Uint8Array of 16-bit little-endian PCM samples
      const numSamples = Math.floor(pcmBytes.length / 2);
      if (numSamples === 0) return;

      // Always create the AudioBuffer with the input's actual sample rate.
      // The Web Audio API will automatically and cleanly resample it to the context's hardware rate.
      const buffer = this.audioContext.createBuffer(1, numSamples, this.inputSampleRate);
      const channelData = buffer.getChannelData(0);

      // Revert to highly robust DataView to avoid any alignment/RangeError issues in Wasm/mobile Chrome
      const dataView = new DataView(pcmBytes.buffer, pcmBytes.byteOffset, pcmBytes.byteLength);
      for (let i = 0; i < numSamples; i++) {
        const sample = dataView.getInt16(i * 2, true); // little-endian
        channelData[i] = sample / 32768.0;
      }

    const source = this.audioContext.createBufferSource();
    source.buffer = buffer;
    source.connect(this.audioContext.destination);

    const now = this.audioContext.currentTime;
    if (this.nextPlayTime < now) {
      // If we are starting playback, or the buffer ran dry due to network/CPU lag,
      // introduce a 100ms look-ahead buffer to absorb jitter and prevent stuttering.
      this.nextPlayTime = now + 0.1;
    }

    source.start(this.nextPlayTime);
    this.nextPlayTime += buffer.duration;
    this.isPlaying = true;

    // Track source for cleanup
    this.sources.push(source);
    source.onended = () => {
      const idx = this.sources.indexOf(source);
      if (idx !== -1) this.sources.splice(idx, 1);
      if (this.sources.length === 0) {
        this.isPlaying = false;
      }
    };
    } catch (e) {
      console.error("WebAudioPlayer playPCMData error:", e);
    }
  }

  stop() {
    // Stop all active sources
    for (const source of this.sources) {
      try { source.stop(); } catch (e) { /* ignore */ }
    }
    this.sources = [];
    this.nextPlayTime = 0;
    this.isPlaying = false;
  }

  dispose() {
    this.stop();
    this.audioContext.close();
  }
}

// --- Global API for Dart interop ---

window._webAudioPlayer = null;

window.initWebAudioPlayer = function (sampleRate) {
  if (window._webAudioPlayer) {
    window._webAudioPlayer.dispose();
  }
  window._webAudioPlayer = new WebAudioPlayer(sampleRate);
};

window.webAudioPlayChunk = function (pcmBytes) {
  if (window._webAudioPlayer) {
    window._webAudioPlayer.playPCMData(new Uint8Array(pcmBytes));
  }
};

window.webAudioStop = function () {
  if (window._webAudioPlayer) {
    window._webAudioPlayer.stop();
  }
};

window.webAudioDispose = function () {
  if (window._webAudioPlayer) {
    window._webAudioPlayer.dispose();
    window._webAudioPlayer = null;
  }
};
