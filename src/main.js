/* ==========================================
   SmartBirth Main Router & State Management
   ========================================== */

import './style.css';
import { renderDashboard } from './components/dashboard.js';
import { renderAnatomy } from './components/anatomy.js';
import { renderMechanism } from './components/mechanism.js';
import { renderCalibration } from './components/calibration.js';
import { renderFingerQuiz } from './components/fingerQuiz.js';
import { renderQuiz } from './components/quiz.js';
import { renderBadge } from './components/badge.js';
import { playSynthSound, toggleSound, isSoundEnabled } from './utils/sfx.js';

// Default Application State
const DEFAULT_STATE = {
  unlockedStage: 1, // 1 to 6 (6 is VR Ready Badge view)
  completedStages: {
    stage1: false,
    stage2: false,
    stage3: false,
    stage4: false,
    stage5: false,
  },
  checklist: {
    scissors: false,
    clamp: false,
    bulb: false,
    gloves: false,
  },
  dilationHighScore: 0,
  quizHighScore: 0,
  studentName: '',
  xp: 0,
  coins: 0,
};

let appState = { ...DEFAULT_STATE };
let currentView = 'dashboard';

// Mascot Dialogue Database
const MASCOT_DIALOGUES = {
  dashboard: [
    "สวัสดีหมอฝึกหัด! 🚀 เลือกด่านกลไกการทำคลอดเพื่อเริ่มสะสมเหรียญทองกันเลยครับ!",
    "ยินดีต้อนรับสู่วิถีนักเรียนแพทย์! ทำภารกิจให้ครบเพื่อผ่านเกณฑ์การฝึกแบบ Pre-VR นะครับ ⭐",
    "ทุกด่านเปิดใช้งานตลอดเวลา คุณสามารถเลือกข้ามด่านไปเรียนส่วนที่สนใจก่อนได้เลยครับ!",
    "พยายามเข้าครับ! สะสมเหรียญและ XP เพื่อปลดล็อกใบประกาศเกียรติคุณในด่านสุดท้าย 🎓"
  ],
  stage1: [
    "ยินดีต้อนรับสู่ด่านที่ 1! 🧤 เรียนรู้เครื่องมือที่จำเป็นและติ๊กเลือกตรวจสอบความเรียบร้อยเพื่อรับเหรียญนะ!",
    "แตะพลิกการ์ด เพื่อศึกษาวิธีประยุกต์ใช้งานทางคลินิกอย่างถูกต้องเลยครับ"
  ],
  stage2: [
    "ด่านที่ 2 กลไกการคลอด 3 มิติ! 🤰 เลื่อนแถบสไลด์เดอร์และใช้นิ้วลากเพื่อสังเกตองศาศีรษะเด็กในโพรงเชิงกรานครับ",
    "หมุนอุ้งเชิงกราน 360 องศาเพื่อมองมุมอื่นๆ ที่มองไม่เห็นในชีวิตจริงได้นะครับ!"
  ],
  stage3: [
    "ด่านที่ 3 ปรับเทียบพิกัด AR! 📷 สแกนหาพื้นที่ราบ แตะเป้าเพื่อจำลองตำแหน่งการวางมือประคองทารกครับ",
    "ทฤษฎี Ritgen Maneuver สำคัญมากต่อการถนอมฝีเย็บไม่ให้ฉีกขาด ปรับเทียบและศึกษาได้เลย!"
  ],
  stage4: [
    "ด่านที่ 4 กางนิ้วจำลองสัมผัส! 🖐️ วางสองนิ้วลงบนหน้าจอแล้วกางออกให้ได้ขนาดปากมดลูกเปิดตามเป้าหมายครับ",
    "ฝึกให้จำระยะของกล้ามเนื้อได้แม่นยำนะครับ ยิ่งแม่นยำยิ่งได้รับเหรียญทองและ XP สูงสุด!"
  ],
  stage5: [
    "ด่านที่ 5 แบบทดสอบจัดลำดับ! 🧠 ลากจัดเรียงขั้นตอนการเคลื่อนต่ำของเด็กทั้ง 7 ขั้นตอนให้ถูกต้องตามเวลาเลยครับ"
  ],
  stage6: [
    "สุดยอดเลยครับหมอฝึกหัด! 🎉 ผ่านเกณฑ์การประเมิน Pre-VR สำเร็จแล้ว กรอกชื่อคุณและพิมพ์ใบประกาศนียบัตรได้เลย!"
  ]
};

