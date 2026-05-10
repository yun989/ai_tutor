/**
 * WebAudioPlayer - Gapless PCM audio streaming player using the Web Audio API.
 *
 * The key technique: use AudioBufferSourceNode.start(when) to schedule each
 * buffer to begin at the exact sample where the previous one ended.
 * This eliminates the gap that occurs with HTML5 Audio / audioplayers.
 */
class WebAudioPlayer {
  constructor(sampleRate) {
    this.audioContext = new AudioContext({ sampleRate: sampleRate });
    this.nextPlayTime = 0;
    this.isPlaying = false;
    this.sources = [];
  }

  resume() {
    if (this.audioContext.state === 'suspended') {
      this.audioContext.resume();
    }
  }

  playPCMData(pcmBytes) {
    this.resume();

    // pcmBytes is a Uint8Array of 16-bit little-endian PCM samples
    const numSamples = Math.floor(pcmBytes.length / 2);
    if (numSamples === 0) return;

    const buffer = this.audioContext.createBuffer(1, numSamples, this.audioContext.sampleRate);
    const channelData = buffer.getChannelData(0);

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
      this.nextPlayTime = now;
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
