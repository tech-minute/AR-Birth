/* ==========================================
   SmartBirth Component: Journey Roadmap Dashboard Grid (Thai)
   ========================================== */

function getLevelStarsHTML(stageKey, appState, isQuiz = false, scoreField = '') {
  const isCompleted = appState.completedStages[stageKey];
  if (!isCompleted) {
    return `
      <div class="level-stars-container">
        <span class="level-star">⭐</span>
        <span class="level-star">⭐</span>
        <span class="level-star">⭐</span>
      </div>
    `;
  }
  
  let starsCount = 3;
  if (isQuiz && scoreField) {
    const score = appState[scoreField] || 0;
    if (score >= 95 || score === 100) starsCount = 3;
    else if (score >= 70) starsCount = 2;
    else starsCount = 1;
  }

  return `
    <div class="level-stars-container">
      <span class="level-star ${starsCount >= 1 ? 'active' : ''}">⭐</span>
      <span class="level-star ${starsCount >= 2 ? 'active' : ''}">⭐</span>
      <span class="level-star ${starsCount >= 3 ? 'active' : ''}">⭐</span>
    </div>
  `;
}

export function renderDashboard(container, appState, navigateTo) {
  // Check if everything is complete to highlight the Badge section
  const allStagesCompleted = 
    appState.completedStages.stage1 &&
    appState.completedStages.stage2 &&
    appState.completedStages.stage3 &&
    appState.completedStages.stage4 &&
    appState.completedStages.stage5;

  const dashboardHTML = `
    <div class="dashboard-view">
      <div class="dashboard-hero">
        <h2>🏆 SmartBirth Learning Quest 🤰</h2>
        <p>หลักสูตรเตรียมความพร้อมก่อนแล็บจริงแบบ Pre-VR สะสมค่าทักษะกางนิ้วสัมผัสและกลไกการทำคลอดเพื่อเป็นสูตินรีแพทย์อัจฉริยะ!</p>
      </div>

      <div class="roadmap-container grid-layout">
        <!-- STAGE 1 -->
        <div class="grid-step-card ${getStepClass(1, appState)}" data-stage="stage1">
          <div class="card-header">
            <span class="step-meta">ภารกิจที่ 1 • เลเวล 1</span>
            <div class="step-icon-badge">
              <img src="https://img.icons8.com/color/256/rubber-gloves.png" alt="🧤" style="width: 2.2rem; height: 2.2rem;">
            </div>
          </div>
          <h3>เครื่องมือและกายวิภาค</h3>
          <p>จัดเตรียมเช็คลิสต์และทบทวนรายละเอียดเครื่องมือทำคลอดจาก Flashcard ให้ครบถ้วน</p>
          ${getLevelStarsHTML('stage1', appState)}
          <div class="reward-info-tag">รางวัล: +100 XP 🪙 +50</div>
          <span class="step-status-tag" style="margin-top: 1rem;">${getStepStatusText('stage1', appState)}</span>
        </div>

        <!-- STAGE 2 -->
        <div class="grid-step-card ${getStepClass(2, appState)}" data-stage="stage2">
          <div class="card-header">
            <span class="step-meta">ภารกิจที่ 2 • เลเวล 2</span>
            <div class="step-icon-badge">
              <img src="https://img.icons8.com/color/256/pregnant.png" alt="🤰" style="width: 2.2rem; height: 2.2rem;">
            </div>
          </div>
          <h3>กลไกการคลอด 3 มิติ</h3>
          <p>หมุนโมเดลอุ้งเชิงกราน 360 องศาเพื่อเรียนรู้ระดับการเคลื่อนต่ำและหมุนของเด็ก 7 ขั้นตอน</p>
          ${getLevelStarsHTML('stage2', appState)}
          <div class="reward-info-tag">รางวัล: +100 XP 🪙 +50</div>
          <span class="step-status-tag" style="margin-top: 1rem;">${getStepStatusText('stage2', appState)}</span>
        </div>

        <!-- STAGE 3 -->
        <div class="grid-step-card ${getStepClass(3, appState)}" data-stage="stage3">
          <div class="card-header">
            <span class="step-meta">ภารกิจที่ 3 • เลเวล 3</span>
            <div class="step-icon-badge">
              <img src="https://img.icons8.com/color/256/camera.png" alt="📷" style="width: 2.2rem; height: 2.2rem;">
            </div>
          </div>
          <h3>ปรับเทียบพิกัด AR Lab</h3>
          <p>เรียนรู้ท่าประคองมือทำคลอด (Ritgen Maneuver) พร้อมปรับเทียบพิกัดกล้องเว็บแคม</p>
          ${getLevelStarsHTML('stage3', appState)}
          <div class="reward-info-tag">รางวัล: +150 XP 🪙 +60</div>
          <span class="step-status-tag" style="margin-top: 1rem;">${getStepStatusText('stage3', appState)}</span>
        </div>

        <!-- STAGE 4 -->
        <div class="grid-step-card ${getStepClass(4, appState)}" data-stage="stage4">
          <div class="card-header">
            <span class="step-meta">ภารกิจที่ 4 • เลเวล 4</span>
            <div class="step-icon-badge">
              <img src="https://img.icons8.com/color/256/hand.png" alt="🖐️" style="width: 2.2rem; height: 2.2rem;">
            </div>
          </div>
          <h3>ประเมินสัมผัสกางนิ้ว</h3>
          <p>กางสองนิ้วสัมผัสบนจอจำลองขนาดปากมดลูกเปิดจริง (1-10 ซม.) (คะแนนสูงสุด: ${appState.dilationHighScore || 0}%)</p>
          ${getLevelStarsHTML('stage4', appState, true, 'dilationHighScore')}
          <div class="reward-info-tag">รางวัล: +200 XP 🪙 +80</div>
          <span class="step-status-tag" style="margin-top: 1rem;">${getStepStatusText('stage4', appState)}</span>
        </div>

        <!-- STAGE 5 -->
        <div class="grid-step-card ${getStepClass(5, appState)}" data-stage="stage5">
          <div class="card-header">
            <span class="step-meta">ภารกิจที่ 5 • เลเวล 5</span>
            <div class="step-icon-badge">
              <img src="https://img.icons8.com/color/256/brain.png" alt="🧠" style="width: 2.2rem; height: 2.2rem;">
            </div>
          </div>
          <h3>เกมเรียงลำดับขั้นตอน</h3>
          <p>ทดสอบเรียงลำดับกลไกการเคลื่อนตัวของทารก 7 ขั้นตอนให้ถูกต้องตามกาลเวลา (คะแนนสูงสุด: ${appState.quizHighScore || 0}%)</p>
          ${getLevelStarsHTML('stage5', appState, true, 'quizHighScore')}
          <div class="reward-info-tag">รางวัล: +200 XP 🪙 +80</div>
          <span class="step-status-tag" style="margin-top: 1rem;">${getStepStatusText('stage5', appState)}</span>
        </div>

        <!-- VR READY BADGE -->
        <div class="grid-step-card unlocked" data-stage="stage6" style="${allStagesCompleted ? 'border-color: var(--primary); box-shadow: var(--shadow-lg); background: #fffcfd;' : ''}">
          <div class="card-header">
            <span class="step-meta" style="color: var(--primary-hover)">เป้าหมายปลายทาง • เลเวล 6</span>
            <div class="step-icon-badge" style="${allStagesCompleted ? 'background-color: var(--primary);' : ''}">
              <img src="https://img.icons8.com/color/256/graduation-cap.png" alt="🎓" style="width: 2.2rem; height: 2.2rem;">
            </div>
          </div>
          <h3>เกียรติบัตร Pre-VR Ready</h3>
          <p>พิมพ์ใบรับรองความความพร้อมสำหรับใช้สอบจำลองแล็บ VR และดูตำแหน่งแรงก์ของคุณบนตาราง</p>
          <div class="level-stars-container">
            <span class="level-star ${allStagesCompleted ? 'active' : ''}">⭐</span>
            <span class="level-star ${allStagesCompleted ? 'active' : ''}">⭐</span>
            <span class="level-star ${allStagesCompleted ? 'active' : ''}">⭐</span>
          </div>
          <span class="step-status-tag" style="margin-top: 1rem; background: rgba(255, 117, 143, 0.1); color: var(--primary-hover);">
            ${allStagesCompleted ? '🏆 พร้อมกดรับสิทธิ์' : '👀 ตรวจเกียรติบัตร'}
          </span>
        </div>
      </div>
    </div>
  `;

  container.innerHTML = dashboardHTML;

  // Add click handlers for unlocked steps
  const steps = container.querySelectorAll('.grid-step-card');
  steps.forEach(step => {
    const stage = step.getAttribute('data-stage');
    if (stage) {
      step.addEventListener('click', () => {
        navigateTo(stage);
      });
    }
  });
}

function getStepClass(stageNum, appState) {
  const stageKey = `stage${stageNum}`;
  if (appState.completedStages[stageKey]) {
    return 'completed';
  } else {
    return 'unlocked';
  }
}

function getStepStatusText(stageKey, appState) {
  if (appState.completedStages[stageKey]) {
    return '✅ สำเร็จเควสนี้แล้ว';
  } else {
    return '🎯 เข้าสู่การเรียนรู้';
  }
}