// Load state from LocalStorage
function loadProgress() {
  const saved = localStorage.getItem('smartbirth_progress');
  if (saved) {
    try {
      appState = JSON.parse(saved);
      appState = { ...DEFAULT_STATE, ...appState };
    } catch (e) {
      console.error('Failed to parse saved progress, resetting to defaults.', e);
      appState = { ...DEFAULT_STATE };
    }
  } else {
    appState = { ...DEFAULT_STATE };
  }
}

// Save state to LocalStorage
export function saveProgress(updates = {}) {
  appState = { ...appState, ...updates };
  localStorage.setItem('smartbirth_progress', JSON.stringify(appState));
  updateHeaderProgress();
  updateHeaderWidgets();
}

// Reset State
function resetProgress() {
  if (confirm('คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตประวัติความก้าวหน้าทั้งหมด? (เหรียญทองและค่า XP จะกลับมาเริ่มต้นใหม่)')) {
    localStorage.removeItem('smartbirth_progress');
    appState = { ...DEFAULT_STATE };
    updateHeaderProgress();
    updateHeaderWidgets();
    playSynthSound('wrong');
    navigateTo('dashboard');
  }
}

// Update Global Progress Bar
function updateHeaderProgress() {
  const stages = ['stage1', 'stage2', 'stage3', 'stage4', 'stage5'];
  const completedCount = stages.filter(stage => appState.completedStages[stage]).length;
  const progressPercent = Math.round((completedCount / stages.length) * 100);
  
  const progressBar = document.getElementById('global-progress-bar');
  const progressText = document.getElementById('global-progress-text');
  
  if (progressBar) progressBar.style.width = `${progressPercent}%`;
  if (progressText) progressText.innerText = `${progressPercent}%`;
}

// Update XP & Coin Counters in Header
function updateHeaderWidgets() {
  const xpText = document.getElementById('header-xp');
  const coinsText = document.getElementById('header-coins');
  
  if (xpText) xpText.innerText = appState.xp || 0;
  if (coinsText) coinsText.innerText = appState.coins || 0;
}

// Floating Coin Particle Animation
export function spawnCoinAnimation(sourceElement) {
  const container = document.getElementById('floating-coins-container');
  const target = document.getElementById('coins-target-anchor');
  if (!container || !target || !sourceElement) return;

  const rectSource = sourceElement.getBoundingClientRect();
  const rectTarget = target.getBoundingClientRect();

  const count = 6;
  for (let i = 0; i < count; i++) {
    setTimeout(() => {
      const coin = document.createElement('div');
      coin.className = 'flying-coin';
      coin.innerText = '🪙';
      coin.style.left = `${rectSource.left + rectSource.width / 2}px`;
      coin.style.top = `${rectSource.top + rectSource.height / 2}px`;
      container.appendChild(coin);

      // Random burst offset
      const angle = Math.random() * Math.PI * 2;
      const distance = 25 + Math.random() * 45;
      const burstX = Math.cos(angle) * distance;
      const burstY = Math.sin(angle) * distance;

      // Force layout recalculation
      coin.offsetWidth;
      coin.style.transform = `translate(${burstX}px, ${burstY}px)`;

      // Fly to target
      setTimeout(() => {
        coin.style.transition = 'all 0.6s cubic-bezier(0.55, 0, 1, 0.45)';
        coin.style.left = `${rectTarget.left}px`;
        coin.style.top = `${rectTarget.top}px`;
        coin.style.transform = 'scale(0.5)';
        
        setTimeout(() => {
          coin.remove();
          playSynthSound('coin');
          // Pulse the coins widget
          target.classList.add('shake');
          setTimeout(() => target.classList.remove('shake'), 400);
        }, 600);
      }, 300);
    }, i * 60);
  }
}

