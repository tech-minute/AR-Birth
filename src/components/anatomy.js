/* ==========================================
   SmartBirth Component: Stage 1 - Anatomy Master (Thai)
   ========================================== */

import { addRewards } from '../main.js';
import { playSynthSound } from '../utils/sfx.js';

const TOOLS_DATA = [
  {
    id: 'gloves',
    name: 'ถุงมือปราศจากเชื้อ (Sterile Gloves) 🧤',
    short: 'สำหรับเทคนิคการทำคลอดที่สะอาดปราศจากเชื้อและป้องกันการปนเปื้อน',
    description: 'มีความจำเป็นสูงสุดในการรักษาความสะอาดและการควบคุมเชื้อระหว่างทำคลอด ผู้ทำคลอดต้องสวมใส่เพื่อป้องกันสิ่งปนเปื้อนเข้าสู่ช่องคลอดของมารดา และปกป้องตนเองจากการสัมผัสสารคัดหลั่งและเลือด โดยต้องสวมใส่ด้วยเทคนิคปราศจากเชื้อ (Sterile Gloving Technique) ที่ถูกต้อง',
    icon: 'shield',
  },
  {
    id: 'scissors',
    name: 'กรรไกรตัดฝีเย็บ (Episiotomy Scissors) ✂️',
    short: 'กรรไกรโค้งสำหรับตัดขยายขนาดช่องทางคลอดกรณีฉุกเฉิน',
    description: 'กรรไกรทางการแพทย์ที่ออกแบบเป็นพิเศษให้มีใบมีดทำมุมเอียงและปลายกลมทู่เพื่อป้องกันอันตรายต่อทารก ใช้สำหรับการตัดฝีเย็บ (Episiotomy) ขยายช่องทางคลอดให้กว้างขึ้นอย่างรวดเร็ว ในภาวะทารกขาดออกซิเจนเฉียบพลัน หรือกรณีไหล่ติดคลอดยาก',
    icon: 'scissors',
  },
  {
    id: 'clamp',
    name: 'ตัวหนีบสายสะดือ (Umbilical Cord Clamp) 🔗',
    short: 'ตัวล็อกพลาสติกเหนียวทนทานสำหรับปิดเส้นเลือดสายสะดือ',
    description: 'อุปกรณ์หนีบล็อกทำจากพลาสติกเกรดการแพทย์พร้อมฟันล็อกแน่นสนิท ใช้หนีบสายสะดือทารกแรกเกิดที่จุดห่างจากหน้าท้องทารกประมาณ 2-3 ซม. และจุดที่สองที่ 5 ซม. ก่อนทำการตัด เพื่อตัดกระแสเลือดไหลเวียนระหว่างรกกับตัวทารกและป้องกันอาการตกเลือด',
    icon: 'link-2',
  },
  {
    id: 'bulb',
    name: 'ลูกยางแดงดูดเสมหะ (Bulb Syringe) 🔴',
    short: 'ลูกยางสำหรับเคลียร์ทางเดินหายใจเด็กแรกเกิด',
    description: 'อุปกรณ์แรงมือทำจากยางเนื้อเหนียวนุ่มสีแดง ใช้สำหรับดูดน้ำคร่ำ เมือก หรือขี้เทาออกจากปากและจมูกของทารกทันทีที่ศีรษะทารกคลอดพ้นทางช่องคลอด เพื่อเปิดทางเดินหายใจให้ทารกหายใจได้ด้วยตนเอง หลักการสำคัญ: ต้องดูดในช่องปากก่อนดูดในรูจมูกเสมอเพื่อป้องกันการสำลักเข้าสู่ปอด',
    icon: 'wind',
  }
];

