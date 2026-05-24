/* ==========================================
   SmartBirth Component: Stage 5 - Decision Quiz (Thai)
   ========================================== */

import { addRewards } from '../main.js';
import { playSynthSound } from '../utils/sfx.js';

const CORRECT_ORDER = [
  '1. Engagement (ศีรษะเข้าสู่เชิงกราน)',
  '2. Descent (ศีรษะเคลื่อนต่ำลง)',
  '3. Flexion (ศีรษะก้ม)',
  '4. Internal Rotation (ศีรษะหมุนภายใน)',
  '5. Extension (ศีรษะเงย)',
  '6. Restitution & Ext Rotation (หมุนกลับและหมุนภายนอก)',
  '7. Expulsion (คลอดไหล่และลำตัว)'
];

const LEADERBOARD_INITIAL = [
  { rank: 1, name: 'พญ. วริศรา เรืองเดช (MD) 🩺', score: 100 },
  { rank: 2, name: 'พว. มนัสวี สมบูรณ์ (RN) 🧤', score: 100 },
  { rank: 3, name: 'พว. ณภัทร ชูเกียรติ (RN) 🧤', score: 100 },
  { rank: 4, name: 'คุณ (ผู้ทดสอบ) 👤', score: 0 },
  { rank: 5, name: 'นพ. วรุตม์ เจริญสุข (MD) 🩺', score: 85 }
];

