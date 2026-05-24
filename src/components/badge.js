/* ==========================================
   SmartBirth Component: Stage 6 - VR Ready Badge & Certificate (Thai)
   ========================================== */

import { saveProgress } from '../main.js';
import { playSynthSound } from '../utils/sfx.js';

export function renderBadge(container, appState, navigateTo) {
  let studentName = appState.studentName || '';

  function renderHTML() {
    const today = new Date().toLocaleDateString('th-TH', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    container.innerHTML = `
      <div class="stage-container">
        <div class="stage-header">
          <div class="stage-title">
            <i data-lucide="award" class="stage-title-icon" style="color:var(--primary);"></i>
            <div>
              <h2>เกียรติบัตรระดับเหรียญทองเกียรติยศ 🎓🏆</h2>
              <p>ยินดีด้วยครับคุณผ่านหลักสูตร Pre-VR จำลองการคลอดแล้ว กรุณากรอกชื่อของคุณเพื่อออกหนังสือรับรอง</p>
            </div>
          </div>
          <div class="stage-actions">
            <button id="btn-back-dashboard" class="btn-icon-text secondary">
              <i data-lucide="arrow-left"></i>
              <span>กลับหน้าหลัก</span>
            </button>
            <button id="btn-print-cert" class="btn-icon-text primary">
              <i data-lucide="printer"></i>
              <span>พิมพ์ใบรับรอง</span>
            </button>
          </div>
        </div>

        <div class="badge-view-container">
          <!-- Central Animated Badge -->
          <div class="badge-showcase" style="position:relative; animation: float 3s infinite ease-in-out;">
            <div class="badge-glow" style="position:absolute; width:100%; height:100%; background:radial-gradient(circle, rgba(253,240,221,0.8) 0%, rgba(255,255,255,0) 70%); border-radius:50%; z-index:-1; filter:blur(10px); transform:scale(1.3);"></div>
            <div class="badge-graphic" style="background: linear-gradient(135deg, var(--primary), var(--warning)); color:#fff; border: 5px solid var(--game-border-color); box-shadow: var(--shadow-md); width:7rem; height:7rem; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:3.5rem;">
              <span>🎓</span>
            </div>
          </div>

          <!-- Name Entry Input -->
          <div class="cert-input-wrapper glass-panel">
            <label for="student-name-input" style="font-size:0.9rem; font-weight:800; color:var(--text-secondary); text-align:center; display:block; margin-bottom:0.35rem;">กรอกชื่อ-นามสกุลของคุณเพื่อลงนามเกียรติบัตร</label>
            <input type="text" id="student-name-input" placeholder="ชื่อ - นามสกุลของคุณ" value="${studentName}" style="width:100%; padding:0.75rem; border:var(--game-border); border-radius:var(--radius-md); font-weight:800; font-size:1.1rem; color:var(--text-primary); text-align:center; box-shadow:var(--shadow-sm); outline:none;">
            <p style="font-size:0.75rem; color:var(--text-muted); margin-top:0.45rem; text-align:center; font-weight:800;">*พิมพ์ชื่อของคุณเพื่ออัปเดตใบรับรองด้านล่างแบบเรียลไทม์</p>
          </div>

          <!-- Printable Certificate Paper -->
          <div class="certificate-paper" id="printable-certificate">
            <div class="cert-header">
              <h3>ใบประกาศเกียรติคุณความพร้อมจำลองเสมือนจริง</h3>
              <h2>SmartBirth Clinical Simulator</h2>
            </div>
            
            <div class="cert-body">
              <p>เอกสารรับรองฉบับนี้ออกไว้ให้เพื่อแสดงว่า</p>
              <div class="cert-recipient" id="cert-recipient-name">${studentName || '[ กรุณากรอกชื่อผู้รับใบรับรอง ]'}</div>
              <p>ได้ผ่านหลักสูตรและแบบประเมินความพร้อมแบบ Pre-VR โดยทำภารกิจสำเร็จสะสมคะแนน <strong>${appState.xp || 0} XP ⭐</strong> และรับรางวัล <strong>${appState.coins || 0} เหรียญทอง 🪙</strong> ครอบคลุมการจำแนกเครื่องมือทำคลอด กายวิภาคศาสตร์ การศึกษาสรีระกลไกการคลอด 3 มิติ ปรับเทียบพื้นที่กล้อง และประเมินประสาทสัมผัสการกางนิ้วตามเกณฑ์สากล</p>
            </div>

            <div class="cert-footer">
              <div class="cert-sign">
                <div class="signature-line"></div>
                <span>ดร. เอฟลิน แวนส์, MD 🩺</span><br>
                <span style="font-size:0.65rem;">ผู้อำนวยการศูนย์จำลองสูติศาสตร์การแพทย์</span>
              </div>
              
              <div class="cert-stamp">
                VR READY<br>ผ่านการรับรอง
              </div>

              <div class="cert-sign">
                <div class="signature-line" style="margin-left:auto; margin-right:auto;"></div>
                <span id="cert-date">${today}</span><br>
                <span style="font-size:0.65rem;">วันที่ออกหนังสือรับรอง</span>
              </div>
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

  function setupListeners() {
    // Back to dashboard
    document.getElementById('btn-back-dashboard').addEventListener('click', () => {
      playSynthSound('click');
      navigateTo('dashboard');
    });

    // Handle Name Input
    const nameInput = document.getElementById('student-name-input');
    const certName = document.getElementById('cert-recipient-name');

    if (nameInput && certName) {
      nameInput.addEventListener('input', (e) => {
        studentName = e.target.value;
        certName.innerText = studentName || '[ กรุณากรอกชื่อผู้รับใบรับรอง ]';
        
        // Save to app state / localstorage
        saveProgress({ studentName });
      });
    }

    // Print certificate handler
    const btnPrint = document.getElementById('btn-print-cert');
    if (btnPrint) {
      btnPrint.addEventListener('click', () => {
        playSynthSound('click');
        if (!studentName.trim()) {
          playSynthSound('wrong');
          alert('กรุณากรอกชื่อ-นามสกุลของคุณในช่องป้อนข้อมูลด้านบนก่อนทำการพิมพ์เกียรติบัตรครับ');
          return;
        }
        window.print();
      });
    }
  }

  renderHTML();
}