export function renderAnatomy(container, appState, navigateTo, onComplete) {
  let activeCardIndex = 0;
  let viewedCards = new Set([0]); // Track viewed cards
  
  function updateDOM() {
    const activeTool = TOOLS_DATA[activeCardIndex];
    
    // Check if the current checklist items are checked in state
    const allChecked = TOOLS_DATA.every(tool => appState.checklist[tool.id]);
    const allCardsViewed = viewedCards.size === TOOLS_DATA.length;
    const canComplete = allChecked && allCardsViewed;

    container.innerHTML = `
      <div class="stage-container">
        <div class="stage-header">
          <div class="stage-title">
            <i data-lucide="book-open" class="stage-title-icon"></i>
            <div>
              <h2>ด่านที่ 1: กายวิภาคและเครื่องมือทำคลอด 🎒</h2>
              <p>เรียนรู้ด้วยตนเอง: ศึกษาข้อมูลการ์ดรายละเอียดเครื่องมือและเช็คลิสต์เตรียมของให้ครบถ้วนเพื่อรับรางวัลประจำด่าน</p>
            </div>
          </div>
          <div class="stage-actions">
            <button id="btn-back-dashboard" class="btn-icon-text secondary">
              <i data-lucide="arrow-left"></i>
              <span>กลับหน้าหลัก</span>
            </button>
            <button id="btn-complete-stage-1" class="btn-icon-text success" ${canComplete ? '' : 'disabled'}>
              <i data-lucide="check-circle"></i>
              <span>ส่งงานสำเร็จด่าน 1</span>
            </button>
          </div>
        </div>

        <div class="anatomy-layout">
          <!-- Left Column: Checklist -->
          <div class="anatomy-checklist-panel glass-panel">
            <div class="panel-header">เช็คลิสต์เตรียมเครื่องมือทำคลอด (+15 XP 🪙 +5 ต่อเครื่องมือ)</div>
            <div class="checklist-items">
              ${TOOLS_DATA.map(tool => {
                const isChecked = appState.checklist[tool.id];
                return `
                  <div class="checklist-item ${isChecked ? 'checked' : ''}" data-tool-id="${tool.id}">
                    <div class="checklist-checkbox">
                      <i data-lucide="check"></i>
                    </div>
                    <div class="checklist-info">
                      <h4>${tool.name}</h4>
                      <p>${tool.short}</p>
                    </div>
                  </div>
                `;
              }).join('')}
            </div>
            
            ${!allChecked ? `
              <p class="text-muted" style="font-size: 0.85rem; margin-top: 1rem; font-weight: 800;">
                💡 คลิกเลือกไอเทมแต่ละตัวด้านบนเพื่อสวมใส่และตรวจสอบความปลอดภัยทางคลินิก
              </p>
            ` : ''}
          </div>

          <!-- Right Column: Interactive Flashcard -->
          <div class="anatomy-flashcards-panel">
            <div class="panel-header">การทบทวนความรู้ทางคลินิก (แตะเพื่อพลิกการ์ด)</div>
            
            <div class="flashcards-container">
              <div class="flashcard" id="interactive-flashcard">
                <!-- Front Side -->
                <div class="flashcard-front">
                  <div class="flashcard-icon-wrapper">
                    <i data-lucide="${activeTool.icon}"></i>
                  </div>
                  <h3>${activeTool.name}</h3>
                  <p>แตะที่นี่เพื่อพลิกอ่านคำแนะนำการใช้งานทางคลินิก</p>
                  <div class="flashcard-instruction">
                    <i data-lucide="rotate-cw"></i> แตะเพื่อพลิกการ์ด
                  </div>
                </div>
                <!-- Back Side -->
                <div class="flashcard-back">
                  <h4>การใช้งานทางคลินิก 🩺</h4>
                  <p>${activeTool.description}</p>
                  <div class="flashcard-instruction">
                    <i data-lucide="rotate-ccw"></i> แตะเพื่อพลิกกลับด้านหน้า
                  </div>
                </div>
              </div>
            </div>

            <div class="flashcard-controls">
              <button id="btn-prev-card" class="btn-icon-text secondary" ${activeCardIndex === 0 ? 'disabled' : ''}>
                <i data-lucide="chevron-left"></i>
                <span>ก่อนหน้า</span>
              </button>
              
              <span class="flashcard-indicator">${activeCardIndex + 1} / ${TOOLS_DATA.length}</span>
              
              <button id="btn-next-card" class="btn-icon-text secondary" ${activeCardIndex === TOOLS_DATA.length - 1 ? 'disabled' : ''}>
                <span>ถัดไป</span>
                <i data-lucide="chevron-right"></i>
              </button>
            </div>

            ${!allCardsViewed ? `
              <p class="text-muted" style="font-size: 0.85rem; margin-top: 0.5rem; text-align: center; font-weight: 800;">
                📖 ศึกษาข้อมูลบน Flashcard ให้ครบทุกใบ (อ่านแล้ว: ${viewedCards.size}/${TOOLS_DATA.length})
              </p>
            ` : ''}
          </div>
        </div>
      </div>
    `;

    // Recreate Lucide icons inside dynamic DOM
    if (window.lucide) {
      window.lucide.createIcons();
    }

    // Attach Event Listeners
    setupListeners();
  }

  function setupListeners() {
    // Back button
    document.getElementById('btn-back-dashboard').addEventListener('click', () => {
      navigateTo('dashboard');
    });

    // Complete button
    const btnComplete = document.getElementById('btn-complete-stage-1');
    if (btnComplete && !btnComplete.disabled) {
      btnComplete.addEventListener('click', () => {
        onComplete();
      });
    }

    // Flashcard Flip
    const cardEl = document.getElementById('interactive-flashcard');
    if (cardEl) {
      cardEl.addEventListener('click', () => {
        playSynthSound('click');
        cardEl.classList.toggle('flipped');
      });
    }

    // Prev Card
    const btnPrev = document.getElementById('btn-prev-card');
    if (btnPrev && activeCardIndex > 0) {
      btnPrev.addEventListener('click', () => {
        playSynthSound('click');
        activeCardIndex--;
        viewedCards.add(activeCardIndex);
        updateDOM();
      });
    }

    // Next Card
    const btnNext = document.getElementById('btn-next-card');
    if (btnNext && activeCardIndex < TOOLS_DATA.length - 1) {
      btnNext.addEventListener('click', () => {
        playSynthSound('click');
        activeCardIndex++;
        viewedCards.add(activeCardIndex);
        updateDOM();
      });
    }

    // Checklist toggles
    const checklistItems = container.querySelectorAll('.checklist-item');
    checklistItems.forEach(item => {
      item.addEventListener('click', () => {
        const id = item.getAttribute('data-tool-id');
        const wasChecked = appState.checklist[id];
        
        // Toggle in state
        appState.checklist[id] = !appState.checklist[id];
        
        // Save state immediately
        localStorage.setItem('smartbirth_progress', JSON.stringify(appState));
        
        if (!wasChecked) {
          playSynthSound('tick');
          addRewards(15, 5, item);
        } else {
          playSynthSound('click');
        }
        
        // Update view
        updateDOM();
      });
    });
  }

  // Initial render
  updateDOM();
}
