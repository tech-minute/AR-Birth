/* ==========================================
   SmartBirth Component: Stage 3 - AR Home-Lab Calibration (Thai)
   ========================================== */

import { addRewards } from '../main.js';
import { playSynthSound } from '../utils/sfx.js';

export function renderCalibration(container, appState, navigateTo, onComplete) {
  let isCalibrated = false;
  let isCalibrating = false;
  let cameraStream = null;
  let calibrationProgress = 0;
  let progressInterval = null;

  function renderHTML() {
    container.innerHTML = `
      <div class="stage-container">
        <div class="stage-header">
          <div class="stage-title">
            <i data-lucide="aperture" class="stage-title-icon"></i>
            <div>
              <h2>ด่านที่ 3: ปรับเทียบพื้นที่จำลองห้องแล็บ AR 📷</h2>
              <p>กรุณาสแกนพื้นที่ราบรอบตัวคุณ และทำการปรับเทียบตำแหน่งทางพิกัดเพื่อแสดงท่าประคองและวางมือทำคลอดเสมือนจริง</p>
            </div>
          </div>
          <div class="stage-actions">
            <button id="btn-back-dashboard" class="btn-icon-text secondary">
              <i data-lucide="arrow-left"></i>
              <span>กลับหน้าหลัก</span>
            </button>
            <button id="btn-complete-stage-3" class="btn-icon-text success" ${isCalibrated ? '' : 'disabled'}>
              <i data-lucide="check-circle"></i>
              <span>ส่งงานสำเร็จด่าน 3</span>
            </button>
          </div>
        </div>

        <div class="ar-layout">
          <!-- Left: Camera/AR Viewport -->
          <div class="ar-viewport-panel">
            <div id="ar-status-toast" class="ar-status-toast">
              <i data-lucide="scan"></i>
              <span id="toast-text">กำลังสแกนหาพื้นราบ...</span>
            </div>

            <!-- Video elements for webcam -->
            <video id="webcam-feed" autoplay playsinline style="display: none; width: 100%; height: 100%; object-fit: cover; position: absolute; z-index: 1;"></video>
            
            <!-- Fallback background when webcam denied or not yet active -->
            <div id="ar-camera-fallback" class="camera-feed-mock" style="background-image: linear-gradient(135deg, #ffeceb, #fffbf5); z-index: 1;">
              <div style="position: absolute; top:50%; left:50%; transform: translate(-50%, -50%); text-align: center; color: var(--text-muted);">
                <i data-lucide="video-off" style="width: 3rem; height: 3rem; margin-bottom: 0.5rem; opacity: 0.5; color: var(--primary);"></i>
                <p>ไม่ได้เปิดการใช้งานกล้องเว็บแคม หรืออุปกรณ์ไม่รองรับ</p>
                <button id="btn-request-cam" class="btn-icon-text secondary" style="margin-top: 1rem;">
                  <i data-lucide="video"></i> เปิดใช้งานกล้องถ่ายรูป
                </button>
              </div>
            </div>

            <!-- Scanning line visual -->
            <div id="scan-line" class="ar-scan-overlay"></div>

            <!-- Interactive Reticle -->
            <div id="ar-reticle" class="ar-reticle"></div>

            <!-- Calibration progress ring/text overlay -->
            <div id="calibration-progress-box" style="display: none; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; z-index: 5; background: rgba(255,255,255,0.95); padding: 1.5rem; border-radius: var(--radius-md); border: 2px solid var(--primary); box-shadow: var(--shadow-md);">
              <h4 style="color: var(--primary); margin-bottom: 0.5rem;">กำลังปรับเทียบพิกัดราบ...</h4>
              <div class="progress-bar-wrapper" style="width: 200px; height: 8px; margin: 0 auto 0.5rem;">
                <div id="calibration-progress-bar" class="progress-bar" style="width: 0%"></div>
              </div>
              <span id="calibration-progress-text" style="font-family: var(--font-mono); font-size: 0.85rem; color: var(--text-primary);">0%</span>
            </div>

            <!-- Ghost Hands & Neon Pelvis Placement Overlay -->
            <div id="ar-model-overlay" style="display: none; position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 3; pointer-events: none;">
              <svg width="100%" height="100%" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet" style="filter: drop-shadow(0 0 8px rgba(255,117,143,0.3));">
                <!-- Glowing Pelvis Inlet -->
                <ellipse cx="200" cy="200" rx="110" ry="80" fill="none" stroke="#4ea8de" stroke-width="4" stroke-dasharray="10 5" opacity="0.8">
                  <animate attributeName="stroke-dashoffset" values="0;100" dur="15s" repeatCount="indefinite" />
                </ellipse>
                <!-- Ischial spines -->
                <circle cx="105" cy="200" r="8" fill="#ff4d6d" opacity="0.9" />
                <circle cx="295" cy="200" r="8" fill="#ff4d6d" opacity="0.9" />
                <text x="105" y="185" fill="#56453d" font-size="10" font-family="sans-serif" text-anchor="middle" font-weight="bold">Ischial Spine (ระดับ 0)</text>
                <text x="295" y="185" fill="#56453d" font-size="10" font-family="sans-serif" text-anchor="middle" font-weight="bold">Ischial Spine (ระดับ 0)</text>

                <!-- Fetal Head overlay -->
                <ellipse cx="200" cy="200" rx="60" ry="75" fill="rgba(255,204,213,0.3)" stroke="#ff758f" stroke-width="3" opacity="0.9" />
                <!-- Sutures -->
                <line x1="200" y1="125" x2="200" y2="250" stroke="#ff4d6d" stroke-width="2" />
                
                <!-- Ghost hand guide vector lines -->
                <!-- Dominant Hand supporting perineum (bottom) -->
                <path d="M 160 380 Q 200 300 240 380" fill="none" stroke="#52b788" stroke-width="3" stroke-dasharray="4 4" opacity="0.8" />
                <text x="200" y="315" fill="#52b788" font-size="11" font-weight="bold" text-anchor="middle">มือที่ถนัดประคองฝีเย็บ (Ritgen Maneuver)</text>
                
                <!-- Non-dominant Hand controlling head extension (top) -->
                <path d="M 160 100 Q 200 150 240 100" fill="none" stroke="#ff758f" stroke-width="3" stroke-dasharray="4 4" opacity="0.8" />
                <text x="200" y="85" fill="#ff4d6d" font-size="11" font-weight="bold" text-anchor="middle">มืออีกข้างควบคุมการเงยของศีรษะทารก</text>
              </svg>
            </div>
          </div>

          <!-- Right: Instructions Panel -->
          <div class="ar-instructions-panel">
            <div class="hand-guide-box glass-panel">
              <h4>🎯 ขั้นตอนการปรับเทียบ</h4>
              <p style="margin-bottom: 0.75rem;">1. ถือสมาร์ทโฟนหรือกล้อง เล็งไปยังพื้นผิวที่เรียบและสว่าง (เช่น โต๊ะหรือเตียงฝึกหุ่นจำลอง)</p>
              <p style="margin-bottom: 0.75rem;">2. แตะปุ่มเป้าวงกลมตรงกลาง เพื่อจำลองล็อกพิกัดภูมิศาสตร์และวางโมเดลเชิงกราน</p>
              <p>3. เมื่อระบบเชื่อมต่อเรียบร้อยแล้ว ให้ศึกษาวิธีการทำคลอดและการประคองครรภ์ตามภาพไกด์ไลน์นำทาง</p>
            </div>

            <div class="hand-guide-box glass-panel">
              <h4>🖐️ แนวทางและกลยุทธ์การวางมือทำคลอด</h4>
              <p style="margin-bottom: 0.75rem; font-size: 0.85rem; line-height: 1.5; font-weight: 700;">
                <strong>การต้านและประคองท้ายทอยทารก (Occiput):</strong> ใช้มือข้างที่ไม่ถนัดกดต้านบริเวณท้ายทอยของทารกเบาๆ เพื่อควบคุมให้ศีรษะทารกเงยคลอดอย่างช้าๆ ป้องกันการเงยศีรษะกระทันหันซึ่งจะทำให้ฝีเย็บฉีกขาด
              </p>
              <p style="font-size: 0.85rem; line-height: 1.5; font-weight: 700;">
                <strong>การประคองฝีเย็บ (Perineal Support):</strong> ใช้มือข้างที่ถนัดถือผ้าสะอาดประคองดันบริเวณฝีเย็บ โดยใช้นิ้วชี้และนิ้วโป้งโอบฝีเย็บเข้าหากันเพื่อช่วยผ่อนคลายและลดความตึงขณะศีรษะทารกเคลื่อนผ่านพ้น
              </p>
            </div>
          </div>
        </div>
      </div>
    `;

    if (window.lucide) {
      window.lucide.createIcons();
    }

    setupListeners();
  }

  function startWebcam() {
    navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } })
      .then(stream => {
        cameraStream = stream;
        const video = document.getElementById('webcam-feed');
        const fallback = document.getElementById('ar-camera-fallback');
        
        if (video) {
          video.srcObject = stream;
          video.style.display = 'block';
        }
        if (fallback) {
          fallback.style.display = 'none';
        }

        const toastText = document.getElementById('toast-text');
        if (toastText) toastText.innerText = 'ตรวจพบพื้นผิวราบแล้ว กรุณาแตะเป้าหมายเพื่อเซ็ตพิกัด';
      })
      .catch(err => {
        console.warn('Webcam permission denied or unavailable.', err);
        const toastText = document.getElementById('toast-text');
        if (toastText) toastText.innerText = 'ไม่พบกล้องเว็บแคม ระบบจะใช้การสแกนแบบแอนิเมชันจำลอง';
      });
  }

  function triggerCalibration() {
    if (isCalibrated || isCalibrating) return;

    isCalibrating = true;
    const progressBox = document.getElementById('calibration-progress-box');
    const reticle = document.getElementById('ar-reticle');
    const toastText = document.getElementById('toast-text');
    
    if (progressBox) progressBox.style.display = 'block';
    if (reticle) reticle.style.display = 'none';
    if (toastText) toastText.innerText = 'กำลังสแกนระนาบและล็อกพิกัด...';

    playSynthSound('click');
    calibrationProgress = 0;
    progressInterval = setInterval(() => {
      calibrationProgress += 5;
      
      const progressBar = document.getElementById('calibration-progress-bar');
      const progressText = document.getElementById('calibration-progress-text');
      
      if (progressBar) progressBar.style.width = `${calibrationProgress}%`;
      if (progressText) progressText.innerText = `${calibrationProgress}%`;

      // Play radar scan beep sound
      if (calibrationProgress % 20 === 0) {
        playSynthSound('click');
      }

      if (calibrationProgress >= 100) {
        clearInterval(progressInterval);
        finalizeCalibration();
      }
    }, 80);
  }

  function finalizeCalibration() {
    isCalibrating = false;
    isCalibrated = true;

    playSynthSound('correct');

    const progressBox = document.getElementById('calibration-progress-box');
    const reticle = document.getElementById('ar-reticle');
    const modelOverlay = document.getElementById('ar-model-overlay');
    const scanLine = document.getElementById('scan-line');
    const toastText = document.getElementById('toast-text');
    const btnComplete = document.getElementById('btn-complete-stage-3');

    if (progressBox) progressBox.style.display = 'none';
    if (reticle) {
      reticle.style.display = 'flex';
      reticle.classList.add('calibrated');
    }
    if (modelOverlay) modelOverlay.style.display = 'block';
    if (scanLine) scanLine.style.display = 'none'; // Turn off active scan
    if (toastText) toastText.innerText = 'ปรับเทียบพิกัดสำเร็จ ด่านประคองการวางมือทำคลอดพร้อมเรียนรู้!';
    if (btnComplete) btnComplete.removeAttribute('disabled');

    // Award coins and XP directly on reticle position
    const targetAnchor = document.getElementById('ar-reticle');
    if (targetAnchor) {
      addRewards(150, 40, targetAnchor);
    }
  }

  function setupListeners() {
    // Back button
    document.getElementById('btn-back-dashboard').addEventListener('click', () => {
      playSynthSound('click');
      stopCamera();
      navigateTo('dashboard');
    });

    // Complete button
    const btnComplete = document.getElementById('btn-complete-stage-3');
    if (btnComplete) {
      btnComplete.addEventListener('click', () => {
        stopCamera();
        onComplete();
      });
    }

    // Enable Webcam trigger button
    const btnRequestCam = document.getElementById('btn-request-cam');
    if (btnRequestCam) {
      btnRequestCam.addEventListener('click', () => {
        playSynthSound('click');
        startWebcam();
      });
    }

    // Tap Reticle to Calibrate
    const reticle = document.getElementById('ar-reticle');
    if (reticle) {
      reticle.addEventListener('click', () => {
        triggerCalibration();
      });
    }
  }

  function stopCamera() {
    if (progressInterval) clearInterval(progressInterval);
    if (cameraStream) {
      cameraStream.getTracks().forEach(track => track.stop());
      cameraStream = null;
    }
  }

  // Initial render setup
  renderHTML();
  
  // Attempt to auto-start webcam
  startWebcam();
}