// Floating Text Popup Animation (+XP / +Coins)
export function spawnFloatingText(text, sourceElement) {
  const container = document.getElementById('floating-coins-container');
  if (!container || !sourceElement) return;
  const rect = sourceElement.getBoundingClientRect();
  
  const textEl = document.createElement('div');
  textEl.className = 'floating-xp-text';
  textEl.innerText = text;
  textEl.style.left = `${rect.left + rect.width / 2 - 20}px`;
  textEl.style.top = `${rect.top - 20}px`;
  
  container.appendChild(textEl);
  setTimeout(() => textEl.remove(), 1200);
}

// Give XP & Coins rewards to the player
export function addRewards(xpToAdd, coinsToAdd, sourceElement = null) {
  let changed = false;
  if (xpToAdd > 0) {
    appState.xp = (appState.xp || 0) + xpToAdd;
    changed = true;
    if (sourceElement) {
      spawnFloatingText(`+${xpToAdd} XP`, sourceElement);
    }
  }
  if (coinsToAdd > 0) {
    appState.coins = (appState.coins || 0) + coinsToAdd;
    changed = true;
    if (sourceElement) {
      // Small delay so XP is shown first
      setTimeout(() => {
        spawnCoinAnimation(sourceElement);
      }, 100);
    } else {
      playSynthSound('coin');
    }
  }
  if (changed) {
    saveProgress();
  }
}

// Update Mascot speech and rendering
function renderMascot(viewKey) {
  const container = document.getElementById('mascot-container');
  if (!container) return;

  const dialogues = MASCOT_DIALOGUES[viewKey] || MASCOT_DIALOGUES.dashboard;
  const randomMsg = dialogues[Math.floor(Math.random() * dialogues.length)];

  container.innerHTML = `
    <div class="mascot-speech-bubble" id="mascot-bubble">${randomMsg}</div>
    <div class="mascot-avatar" id="mascot-stork-avatar" title="พี่นกกระสา Smarty (คลิกเพื่อขอคำแนะนำเพิ่มเติม!)">
      <svg viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="42" fill="#fff5f7" stroke="#4e3d30" stroke-width="4"/>
        <circle cx="30" cy="52" r="7" fill="#ffccd5" opacity="0.6"/>
        <circle cx="70" cy="52" r="7" fill="#ffccd5" opacity="0.6"/>
        <circle cx="37" cy="44" r="5" fill="#4e3d30"/>
        <circle cx="63" cy="44" r="5" fill="#4e3d30"/>
        <circle cx="35" cy="42" r="2" fill="#ffffff"/>
        <circle cx="61" cy="42" r="2" fill="#ffffff"/>
        <!-- Big orange stork beak -->
        <path d="M 44 48 Q 50 72 56 48 Z" fill="#ff9f43" stroke="#4e3d30" stroke-width="4" stroke-linejoin="round"/>
        <!-- Academic grad cap -->
        <polygon points="50,4 82,18 50,32 18,18" fill="#ff758f" stroke="#4e3d30" stroke-width="4"/>
        <rect x="46" y="18" width="8" height="12" fill="#4e3d30"/>
        <circle cx="82" cy="18" r="3" fill="#f7d070" stroke="#4e3d30" stroke-width="1.5"/>
      </svg>
    </div>
  `;

  // Stork click interactions
  const mascotAvatar = document.getElementById('mascot-stork-avatar');
  if (mascotAvatar) {
    mascotAvatar.addEventListener('click', () => {
      playSynthSound('click');
      // Cycle message
      const bubble = document.getElementById('mascot-bubble');
      if (bubble) {
        let nextMsg = randomMsg;
        while (nextMsg === bubble.innerText && dialogues.length > 1) {
          nextMsg = dialogues[Math.floor(Math.random() * dialogues.length)];
        }
        bubble.innerText = nextMsg;
        
        // Bounce animation
        mascotAvatar.style.transform = 'scale(1.2) rotate(10deg)';
        setTimeout(() => mascotAvatar.style.transform = '', 300);
      }
    });
  }
}

// Toggle Sound Controller
function updateSoundButton() {
  const btn = document.getElementById('btn-toggle-sound');
  if (!btn) return;
  
  const enabled = isSoundEnabled();
  btn.innerHTML = enabled ? '<i data-lucide="volume-2"></i>' : '<i data-lucide="volume-x"></i>';
  
  if (window.lucide) {
    window.lucide.createIcons();
  }
}

