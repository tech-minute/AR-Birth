/* ==========================================
   SmartBirth Utility: Web Audio API Sound Synthesizer
   ========================================== */

let audioCtx = null;
let soundEnabled = true;

// Load sound settings
function initSoundSetting() {
  const saved = localStorage.getItem('smartbirth_sfx');
  if (saved !== null) {
    soundEnabled = saved === 'true';
  } else {
    soundEnabled = true;
    localStorage.setItem('smartbirth_sfx', 'true');
  }
}

initSoundSetting();

export function toggleSound() {
  soundEnabled = !soundEnabled;
  localStorage.setItem('smartbirth_sfx', soundEnabled ? 'true' : 'false');
  playSynthSound('click'); // Play sound to confirm toggling on
  return soundEnabled;
}

export function isSoundEnabled() {
  return soundEnabled;
}

function getAudioContext() {
  if (!audioCtx) {
    // Standard and vendor prefixed audio context
    audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  }
  if (audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  return audioCtx;
}

// Generate sound effects dynamically using oscillators and filters (zero asset dependencies)
export function playSynthSound(type) {
  if (!soundEnabled) return;
  
  try {
    const ctx = getAudioContext();
    const now = ctx.currentTime;
    
    switch (type) {
      case 'click': {
        // Quick high-pitched cozy bleep
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        
        osc.type = 'sine';
        osc.frequency.setValueAtTime(587.33, now); // D5 note
        osc.frequency.exponentialRampToValueAtTime(880.00, now + 0.08); // A5 note
        
        gain.gain.setValueAtTime(0.08, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.08);
        
        osc.start(now);
        osc.stop(now + 0.08);
        break;
      }
      
      case 'tick': {
        // Snappy woodblock or pluck sound for checkboxes
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(783.99, now); // G5 note
        osc.frequency.exponentialRampToValueAtTime(1046.50, now + 0.04); // C6 note
        
        gain.gain.setValueAtTime(0.12, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.04);
        
        osc.start(now);
        osc.stop(now + 0.04);
        break;
      }
      
      case 'correct': {
        // Triumphant game-like arpeggio (C major 7th chord sweep)
        const notes = [523.25, 659.25, 783.99, 987.77, 1046.50]; // C5, E5, G5, B5, C6
        notes.forEach((freq, index) => {
          const startTime = now + index * 0.06;
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.connect(gain);
          gain.connect(ctx.destination);
          
          osc.type = 'sine';
          osc.frequency.setValueAtTime(freq, startTime);
          
          gain.gain.setValueAtTime(0.08, startTime);
          gain.gain.exponentialRampToValueAtTime(0.001, startTime + 0.2);
          
          osc.start(startTime);
          osc.stop(startTime + 0.2);
        });
        break;
      }
      
      case 'wrong': {
        // Low arcade-style double error buzz
        const startTimes = [now, now + 0.12];
        startTimes.forEach(startTime => {
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.connect(gain);
          gain.connect(ctx.destination);
          
          osc.type = 'sawtooth';
          osc.frequency.setValueAtTime(150, startTime);
          osc.frequency.linearRampToValueAtTime(110, startTime + 0.1);
          
          gain.gain.setValueAtTime(0.08, startTime);
          gain.gain.linearRampToValueAtTime(0.001, startTime + 0.1);
          
          osc.start(startTime);
          osc.stop(startTime + 0.1);
        });
        break;
      }
      
      case 'levelUp': {
        // Celebratory triumphant game leveling-up sweep
        const rootNotes = [523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77, 1046.50]; // C5 to C6 scale
        rootNotes.forEach((freq, index) => {
          const startTime = now + index * 0.05;
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.connect(gain);
          gain.connect(ctx.destination);
          
          osc.type = 'sine';
          osc.frequency.setValueAtTime(freq, startTime);
          
          // Slight vibrato
          const mod = ctx.createOscillator();
          const modGain = ctx.createGain();
          mod.frequency.value = 15;
          modGain.gain.value = 10;
          mod.connect(modGain);
          modGain.connect(osc.frequency);
          
          gain.gain.setValueAtTime(0.06, startTime);
          gain.gain.exponentialRampToValueAtTime(0.001, startTime + 0.3);
          
          mod.start(startTime);
          osc.start(startTime);
          mod.stop(startTime + 0.3);
          osc.stop(startTime + 0.3);
        });
        break;
      }
      
      case 'coin': {
        // Bright shining metal coin pickup sound
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        
        osc.type = 'sine';
        osc.frequency.setValueAtTime(987.77, now); // B5
        osc.frequency.setValueAtTime(1318.51, now + 0.08); // E6
        
        gain.gain.setValueAtTime(0.08, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
        
        osc.start(now);
        osc.stop(now + 0.25);
        break;
      }
    }
  } catch (e) {
    console.warn("Failed to play synthesized audio effect:", e);
  }
}
