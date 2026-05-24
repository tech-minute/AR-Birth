/* ==========================================
   SmartBirth Component: Stage 4 - Finger Dilation Quiz (Thai)
   ========================================== */

import { addRewards } from '../main.js';
import { playSynthSound } from '../utils/sfx.js';

const TARGETS = [3, 5, 8, 10]; // Dilation targets in cm

export function renderFingerQuiz(container, appState, navigateTo, onComplete) {
  let currentTargetIndex = 0;
  let targetCm = TARGETS[currentTargetIndex];
  let measuredCm = 0;
  let isTargetMatched = false;
  let matchStartTime = null;
  const matchDurationNeeded = 1200; // Hold for 1.2 seconds to confirm
  
  let canvas, ctx;
  let touchPoints = []; // [{x, y, id}]
  let isMouseDown = false;
  let mouseStart = null;
  let mouseCurrent = null;
  let animationFrameId = null;
  let particles = []; // Particle explosion array

  // Conversion: typical screen pixels per cm
  const PIXELS_PER_CM = 38;

  function renderHTML() {
    container.innerHTML = `
      <div class="stage-container">
        <div class="stage-header">
          <div class="stage-title">
            <i data-lucide="fingerprint" class="stage-title-icon"></i>
            <div>
              <h2>ด่านที่ 4: แบบทดสอบกางนิ้วสัมผัสปากมดลูกจำลอง 🖐️</h2>
              <p>วางนิ้วชี้และนิ้วกลางลงบนหน้าจอแล้วกางออก (บนคอมพิวเตอร์ให้คลิกเมาส์ค้างแล้วลากเส้น) เพื่อประเมินปากมดลูกเป้าหมาย</p>
            </div>
          </div>
          <div class="stage-actions">
            <button id="btn-back-dashboard" class="btn-icon-text secondary">
              <i data-lucide="arrow-left"></i>
              <span>กลับหน้าหลัก</span>
            </button>
            <button id="btn-complete-stage-4" class="btn-icon-text success" disabled>
              <i data-lucide="check-circle"></i>
              <span>ส่งงานสำเร็จด่าน 4</span>
            </button>
          </div>
        </div>

        <div class="finger-layout">
          <!-- Left: Touch Canvas -->
          <div class="finger-canvas-panel">
            <div id="pulse-overlay" class="pulse-overlay"></div>
            
            <div class="dilation-readout">
              <div class="label"><i data-lucide="gauge" style="width: 12px; height: 12px; display: inline-block; vertical-align: middle; margin-right: 4px; color: var(--accent-teal)"></i> ขนาดเปิดที่กางได้</div>
              <div class="value"><span id="measured-value">0.0</span><span class="unit"> ซม.</span></div>
            </div>

            <div class="target-readout">
              <div class="label"><i data-lucide="crosshair" style="width: 12px; height: 12px; display: inline-block; vertical-align: middle; margin-right: 4px; color: var(--primary)"></i> ขนาดเป้าหมาย</div>
              <div class="value" id="target-value">${targetCm} ซม.</div>
              <div id="hold-prompt" style="font-size:0.8rem; color:var(--warning); display:none; margin-top:0.25rem; font-weight:800; animation: float 1s infinite;">กางนิ้วค้างไว้ตรงนี้นิ่งๆ...</div>
            </div>

            <canvas id="dilation-canvas"></canvas>
          </div>

          <!-- Right: Instructions & Progress -->
          <div class="finger-sidebar">
            <div class="glass-panel" style="padding: 1.25rem;">
              <h4 style="margin-bottom: 0.5rem; display:flex; align-items:center; gap:0.35rem;">
                <i data-lucide="award" style="color:var(--primary);"></i> ความก้าวหน้าเป้าหมาย
              </h4>
              <p style="font-size:0.85rem; margin-bottom:0.75rem; color:var(--text-secondary); font-weight:700;">ฝึกกางนิ้วมือให้ตรงกับระยะเป้าหมายทั้ง 4 ขนาด:</p>
              
              <div style="display:flex; justify-content:space-between; gap:0.5rem;">
                ${TARGETS.map((t, idx) => `
                  <div id="target-badge-${idx}" style="flex:1; text-align:center; padding:0.5rem; border-radius:var(--radius-sm); border:2px solid var(--game-border-color); font-family:var(--font-mono); font-size:0.8rem; font-weight:900; background:rgba(255,255,255,0.01); color:var(--text-muted); box-shadow: 2px 2px 0px var(--game-border-color);">
                    ${t} ซม.
                  </div>
                `).join('')}
              </div>
            </div>

            <div class="dilation-reference-card glass-panel">
              <h4>🔍 เกณฑ์เปรียบเทียบระยะเปิดด้วยสายตา</h4>
              <p style="font-size: 0.75rem; color:var(--text-muted); margin-bottom: 0.75rem; font-weight: 700;">จำลองความรู้สึกและขนาดเปรียบเทียบเทียบ:</p>
              <div class="reference-sizes" style="display: flex; flex-direction: column; gap: 0.6rem;">
                <div class="ref-size-item" style="display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 0.8rem; font-weight:800; font-size:0.85rem;">
                  <span>⚫ 1 ซม. (เม็ดซีเรียลกลมเล็ก)</span>
                </div>
                <div class="ref-size-item" style="display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 0.8rem; font-weight:800; font-size:0.85rem;">
                  <span>🪙 3 ซม. (ขนาดเหรียญ 10 บาท)</span>
                </div>
                <div class="ref-size-item" style="display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 0.8rem; font-weight:800; font-size:0.85rem;">
                  <span>🍋 5 ซม. (มะนาวฝานซีก)</span>
                </div>
                <div class="ref-size-item" style="display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 0.8rem; font-weight:800; font-size:0.85rem;">
                  <span>🥫 8 ซม. (ขอบปากกระป๋องน้ำ)</span>
                </div>
                <div class="ref-size-item" style="display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 0.8rem; font-weight:800; font-size:0.85rem;">
                  <span>🥯 10 ซม. (ขนมปังเบเกิล / เปิดหมด)</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;

    if (window.lucide) {
      window.lucide.createIcons();
    }

    setupCanvas();
    updateBadges();
  }

  function updateBadges() {
    TARGETS.forEach((t, idx) => {
      const badge = document.getElementById(`target-badge-${idx}`);
      if (!badge) return;
      if (idx < currentTargetIndex) {
        badge.style.borderColor = 'var(--game-border-color)';
        badge.style.backgroundColor = 'var(--success)';
        badge.style.color = '#fff';
      } else if (idx === currentTargetIndex) {
        badge.style.borderColor = 'var(--game-border-color)';
        badge.style.backgroundColor = 'var(--primary)';
        badge.style.color = '#fff';
      } else {
        badge.style.borderColor = 'var(--game-border-color)';
        badge.style.backgroundColor = '#fff';
        badge.style.color = 'var(--text-muted)';
      }
    });
  }

  // Spawn visual particle stars upon matching a target
  function spawnParticles(x, y) {
    const colors = ['#ff758f', '#4ea8de', '#52b788', '#f7d070', '#fff'];
    for (let i = 0; i < 30; i++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 2 + Math.random() * 6;
      particles.push({
        x: x,
        y: y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        size: 5 + Math.random() * 5,
        color: colors[Math.floor(Math.random() * colors.length)],
        alpha: 1,
        decay: 0.015 + Math.random() * 0.02
      });
    }
  }

  function setupCanvas() {
    canvas = document.getElementById('dilation-canvas');
    if (!canvas) return;

    ctx = canvas.getContext('2d');

    const resizeCanvas = () => {
      if (!canvas) return;
      const rect = canvas.parentElement.getBoundingClientRect();
      canvas.width = rect.width;
      canvas.height = rect.height;
    };
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    // Multi-touch events
    canvas.addEventListener('touchstart', (e) => {
      e.preventDefault();
      touchPoints = Array.from(e.touches).map(t => ({
        x: t.clientX - canvas.getBoundingClientRect().left,
        y: t.clientY - canvas.getBoundingClientRect().top,
        id: t.identifier
      })).slice(0, 2);
    });

    canvas.addEventListener('touchmove', (e) => {
      e.preventDefault();
      touchPoints = Array.from(e.touches).map(t => ({
        x: t.clientX - canvas.getBoundingClientRect().left,
        y: t.clientY - canvas.getBoundingClientRect().top,
        id: t.identifier
      })).slice(0, 2);
    });

    canvas.addEventListener('touchend', (e) => {
      e.preventDefault();
      touchPoints = Array.from(e.touches).map(t => ({
        x: t.clientX - canvas.getBoundingClientRect().left,
        y: t.clientY - canvas.getBoundingClientRect().top,
        id: t.identifier
      })).slice(0, 2);
    });

    // Mouse drag fallback (desktop)
    canvas.addEventListener('mousedown', (e) => {
      const rect = canvas.getBoundingClientRect();
      isMouseDown = true;
      mouseStart = { x: e.clientX - rect.left, y: e.clientY - rect.top };
      mouseCurrent = { ...mouseStart };
      playSynthSound('click');
    });

    canvas.addEventListener('mousemove', (e) => {
      if (!isMouseDown) return;
      const rect = canvas.getBoundingClientRect();
      mouseCurrent = { x: e.clientX - rect.left, y: e.clientY - rect.top };
    });

    canvas.addEventListener('mouseup', () => {
      isMouseDown = false;
      mouseStart = null;
      mouseCurrent = null;
    });

    canvas.addEventListener('mouseleave', () => {
      isMouseDown = false;
      mouseStart = null;
      mouseCurrent = null;
    });

    // Draw frame tick loop
    const tick = () => {
      drawCanvas();
      checkDilationMatch();
      animationFrameId = requestAnimationFrame(tick);
    };
    tick();
  }

  function drawCanvas() {
    if (!ctx || !canvas) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;

    // Grid backdrop
    ctx.strokeStyle = 'rgba(186, 171, 153, 0.15)';
    ctx.lineWidth = 1;
    const gridSize = 30;
    for (let x = 0; x < canvas.width; x += gridSize) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, canvas.height);
      ctx.stroke();
    }
    for (let y = 0; y < canvas.height; y += gridSize) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(canvas.width, y);
      ctx.stroke();
    }

    // Determine current endpoints
    let p1 = null, p2 = null;
    if (touchPoints.length >= 2) {
      p1 = touchPoints[0];
      p2 = touchPoints[1];
    } else if (isMouseDown && mouseStart && mouseCurrent) {
      p1 = mouseStart;
      p2 = mouseCurrent;
    }

    if (p1 && p2) {
      const dx = p2.x - p1.x;
      const dy = p2.y - p1.y;
      const distPx = Math.sqrt(dx * dx + dy * dy);
      measuredCm = Math.min(12, distPx / PIXELS_PER_CM);
    } else {
      measuredCm = 0;
    }

    // Update readout
    const valText = document.getElementById('measured-value');
    if (valText) {
      valText.innerText = measuredCm.toFixed(1);
    }

    // Draw concentric ring
    const diameterPx = measuredCm * PIXELS_PER_CM;
    const radiusPx = diameterPx / 2;

    // Draw the cervix muscles
    ctx.beginPath();
    ctx.arc(centerX, centerY, radiusPx + 20, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(239, 149, 149, 0.35)'; // flesh tissue tone
    ctx.fill();
    ctx.strokeStyle = '#4e3d30';
    ctx.lineWidth = 4;
    ctx.stroke();

    // Draw cervix opening orifice
    ctx.beginPath();
    ctx.arc(centerX, centerY, Math.max(0, radiusPx), 0, Math.PI * 2);
    ctx.fillStyle = '#fffdf9'; // app cream bg color
    ctx.fill();
    ctx.stroke();

    // Reference coin lines if target is 3cm (coin 10b)
    if (targetCm === 3) {
      ctx.beginPath();
      ctx.arc(centerX, centerY, (3 * PIXELS_PER_CM) / 2, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(247, 208, 112, 0.12)';
      ctx.fill();
      ctx.strokeStyle = 'rgba(247, 208, 112, 0.5)';
      ctx.lineWidth = 2;
      ctx.setLineDash([5, 5]);
      ctx.stroke();
      ctx.setLineDash([]);
    }

    // Draw target boundary ring
    ctx.beginPath();
    ctx.arc(centerX, centerY, (targetCm * PIXELS_PER_CM) / 2, 0, Math.PI * 2);
    ctx.strokeStyle = isTargetMatched ? 'rgba(82, 183, 136, 0.4)' : 'rgba(255, 117, 143, 0.35)';
    ctx.lineWidth = 3;
    ctx.stroke();

    // Draw measurement nodes and ruler line
    if (p1 && p2) {
      ctx.beginPath();
      ctx.moveTo(p1.x, p1.y);
      ctx.lineTo(p2.x, p2.y);
      ctx.strokeStyle = isTargetMatched ? '#52b788' : '#ff758f';
      ctx.lineWidth = 4;
      ctx.stroke();

      // Finger buttons
      ctx.beginPath();
      ctx.arc(p1.x, p1.y, 18, 0, Math.PI * 2);
      ctx.fillStyle = '#ff758f';
      ctx.fill();
      ctx.strokeStyle = '#4e3d30';
      ctx.lineWidth = 3;
      ctx.stroke();

      ctx.beginPath();
      ctx.arc(p2.x, p2.y, 18, 0, Math.PI * 2);
      ctx.fillStyle = '#ff758f';
      ctx.fill();
      ctx.stroke();

      // Mid line label
      const midX = (p1.x + p2.x) / 2;
      const midY = (p1.y + p2.y) / 2;
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.roundRect(midX - 35, midY - 14, 70, 28, 6);
      ctx.fill();
      ctx.strokeStyle = '#4e3d30';
      ctx.lineWidth = 3;
      ctx.stroke();

      ctx.font = '900 12px var(--font-mono)';
      ctx.fillStyle = '#4e3d30';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(`${measuredCm.toFixed(1)} ซม.`, midX, midY);
    }

    // Draw and Update particles
    particles.forEach((p, idx) => {
      p.x += p.vx;
      p.y += p.vy;
      p.vx *= 0.96;
      p.vy *= 0.96;
      p.alpha -= p.decay;
      
      if (p.alpha <= 0) {
        particles.splice(idx, 1);
        return;
      }
      
      ctx.save();
      ctx.globalAlpha = p.alpha;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    });
  }

  function checkDilationMatch() {
    const errorMargin = 0.35; // Allow +/- 0.35 cm margin
    const isMatched = Math.abs(measuredCm - targetCm) <= errorMargin;

    const pulseOverlay = document.getElementById('pulse-overlay');
    const holdPrompt = document.getElementById('hold-prompt');

    if (isMatched) {
      if (!isTargetMatched) {
        isTargetMatched = true;
        matchStartTime = Date.now();
        if (pulseOverlay) pulseOverlay.classList.add('correct');
        if (holdPrompt) holdPrompt.style.display = 'block';
      } else {
        const holdTime = Date.now() - matchStartTime;
        if (holdTime >= matchDurationNeeded) {
          triggerTargetSuccess();
        }
      }
    } else {
      isTargetMatched = false;
      matchStartTime = null;
      if (pulseOverlay) {
        pulseOverlay.classList.remove('correct');
        pulseOverlay.classList.remove('incorrect');
      }
      if (holdPrompt) holdPrompt.style.display = 'none';
    }
  }

  function triggerTargetSuccess() {
    if (navigator.vibrate) {
      navigator.vibrate(150);
    }

    isTargetMatched = false;
    matchStartTime = null;

    const pulseOverlay = document.getElementById('pulse-overlay');
    if (pulseOverlay) {
      pulseOverlay.classList.remove('correct');
      pulseOverlay.classList.add('success-glow-effect');
      setTimeout(() => pulseOverlay.classList.remove('success-glow-effect'), 500);
      
      // Award rewards!
      addRewards(40, 15, pulseOverlay);
    }

    // Spawn cute star chimes particles on canvas center
    spawnParticles(canvas.width / 2, canvas.height / 2);

    playSynthSound('correct');

    currentTargetIndex++;
    updateBadges();

    if (currentTargetIndex < TARGETS.length) {
      targetCm = TARGETS[currentTargetIndex];
      const targetReadout = document.getElementById('target-value');
      if (targetReadout) targetReadout.innerText = `${targetCm} ซม.`;
    } else {
      finalizeQuiz();
    }
  }

  function finalizeQuiz() {
    playSynthSound('levelUp');
    const holdPrompt = document.getElementById('hold-prompt');
    if (holdPrompt) holdPrompt.style.display = 'none';

    const targetReadout = document.getElementById('target-value');
    if (targetReadout) {
      targetReadout.innerHTML = '<span style="color:var(--success)">🌟 ผ่านสำเร็จ 100%!</span>';
    }

    const btnComplete = document.getElementById('btn-complete-stage-4');
    if (btnComplete) {
      btnComplete.removeAttribute('disabled');
    }
  }

  renderHTML();

  document.getElementById('btn-back-dashboard').addEventListener('click', () => {
    playSynthSound('click');
    if (animationFrameId) cancelAnimationFrame(animationFrameId);
    navigateTo('dashboard');
  });

  const btnComplete = document.getElementById('btn-complete-stage-4');
  if (btnComplete) {
    btnComplete.addEventListener('click', () => {
      if (animationFrameId) cancelAnimationFrame(animationFrameId);
      onComplete(100); 
    });
  }
}