export function renderQuiz(container, appState, navigateTo, onComplete) {
  // Shuffle cards
  let shuffledCards = [...CORRECT_ORDER].sort(() => Math.random() - 0.5);
  let leaderboardData = [...LEADERBOARD_INITIAL];
  
  // Placed cards mapping: { slotIndex: cardName } (0-6)
  let placedCards = {
    0: null, 1: null, 2: null, 3: null, 4: null, 5: null, 6: null
  };

  let selectedSrcCard = null; // click-to-place state
  let hasSubmitted = false;

  function renderHTML() {
    container.innerHTML = `
      <div class="stage-container">
        <div class="stage-header">
          <div class="stage-title">
            <i data-lucide="help-circle" class="stage-title-icon"></i>
            <div>
              <h2>ด่านที่ 5: แบบทดสอบเรียงลำดับขั้นตอนกลไกการคลอด 🧠</h2>
              <p>จัดเรียงลำดับขั้นตอนกลไกการเคลื่อนตัวของทารก 7 ขั้นตอนให้ถูกต้องตามกาลเวลาเพื่อพิสูจน์ความรู้เชิงปฏิวัติ</p>
            </div>
          </div>
          <div class="stage-actions">
            <button id="btn-back-dashboard" class="btn-icon-text secondary">
              <i data-lucide="arrow-left"></i>
              <span>กลับหน้าหลัก</span>
            </button>
            <button id="btn-submit-quiz" class="btn-icon-text primary">
              <i data-lucide="send"></i>
              <span>ส่งคำตอบ</span>
            </button>
            <button id="btn-complete-stage-5" class="btn-icon-text success" disabled>
              <i data-lucide="check-circle"></i>
              <span>ส่งงานสำเร็จด่าน 5</span>
            </button>
          </div>
        </div>

        <div class="quiz-layout">
          <!-- Left: Drag-and-drop workspace -->
          <div class="quiz-workspace">
            <div class="quiz-instruction-box">
              <p><strong>ภารกิจสูติศาสตร์:</strong> การจดจำลำดับของกลไกการคลอดได้อย่างแม่นยำมีความสำคัญสูงสุดในห้องทำคลอดจริง ลากตัวเลือกมาจัดเรียงลงในช่องว่างลำดับ 1-7 ด้านขวาให้ถูกต้องครบถ้วน!</p>
            </div>

            <div class="drag-drop-container">
              <!-- Source Cards -->
              <div class="drag-source-panel">
                <div class="panel-header">ตัวเลือกขั้นตอนการเคลื่อนต่ำ</div>
                <div id="source-cards-container" style="display:flex; flex-direction:column; gap:0.5rem; min-height: 300px;">
                  <!-- Render source cards here -->
                </div>
              </div>

              <!-- Target Slots -->
              <div class="drop-target-panel">
                <div class="panel-header">จัดเรียงลำดับขั้นตอน (บนลงล่าง ลำดับที่ 1-7)</div>
                <div style="display:flex; flex-direction:column; gap:0.5rem;">
                  ${Array.from({ length: 7 }).map((_, idx) => `
                    <div class="drop-slot" data-slot-index="${idx}">
                      <div class="slot-number">${idx + 1}</div>
                      <div class="slot-content" id="slot-content-${idx}">
                        <span style="color:var(--text-muted); font-size:0.8rem; margin:auto 0 auto 0.5rem; pointer-events:none;">ช่องว่าง</span>
                      </div>
                    </div>
                  `).join('')}
                </div>
              </div>
            </div>
          </div>

          <!-- Right: Leaderboard rankings -->
          <div class="leaderboard-panel glass-panel">
            <div class="panel-header" style="margin-bottom:0.75rem;"><i data-lucide="award"></i> ตารางอันดับบอร์ดจำลอง</div>
            <div class="leaderboard-list">
              <!-- Rerendered dynamically -->
            </div>
            
            <div style="font-size:0.75rem; color:var(--text-muted); margin-top:1rem; line-height:1.4; font-weight:800;">
              *จัดเรียงลำดับได้ถูกต้องครบ 100% เพื่อไต่อันดับสู่จุดสูงสุดของโรงเรียนสูตินรีแพทย์ พร้อมปลดล็อกรับตราดิจิทัล Pre-VR Ready!
            </div>
          </div>
        </div>
      </div>
    `;

    if (window.lucide) {
      window.lucide.createIcons();
    }

    renderSourceCards();
    renderLeaderboard();
  }

  function renderLeaderboard() {
    const lbContainer = container.querySelector('.leaderboard-list');
    if (!lbContainer) return;

    // Load dynamic score for user
    leaderboardData.forEach(item => {
      if (item.name.includes('คุณ (ผู้ทดสอบ)')) {
        item.score = appState.quizHighScore || 0;
      }
    });

    // Re-sort data
    leaderboardData.sort((a, b) => b.score - a.score);
    leaderboardData.forEach((item, index) => {
      item.rank = index + 1;
    });

    lbContainer.innerHTML = leaderboardData.map(item => {
      const isUser = item.name.includes('คุณ (ผู้ทดสอบ)');
      return `
        <div class="leaderboard-item ${isUser ? 'currentUser' : ''}">
          <div class="rank-name">
            <span class="rank" style="${item.rank <= 3 ? 'background:var(--primary); color:#fff; border-radius:50%; width:20px; height:20px; display:inline-flex; align-items:center; justify-content:center;' : ''}">#${item.rank}</span>
            <span class="name" style="font-weight:900;">${item.name}</span>
          </div>
          <span class="score" style="font-family:var(--font-mono); font-weight:900;">${item.score}%</span>
        </div>
      `;
    }).join('');
  }

  function getStepIcon(cardName) {
    if (cardName.includes('Engagement')) return 'arrow-down-to-line';
    if (cardName.includes('Descent')) return 'arrow-down';
    if (cardName.includes('Flexion')) return 'corner-right-down';
    if (cardName.includes('Internal Rotation')) return 'rotate-cw';
    if (cardName.includes('Extension')) return 'arrow-up-right';
    if (cardName.includes('Restitution')) return 'rotate-ccw';
    if (cardName.includes('Expulsion')) return 'baby';
    return 'grip-vertical';
  }

  // Render cards that have not been placed yet
  function renderSourceCards() {
    const srcContainer = document.getElementById('source-cards-container');
    if (!srcContainer) return;

    srcContainer.innerHTML = '';
    
    shuffledCards.forEach(card => {
      const isPlaced = Object.values(placedCards).includes(card);
      if (isPlaced) return;

      const cardEl = document.createElement('div');
      cardEl.className = `draggable-card ${selectedSrcCard === card ? 'active' : ''}`;
      cardEl.draggable = !hasSubmitted;
      cardEl.setAttribute('data-card-name', card);
      
      if (selectedSrcCard === card) {
        cardEl.style.borderColor = 'var(--primary)';
        cardEl.style.boxShadow = '0 0 10px var(--primary-glow)';
      }

      cardEl.innerHTML = `
        <i data-lucide="grip-vertical" class="card-handle"></i>
        <i data-lucide="${getStepIcon(card)}" style="width: 1.1rem; height: 1.1rem; color: var(--primary); flex-shrink: 0;"></i>
        <span style="margin-left: 0.25rem;">${card}</span>
      `;
      
      srcContainer.appendChild(cardEl);
    });

    if (window.lucide) {
      window.lucide.createIcons();
    }
  }

  function renderPlacedCards() {
    for (let i = 0; i < 7; i++) {
      const slotContent = document.getElementById(`slot-content-${i}`);
      if (!slotContent) continue;

      const card = placedCards[i];
      if (card) {
        slotContent.innerHTML = `
          <div class="draggable-card" style="width:100%; margin:0; display: flex; align-items: center; gap: 0.75rem;" draggable="${!hasSubmitted}" data-card-name="${card}" data-source-slot="${i}">
            <i data-lucide="grip-vertical" class="card-handle"></i>
            <i data-lucide="${getStepIcon(card)}" style="width: 1.1rem; height: 1.1rem; color: var(--primary); flex-shrink: 0;"></i>
            <span>${card}</span>
            <i data-lucide="x" class="remove-card" style="margin-left:auto; width:14px; height:14px; cursor:pointer; color:var(--error);" title="นำออกจากช่อง"></i>
          </div>
        `;
      } else {
        slotContent.innerHTML = `<span style="color:var(--text-muted); font-size:0.8rem; margin:auto 0 auto 0.5rem; pointer-events:none;">ช่องว่าง</span>`;
      }
    }

    if (window.lucide) {
      window.lucide.createIcons();
    }

    // Bind remove button handlers
    container.querySelectorAll('.remove-card').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        playSynthSound('click');
        const slotIdx = btn.closest('.drop-slot').getAttribute('data-slot-index');
        placedCards[slotIdx] = null;
        renderPlacedCards();
        renderSourceCards();
        setupDragAndDrop();
      });
    });
  }

  function setupDragAndDrop() {
    if (hasSubmitted) return;

    const cards = container.querySelectorAll('.draggable-card');
    cards.forEach(card => {
      card.addEventListener('dragstart', (e) => {
        playSynthSound('click');
        e.dataTransfer.setData('text/plain', card.getAttribute('data-card-name'));
        const sourceSlot = card.getAttribute('data-source-slot');
        if (sourceSlot !== null) {
          e.dataTransfer.setData('source-slot', sourceSlot);
        }
      });

      card.addEventListener('click', (e) => {
        e.stopPropagation();
        playSynthSound('click');
        const cardName = card.getAttribute('data-card-name');
        const sourceSlot = card.getAttribute('data-source-slot');

        if (sourceSlot !== null) {
          placedCards[sourceSlot] = null;
          renderPlacedCards();
          renderSourceCards();
          setupDragAndDrop();
        } else {
          selectedSrcCard = selectedSrcCard === cardName ? null : cardName;
          renderSourceCards();
        }
      });
    });

    const slots = container.querySelectorAll('.drop-slot');
    slots.forEach(slot => {
      const slotIndex = parseInt(slot.getAttribute('data-slot-index'));

      slot.addEventListener('dragover', (e) => {
        e.preventDefault();
        slot.classList.add('drag-over');
      });

      slot.addEventListener('dragleave', () => {
        slot.classList.remove('drag-over');
      });

      slot.addEventListener('drop', (e) => {
        e.preventDefault();
        slot.classList.remove('drag-over');

        const cardName = e.dataTransfer.getData('text/plain');
        const sourceSlot = e.dataTransfer.getData('source-slot');

        handleCardPlacement(cardName, slotIndex, sourceSlot);
      });

      slot.addEventListener('click', () => {
        if (selectedSrcCard) {
          handleCardPlacement(selectedSrcCard, slotIndex, null);
          selectedSrcCard = null;
          renderSourceCards();
        }
      });
    });
  }

  function handleCardPlacement(cardName, targetSlotIndex, sourceSlotIndex) {
    playSynthSound('tick');
    const displacedCard = placedCards[targetSlotIndex];
    
    if (sourceSlotIndex !== null && sourceSlotIndex !== '') {
      placedCards[sourceSlotIndex] = displacedCard;
    }

    placedCards[targetSlotIndex] = cardName;
    
    renderPlacedCards();
    renderSourceCards();
    setupDragAndDrop();
  }

  // falling confetti overlay logic
  function triggerConfetti() {
    const wrapper = document.getElementById('floating-coins-container');
    if (!wrapper) return;

    const colors = ['#ff758f', '#4ea8de', '#52b788', '#f7d070', '#b983ff'];
    for (let i = 0; i < 80; i++) {
      const conf = document.createElement('div');
      conf.style.position = 'absolute';
      conf.style.width = `${6 + Math.random() * 8}px`;
      conf.style.height = `${10 + Math.random() * 12}px`;
      conf.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
      conf.style.left = `${Math.random() * 100}vw`;
      conf.style.top = `-20px`;
      conf.style.zIndex = '9999';
      conf.style.transform = `rotate(${Math.random() * 360}deg)`;
      
      wrapper.appendChild(conf);
      
      const speed = 2.5 + Math.random() * 4;
      const spin = 10 + Math.random() * 20;
      const swing = 0.5 + Math.random() * 1.5;
      let t = 0;
      
      const anim = setInterval(() => {
        t += 0.05;
        const top = parseFloat(conf.style.top) + speed;
        const left = parseFloat(conf.style.left) + Math.sin(t * swing) * 2.2;
        conf.style.top = `${top}px`;
        conf.style.left = `${left}px`;
        conf.style.transform = `rotate(${t * swing * spin}deg)`;
        
        if (top > window.innerHeight) {
          clearInterval(anim);
          conf.remove();
        }
      }, 20);
    }
  }

  function submitQuiz() {
    const allFilled = Object.values(placedCards).every(card => card !== null);
    if (!allFilled) {
      playSynthSound('wrong');
      alert('กรุณาใส่ขั้นตอนให้ครบถ้วนทั้ง 7 ช่องก่อนกดยืนยันคำตอบครับ');
      return;
    }

    hasSubmitted = true;
    let correctCount = 0;

    // Validate slots
    for (let i = 0; i < 7; i++) {
      const slot = container.querySelector(`.drop-slot[data-slot-index="${i}"]`);
      if (!slot) continue;

      const card = placedCards[i];
      const isCorrect = card === CORRECT_ORDER[i];

      if (isCorrect) {
        correctCount++;
        slot.classList.add('correct');
      } else {
        slot.classList.add('incorrect');
        slot.classList.add('shake');
        setTimeout(() => slot.classList.remove('shake'), 400);
      }
    }

    const scorePercent = Math.round((correctCount / 7) * 100);

    // Disable cards dragging
    container.querySelectorAll('.draggable-card').forEach(card => {
      card.draggable = false;
      card.style.cursor = 'default';
    });

    // Save and update leaderboard ranks
    if (scorePercent > appState.quizHighScore) {
      appState.quizHighScore = scorePercent;
    }
    
    // Sort and rerender leaderboard on screen immediately
    renderLeaderboard();

    // Toggle button state
    const btnSubmit = document.getElementById('btn-submit-quiz');
    if (btnSubmit) btnSubmit.disabled = true;

    if (correctCount === 7) {
      playSynthSound('correct');
      triggerConfetti();

      // Unlock complete
      const btnComplete = document.getElementById('btn-complete-stage-5');
      if (btnComplete) btnComplete.removeAttribute('disabled');

      // Large bonus points rewards
      addRewards(200, 80, document.getElementById('btn-submit-quiz'));
      
      alert('ยินดีด้วยครับ! คุณเรียงลำดับขั้นตอนกลไกคลอด 7 ขั้นตอนได้อย่างถูกต้องสมบูรณ์แบบ 100% 🌟');
    } else {
      playSynthSound('wrong');
      setTimeout(() => {
        if (confirm(`คุณตอบถูกทั้งหมด ${correctCount} จาก 7 ขั้นตอน (ได้คะแนน ${scorePercent}%) ต้องการล้างคำตอบและลองใหม่อีกครั้งเพื่อสะสมดาวให้ครบถ้วน 100% หรือไม่ครับ?`)) {
          retryQuiz();
        }
      }, 900);
    }
  }

  function retryQuiz() {
    playSynthSound('click');
    hasSubmitted = false;
    placedCards = { 0: null, 1: null, 2: null, 3: null, 4: null, 5: null, 6: null };
    shuffledCards = [...CORRECT_ORDER].sort(() => Math.random() - 0.5);
    
    // Clear slots
    container.querySelectorAll('.drop-slot').forEach(slot => {
      slot.className = 'drop-slot';
    });

    const btnSubmit = document.getElementById('btn-submit-quiz');
    if (btnSubmit) btnSubmit.disabled = false;

    renderPlacedCards();
    renderSourceCards();
    setupDragAndDrop();
  }

  // Initial rendering
  renderHTML();
  renderPlacedCards();
  setupDragAndDrop();

  // Attach control listeners
  document.getElementById('btn-back-dashboard').addEventListener('click', () => {
    playSynthSound('click');
    navigateTo('dashboard');
  });

  document.getElementById('btn-submit-quiz').addEventListener('click', submitQuiz);

  const btnComplete = document.getElementById('btn-complete-stage-5');
  if (btnComplete) {
    btnComplete.addEventListener('click', () => {
      onComplete(100);
    });
  }
}