// Navigation Hash Router
export function navigateTo(targetView) {
  window.location.hash = `/${targetView}`;
}

// Local mounting coordinator
function mountView(targetView) {
  currentView = targetView;
  const container = document.getElementById('app-viewport');
  if (!container) return;
  
  // Clear previous component contents
  container.innerHTML = '';
  
  // Play routing sound
  playSynthSound('click');

  // Trigger mascot update
  renderMascot(targetView);

  // Mount the selected view component
  switch (targetView) {
    case 'dashboard':
      renderDashboard(container, appState, navigateTo);
      break;
    case 'stage1':
      renderAnatomy(container, appState, navigateTo, () => {
        playSynthSound('levelUp');
        const wasCompleted = appState.completedStages.stage1;
        appState.completedStages.stage1 = true;
        if (appState.unlockedStage === 1) appState.unlockedStage = 2;
        
        // Complete reward (Award XP and Coins only on first completion)
        saveProgress();
        if (!wasCompleted) {
          addRewards(100, 50, document.querySelector('.stage-header'));
        }
        
        // Small delay to let coin animation finish
        setTimeout(() => navigateTo('dashboard'), 1200);
      });
      break;
    case 'stage2':
      renderMechanism(container, appState, navigateTo, () => {
        playSynthSound('levelUp');
        const wasCompleted = appState.completedStages.stage2;
        appState.completedStages.stage2 = true;
        if (appState.unlockedStage === 2) appState.unlockedStage = 3;
        
        saveProgress();
        if (!wasCompleted) {
          addRewards(100, 50, document.querySelector('.stage-header'));
        }
        
        setTimeout(() => navigateTo('dashboard'), 1200);
      });
      break;
    case 'stage3':
      renderCalibration(container, appState, navigateTo, () => {
        playSynthSound('levelUp');
        const wasCompleted = appState.completedStages.stage3;
        appState.completedStages.stage3 = true;
        if (appState.unlockedStage === 3) appState.unlockedStage = 4;
        
        saveProgress();
        if (!wasCompleted) {
          addRewards(150, 60, document.querySelector('.stage-header'));
        }
        
        setTimeout(() => navigateTo('dashboard'), 1200);
      });
      break;
    case 'stage4':
      renderFingerQuiz(container, appState, navigateTo, (score) => {
        playSynthSound('levelUp');
        const wasCompleted = appState.completedStages.stage4;
        appState.completedStages.stage4 = true;
        if (appState.unlockedStage === 4) appState.unlockedStage = 5;
        if (score > appState.dilationHighScore) {
          appState.dilationHighScore = score;
        }
        
        saveProgress();
        if (!wasCompleted) {
          addRewards(200, 80, document.querySelector('.stage-header'));
        }
        
        setTimeout(() => navigateTo('dashboard'), 1200);
      });
      break;
    case 'stage5':
      renderQuiz(container, appState, navigateTo, (score) => {
        playSynthSound('levelUp');
        const wasCompleted = appState.completedStages.stage5;
        appState.completedStages.stage5 = true;
        if (appState.unlockedStage === 5) appState.unlockedStage = 6;
        if (score > appState.quizHighScore) {
          appState.quizHighScore = score;
        }
        
        saveProgress();
        if (!wasCompleted) {
          addRewards(200, 80, document.querySelector('.stage-header'));
        }
        
        setTimeout(() => navigateTo('dashboard'), 1200);
      });
      break;
    case 'stage6': // VR Ready Badge view
      renderBadge(container, appState, navigateTo);
      break;
    default:
      renderDashboard(container, appState, navigateTo);
  }
  
  // Refresh Lucide Icons for newly mounted DOM
  if (window.lucide) {
    window.lucide.createIcons();
  }
}

// Router Event Handler
function handleRouting() {
  const hash = window.location.hash || '#/dashboard';
  const view = hash.replace(/^#\/?/, '') || 'dashboard';
  mountView(view);
}

// Listen to Hash Changes
window.addEventListener('hashchange', handleRouting);

// Theme Manager
function initTheme() {
  const savedTheme = localStorage.getItem('smartbirth_theme') || 'warm';
  setTheme(savedTheme);
}

function setTheme(theme) {
  if (theme === 'blue') {
    document.body.classList.add('blue-theme');
    document.body.classList.remove('warm-theme');
  } else {
    document.body.classList.add('warm-theme');
    document.body.classList.remove('blue-theme');
  }
  localStorage.setItem('smartbirth_theme', theme);
}

function toggleTheme() {
  const isBlue = document.body.classList.contains('blue-theme');
  const nextTheme = isBlue ? 'warm' : 'blue';
  setTheme(nextTheme);
  playSynthSound('click');
}

// Initial App Mounting
document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  loadProgress();
  updateHeaderProgress();
  updateHeaderWidgets();
  updateSoundButton();

  // Handle Splash Screen Loader
  const splash = document.getElementById('splash-screen');
  const splashProgress = document.getElementById('splash-progress-bar');
  const splashText = document.getElementById('splash-loading-text');
  const startBtn = document.getElementById('btn-start-quest');
  const loadingBox = document.getElementById('splash-loading-box');

  if (splash && splashProgress && splashText && startBtn && loadingBox) {
    let currentPct = 0;
    const loadSteps = [
      "กำลังเชื่อมต่อระบบประสาทสัมผัส...",
      "กำลังจำลองโมเดลอุ้งเชิงกราน 3 มิติ...",
      "กำลังจำลองระดับพิกัดแล็บ AR...",
      "กำลังจัดเตรียมชุดเช็คลิสต์เครื่องมือ...",
      "ระบบจำลองพร้อมสำหรับการทดสอบแล้ว!"
    ];

    const interval = setInterval(() => {
      currentPct += 2;
      if (splashProgress) splashProgress.style.width = `${currentPct}%`;
      
      const stepIdx = Math.min(Math.floor(currentPct / 20), loadSteps.length - 1);
      if (splashText) splashText.innerText = `${loadSteps[stepIdx]} ${currentPct}%`;

      if (currentPct % 16 === 0) {
        playSynthSound('tick');
      }

      if (currentPct >= 100) {
        clearInterval(interval);
        loadingBox.classList.add('hidden');
        startBtn.classList.remove('hidden');
      }
    }, 25);

    startBtn.addEventListener('click', () => {
      // Play triumphant arpeggio
      playSynthSound('correct');
      
      // Award startup check points
      addRewards(30, 10, startBtn);

      splash.classList.add('fade-out');
      setTimeout(() => {
        splash.classList.add('hidden');
      }, 500);
    });
  }

  // Event listener for Reset button
  const btnReset = document.getElementById('btn-reset-progress');
  if (btnReset) btnReset.addEventListener('click', resetProgress);

  // Sound toggle button listener
  const btnToggleSound = document.getElementById('btn-toggle-sound');
  if (btnToggleSound) {
    btnToggleSound.addEventListener('click', () => {
      toggleSound();
      updateSoundButton();
    });
  }

  // Theme toggle button listener
  const btnToggleTheme = document.getElementById('btn-toggle-theme');
  if (btnToggleTheme) {
    btnToggleTheme.addEventListener('click', () => {
      toggleTheme();
    });
  }
  
  // Event listeners for Help modal
  const helpLink = document.getElementById('link-help');
  const helpModal = document.getElementById('help-modal');
  const btnCloseHelp = document.getElementById('btn-close-help');
  
  if (helpLink && helpModal) {
    helpLink.addEventListener('click', (e) => {
      e.preventDefault();
      playSynthSound('click');
      helpModal.classList.remove('hidden');
    });
  }
  
  if (btnCloseHelp && helpModal) {
    btnCloseHelp.addEventListener('click', () => {
      playSynthSound('click');
      helpModal.classList.add('hidden');
    });
  }
  
  if (helpModal) {
    helpModal.addEventListener('click', (e) => {
      if (e.target === helpModal) {
        helpModal.classList.add('hidden');
      }
    });
  }

  // Initialize Routing from Hash (or default to dashboard)
  if (!window.location.hash || window.location.hash === '#/') {
    window.location.hash = '/dashboard';
  } else {
    handleRouting();
  }
});

