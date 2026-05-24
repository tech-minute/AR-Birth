/* ==========================================
   SmartBirth Component: Stage 2 - Mechanism Pro (Three.js) (Thai)
   ========================================== */

import * as THREE from 'three';
import { addRewards } from '../main.js';
import { playSynthSound } from '../utils/sfx.js';

const MOVEMENT_STEPS = [
  {
    title: 'การเตรียมตัวเข้าสู่เชิงกราน (Pre-Engagement) 🤰',
    desc: 'ศีรษะของทารกลอยอยู่เหนือขอบทางเข้าของอุ้งเชิงกราน (Pelvic Inlet) โดยปกติแล้วศีรษะทารกจะหันไปทางด้านข้างของช่องเชิงกรานมารดา (Occiput Transverse)',
    notes: [
      'ความสูงของศีรษะทารก (Station) ยังอยู่สูงเหนือกึ่งกลางโพรงเชิงกราน',
      'แนวรอยต่อกะโหลกศีรษะ (Sagittal suture) อยู่ในแนวขวางหรือแนวเฉียง'
    ]
  },
  {
    title: '1. ศีรษะเข้าสู่เชิงกราน (Engagement) 🎯',
    desc: 'เส้นผ่านศูนย์กลางกว้างสุดของศีรษะทารก (Biparietal diameter) เคลื่อนผ่านขอบทางเข้าของอุ้งเชิงกรานเข้ามาในโพรงเชิงกราน ศีรษะมักจะยังคงหันในแนวขวาง',
    notes: [
      'ระดับศีรษะทารกเคลื่อนลงมาถึงตำแหน่งของปุ่ม ischial spines (เรียกว่า Station 0)',
      'การมี Engagement เป็นการส่งสัญญาณที่ดีว่าขนาดศีรษะทารกและทางเข้าเชิงกรานมารดามีสัดส่วนที่เข้ากันได้'
    ]
  },
  {
    title: '2. ศีรษะเคลื่อนต่ำลง (Descent) ⬇️',
    desc: 'ศีรษะและตัวทารกเคลื่อนต่ำลงไปตามช่องคลอดเรื่อยๆ ภายใต้แรงบีบตัวของกล้ามเนื้อมดลูกและการออกแรงเบ่งอย่างสม่ำเสมอของมารดา',
    notes: [
      'เกิดขึ้นอย่างต่อเนื่องตั้งแต่ระยะปากมดลูกเปิดจนกระทั่งทารกคลอดเสร็จสิ้น',
      'ประเมินระดับความต่ำเป็นหน่วย Station ที่เป็นค่าบวก (+1 ถึง +5)'
    ]
  },
  {
    title: '3. ศีรษะก้ม (Flexion) 🔀',
    desc: 'ในขณะที่ศีรษะเคลื่อนต่ำลงไป จะพบกับแรงต้านจากผนังช่องคลอดและพื้นเชิงกราน ทำให้ศีรษะก้มลงโดยอัตโนมัติจนคางชิดหน้าอกทารก',
    notes: [
      'การก้มช่วยปรับเอาเส้นผ่านศูนย์กลางศีรษะส่วนที่แคบที่สุด (Suboccipitobregmatic, ~9.5 ซม.) เพื่อนำทางผ่านช่องคลอด',
      'เป็นขั้นตอนสำคัญในการลดการใช้เนื้อที่ทางผ่านเพื่อให้คลอดง่ายขึ้น'
    ]
  },
  {
    title: '4. ศีรษะหมุนภายใน (Internal Rotation) 🔄',
    desc: 'ศีรษะของทารกจะหมุนปรับตำแหน่งภายในช่องคลอดประมาณ 90 องศา จากแนวขวางมาอยู่ในแนวหน้าหลัง (Occiput Anterior) เพื่อหันส่วนท้ายทอยมาขัดอยู่ใต้กระดูกหัวหน่าวมารดา',
    notes: [
      'ปรับแนวศีรษะทารกให้สอดรับกับความกว้างแนวหน้าหลังของช่องทางออกเชิงกราน',
      'รอยต่อกะโหลกศีรษะทารก (Sagittal suture) เปลี่ยนจากแนวนอนขวางเป็นแนวตั้งหน้าหลัง'
    ]
  },
  {
    title: '5. ศีรษะเงย (Extension) ↗️',
    desc: 'เมื่อศีรษะท้ายทอยขัดแน่นใต้กระดูกหัวหน่าวมารดา (Symphysis pubis) เป็นจุดหมุน ศีรษะทารกจะก้มต่อไปไม่ได้ จึงเริ่มเงยขึ้นตามมุมโค้งทางออกของช่องคลอด หน้าผาก หน้า และคางจะค่อยๆ ไหลผ่านพ้นฝีเย็บออกมา',
    notes: [
      'ศีรษะของทารกโผล่พ้นช่องคลอดออกมาภายนอกอย่างสมบูรณ์',
      'ผู้ทำคลอดต้องประคองศีรษะและควบคุมแรงเบ่งในขั้นตอนนี้ให้ค่อยเป็นค่อยไปเพื่อรักษาและป้องกันแผลฝีเย็บฉีกขาด'
    ]
  },
  {
    title: '6. ศีรษะสะบัดกลับและหมุนภายนอก (Restitution & External Rotation) ↩️',
    desc: 'เมื่อศีรษะคลอดพ้นมาแล้ว ศีรษะจะหมุนกลับไปแนวขวางธรรมชาติ (Restitution) เพื่อคลายการบิดตัวของลำคอ จากนั้นจะหมุนภายนอกเพิ่มอีกเพื่อช่วยประคองให้ไหล่ทารกที่อยู่ด้านในหมุนตัวเข้าสู่แนวหน้าหลังเตรียมคลอดไหล่',
    notes: [
      'Restitution: ศีรษะทารกสะบัดกลับไปตั้งฉากกับแนวบ่าของเด็กเอง',
      'External Rotation: เป็นปฏิกิริยาต่อเนื่องจากการหมุนแนวไหล่ของทารกภายในเชิงกรานเข้าหาแนวดิ่งหน้าหลัง'
    ]
  },
  {
    title: '7. การคลอดไหล่และลำตัว (Expulsion) 👶🎉',
    desc: 'ทำคลอดไหล่บนโดยโน้มศีรษะทารกลงด้านล่างเบาๆ เพื่อให้ไหล่บนลอดพ้นกระดูกหัวหน่าวมารดา จากนั้นดึงยกศีรษะทารกขึ้นด้านบนเพื่อทำคลอดไหล่ล่างตามลำดับ เมื่อคลอดไหล่ทั้งสองข้างได้แล้ว ลำตัวและขาจะคลอดตามออกมาอย่างรวดเร็ว',
    notes: [
      'เป็นจุดสิ้นสุดของกระบวนการคลอดทารก',
      'แพทย์หรือพยาบาลทำคลอดจะประคองตัวทารกขึ้นขนานไปตามสรีระความโค้งทางช่องคลอดมารดา'
    ]
  }
];

// Helper to interpolate position and rotation values
function getFetalTransform(value) {
  // Define keyframes for 8 stages (index 0 to 7)
  const keyframes = [
    { pos: [0, 2.2, 0], rot: [0, 0, Math.PI / 2], flex: 0.1 },        // 0. Pre-engagement
    { pos: [0, 1.2, 0], rot: [0, 0, Math.PI / 2], flex: 0.3 },        // 1. Engagement
    { pos: [0, 0.4, 0], rot: [0, 0, Math.PI / 2], flex: 0.6 },        // 2. Descent
    { pos: [0, -0.4, 0], rot: [0, 0, Math.PI / 2], flex: 1.2 },       // 3. Flexion (Chin flexes)
    { pos: [0, -1.1, 0.1], rot: [0, -Math.PI / 2, 0], flex: 1.2 },    // 4. Internal Rotation (Rotates OA)
    { pos: [0, -1.8, 1.0], rot: [-Math.PI / 4, -Math.PI / 2, 0], flex: 0.2 }, // 5. Extension (Head extends)
    { pos: [0, -2.4, 2.1], rot: [-Math.PI / 4, 0, 0], flex: 0.4 },    // 6. Restitution/Ext Rotation
    { pos: [0, -3.6, 3.6], rot: [-Math.PI / 4, 0, 0], flex: 0.4 }     // 7. Expulsion
  ];

  const index = Math.floor(value);
  const frac = value - index;

  if (index >= keyframes.length - 1) {
    return keyframes[keyframes.length - 1];
  }

  const k1 = keyframes[index];
  const k2 = keyframes[index + 1];

  // Linear interpolation for positions
  const pos = [
    k1.pos[0] + (k2.pos[0] - k1.pos[0]) * frac,
    k1.pos[1] + (k2.pos[1] - k1.pos[1]) * frac,
    k1.pos[2] + (k2.pos[2] - k1.pos[2]) * frac
  ];

  // Slerp-like interpolation for rotations
  const rot = [
    k1.rot[0] + (k2.rot[0] - k1.rot[0]) * frac,
    k1.rot[1] + (k2.rot[1] - k1.rot[1]) * frac,
    k1.rot[2] + (k2.rot[2] - k1.rot[2]) * frac
  ];

  const flex = k1.flex + (k2.flex - k1.flex) * frac;

  return { pos, rot, flex };
}

export function renderMechanism(container, appState, navigateTo, onComplete) {
  let sliderValue = 0;
  let maxSliderViewed = 0; // Track if the user scrubbed to the end
  let scene, camera, renderer, animationFrameId;
  let pelvisGroup, fetusGroup;
  let lastRoundedValue = 0;
  
  // Custom rotation angles for camera interaction
  let rotX = 0.2;
  let rotY = -0.5;

  function renderHTML() {
    container.innerHTML = `
      <div class="stage-container">
        <div class="stage-header">
          <div class="stage-title">
            <i data-lucide="rotate-3d" class="stage-title-icon"></i>
            <div>
              <h2>ด่านที่ 2: กลไกการคลอด 3 มิติเชิงปฏิสัมพันธ์ 🤰</h2>
              <p>เลื่อนแถบสไลด์เดอร์ด้านล่างเพื่อสังเกตกลไกทารกทั้ง 7 ขั้นตอน ใช้นิ้วลากเพื่อหมุนตรวจวิเคราะห์กระดูกเชิงกรานได้ 360 องศา</p>
            </div>
          </div>
          <div class="stage-actions">
            <button id="btn-back-dashboard" class="btn-icon-text secondary">
              <i data-lucide="arrow-left"></i>
              <span>กลับหน้าหลัก</span>
            </button>
            <button id="btn-complete-stage-2" class="btn-icon-text success" disabled>
              <i data-lucide="check-circle"></i>
              <span>ส่งงานสำเร็จด่าน 2</span>
            </button>
          </div>
        </div>

        <div class="simulator-layout">
          <!-- Left: 3D Canvas Viewport -->
          <div class="canvas-panel">
            <div class="viewport-instructions">
              <i data-lucide="mouse-pointer"></i> ลากด้วยเมาส์หรือสัมผัสเพื่อหมุนมุมมอง | สกรอลล์ซูมเข้า-ออก
            </div>
            
            <div id="three-canvas-container" class="canvas-container"></div>
            
            <div class="canvas-controls glass-panel">
              <div class="slider-labels">
                <span>เริ่ม</span>
                <span>1. ENGAGE</span>
                <span>2. DESCENT</span>
                <span>3. FLEXION</span>
                <span>4. INT ROT</span>
                <span>5. EXTENSION</span>
                <span>6. EXT ROT</span>
                <span>7. EXPULSION</span>
              </div>
              <div class="custom-slider-wrapper">
                <input type="range" id="labor-slider" class="custom-slider" min="0" max="7" step="0.01" value="0">
              </div>
            </div>
          </div>

          <!-- Right: Interactive Annotations Panel -->
          <div class="explanation-panel">
            <div class="stage-desc-card glass-panel" id="stage-desc-card">
              <!-- Content updated dynamically by JS -->
            </div>
            
            <div class="anatomical-notes-card glass-panel" id="anatomical-notes-card">
              <!-- Content updated dynamically by JS -->
            </div>
          </div>
        </div>
      </div>
    `;

    if (window.lucide) {
      window.lucide.createIcons();
    }
  }

  function updateAnnotationPanel() {
    const stepIndex = Math.round(sliderValue);
    const data = MOVEMENT_STEPS[stepIndex];
    
    // Description card update
    const descCard = document.getElementById('stage-desc-card');
    if (descCard) {
      descCard.innerHTML = `
        <span class="stage-num"><i data-lucide="info" style="width: 14px; height: 14px; display: inline-block; vertical-align: middle; margin-right: 4px; color: var(--primary)"></i> ลำดับกลไกการเคลื่อนตัวที่ ${stepIndex}</span>
        <h3>${data.title}</h3>
        <p>${data.desc}</p>
      `;
    }

    // Notes list update
    const notesCard = document.getElementById('anatomical-notes-card');
    if (notesCard) {
      notesCard.innerHTML = `
        <h4><i data-lucide="activity" style="width: 16px; height: 16px; display: inline-block; vertical-align: middle; margin-right: 6px; color: var(--accent-teal)"></i> จุดสำคัญทางคลินิกและสรีรวิทยา</h4>
        <ul style="list-style: none; padding-left: 0;">
          ${data.notes.map(note => `
            <li style="margin-bottom: 0.5rem; display: flex; align-items: flex-start; gap: 0.5rem; font-weight: 700; font-size: 0.85rem;">
              <i data-lucide="check-circle-2" style="width: 14px; height: 14px; color: var(--success); flex-shrink: 0; margin-top: 3px;"></i>
              <span>${note}</span>
            </li>
          `).join('')}
        </ul>
      `;
    }

    // Ensure new icons render
    if (window.lucide) {
      window.lucide.createIcons();
    }
  }

  function initThree() {
    const canvasContainer = document.getElementById('three-canvas-container');
    if (!canvasContainer) return;

    const width = canvasContainer.clientWidth;
    const height = canvasContainer.clientHeight;

    // 1. Scene setup
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0xfffdf9); // Cute cream background
    scene.fog = new THREE.FogExp2(0xfffdf9, 0.05);

    // 2. Camera setup
    camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100);
    camera.position.set(0, 0, 10);

    // 3. Renderer setup
    renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(width, height);
    renderer.setPixelRatio(window.devicePixelRatio);
    canvasContainer.appendChild(renderer.domElement);

    // 4. Lights
    const ambientLight = new THREE.AmbientLight(0xfff5ea, 1.8); // Soft warm ambient light
    scene.add(ambientLight);

    const dirLight1 = new THREE.DirectionalLight(0xff8da1, 2.2); // Cute pastel pink light
    dirLight1.position.set(5, 10, 7);
    scene.add(dirLight1);

    const dirLight2 = new THREE.DirectionalLight(0x4ea8de, 1.8); // Cute pastel blue light
    dirLight2.position.set(-5, -5, 5);
    scene.add(dirLight2);

    const pointLight = new THREE.PointLight(0xff758f, 1.2, 10); // Warm accent point light
    pointLight.position.set(0, 0, 0);
    scene.add(pointLight);

    // 5. Models (Cute representation)
    const rotateGroup = new THREE.Group();
    scene.add(rotateGroup);

    pelvisGroup = new THREE.Group();
    
    // Pelvic Inlet Ring
    const torusGeom = new THREE.TorusGeometry(1.6, 0.18, 16, 64);
    const torusMat = new THREE.MeshStandardMaterial({
      color: 0x4ea8de, // Soft pastel blue
      wireframe: true,
      transparent: true,
      opacity: 0.3
    });
    const inletRing = new THREE.Mesh(torusGeom, torusMat);
    inletRing.rotation.x = Math.PI / 2; // Flat inlet plane
    pelvisGroup.add(inletRing);

    // Iliac Crests (Upper wings of pelvis)
    const iliacGeom = new THREE.TorusGeometry(1.5, 0.1, 12, 32, Math.PI);
    const iliacMat = new THREE.MeshStandardMaterial({
      color: 0xff758f, // Cute pink
      transparent: true,
      opacity: 0.18,
      wireframe: true
    });
    
    const leftWing = new THREE.Mesh(iliacGeom, iliacMat);
    leftWing.position.set(-1.4, 0.4, 0);
    leftWing.rotation.set(0, 0, -Math.PI / 6);
    pelvisGroup.add(leftWing);
    
    const rightWing = new THREE.Mesh(iliacGeom, iliacMat);
    rightWing.position.set(1.4, 0.4, 0);
    rightWing.rotation.set(0, 0, Math.PI + Math.PI / 6);
    pelvisGroup.add(rightWing);

    // Ischial Spines landmarks
    const spineGeom = new THREE.SphereGeometry(0.12, 8, 8);
    const spineMat = new THREE.MeshStandardMaterial({ color: 0xff4d6d }); // Soft coral-pink spines
    
    const leftSpine = new THREE.Mesh(spineGeom, spineMat);
    leftSpine.position.set(-1.1, -0.6, 0); // Ischial spine station 0
    pelvisGroup.add(leftSpine);

    const rightSpine = new THREE.Mesh(spineGeom, spineMat);
    rightSpine.position.set(1.1, -0.6, 0);
    pelvisGroup.add(rightSpine);

    rotateGroup.add(pelvisGroup);

    // Fetus Group (Baby Head & Neck/Shoulders)
    fetusGroup = new THREE.Group();

    // Stylized Head (Peach skin tone)
    const headGeom = new THREE.SphereGeometry(0.8, 32, 32);
    headGeom.scale(1.0, 1.25, 1.0); // Make it slightly elongated
    const headMat = new THREE.MeshStandardMaterial({
      color: 0xffccd5, // Pastel peach-pink
      roughness: 0.6,
      metalness: 0.05,
      transparent: true,
      opacity: 0.9
    });
    const headMesh = new THREE.Mesh(headGeom, headMat);
    fetusGroup.add(headMesh);

    // Add suture lines (Sagittal suture)
    const sutureGeom = new THREE.TorusGeometry(0.81, 0.015, 8, 64, Math.PI);
    const sutureMat = new THREE.MeshBasicMaterial({ color: 0xff758f }); // Cute pink sutures
    const sagittalSuture = new THREE.Mesh(sutureGeom, sutureMat);
    sagittalSuture.rotation.y = Math.PI / 2; // Suture goes front to back
    headMesh.add(sagittalSuture);

    // Add lambdoid sutures (Y-shape back of head)
    const lambdaGeom = new THREE.TorusGeometry(0.81, 0.015, 8, 32, Math.PI / 3);
    const lambdaLeft = new THREE.Mesh(lambdaGeom, sutureMat);
    lambdaLeft.position.set(0, -0.2, -0.4);
    lambdaLeft.rotation.set(Math.PI / 4, 0, Math.PI / 4);
    headMesh.add(lambdaLeft);

    const lambdaRight = new THREE.Mesh(lambdaGeom, sutureMat);
    lambdaRight.position.set(0, -0.2, -0.4);
    lambdaRight.rotation.set(Math.PI / 4, 0, -Math.PI / 4);
    headMesh.add(lambdaRight);

    // Neck and Torso body connection
    const bodyGeom = new THREE.CylinderGeometry(0.4, 0.5, 1.8, 16);
    const bodyMat = new THREE.MeshStandardMaterial({
      color: 0xffccd5,
      transparent: true,
      opacity: 0.35,
      wireframe: true
    });
    const bodyMesh = new THREE.Mesh(bodyGeom, bodyMat);
    bodyMesh.position.set(0, 1.2, 0); // Positioned behind/above the head
    fetusGroup.add(bodyMesh);

    // Initial positioning
    const t = getFetalTransform(sliderValue);
    fetusGroup.position.set(t.pos[0], t.pos[1], t.pos[2]);
    fetusGroup.rotation.set(t.rot[0], t.rot[1], t.rot[2]);

    rotateGroup.add(fetusGroup);

    // 6. Camera Orbit Interactions
    let isDragging = false;
    let prevMouseX = 0;
    let prevMouseY = 0;

    canvasContainer.addEventListener('pointerdown', (e) => {
      isDragging = true;
      prevMouseX = e.clientX;
      prevMouseY = e.clientY;
    });

    window.addEventListener('pointermove', (e) => {
      if (!isDragging) return;
      
      const deltaX = e.clientX - prevMouseX;
      const deltaY = e.clientY - prevMouseY;
      
      prevMouseX = e.clientX;
      prevMouseY = e.clientY;

      rotY += deltaX * 0.007;
      rotX += deltaY * 0.007;

      // Limit vertical rotation to prevent flipping upside down
      rotX = Math.max(-Math.PI / 3, Math.min(Math.PI / 3, rotX));
    });

    window.addEventListener('pointerup', () => {
      isDragging = false;
    });

    // Zoom listener via mouse wheel
    canvasContainer.addEventListener('wheel', (e) => {
      e.preventDefault();
      camera.position.z += e.deltaY * 0.005;
      camera.position.z = Math.max(5, Math.min(20, camera.position.z));
    }, { passive: false });

    // Handle Window resize
    const resizeObserver = new ResizeObserver(() => {
      if (!canvasContainer || !renderer) return;
      const w = canvasContainer.clientWidth;
      const h = canvasContainer.clientHeight;
      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
    });
    resizeObserver.observe(canvasContainer);

    // 7. Animation Loop
    function animate() {
      animationFrameId = requestAnimationFrame(animate);

      // Apply camera rotations to the rotation group
      rotateGroup.rotation.y = rotY;
      rotateGroup.rotation.x = rotX;

      renderer.render(scene, camera);
    }
    
    animate();
  }

  function handleSliderInput(value) {
    sliderValue = parseFloat(value);
    
    // Play tick sound and reward on milestone crossings
    const rounded = Math.round(sliderValue);
    if (rounded !== lastRoundedValue) {
      lastRoundedValue = rounded;
      playSynthSound('tick');
      
      const chkKey = `stage2_chk_${rounded}`;
      if (!appState[chkKey]) {
        appState[chkKey] = true;
        addRewards(15, 5, document.getElementById('stage-desc-card'));
      }
    }

    // Update Three.js model transform
    if (fetusGroup) {
      const t = getFetalTransform(sliderValue);
      fetusGroup.position.set(t.pos[0], t.pos[1], t.pos[2]);
      fetusGroup.rotation.set(t.rot[0], t.rot[1], t.rot[2]);
      
      // Animate chin flexion visually
      const body = fetusGroup.children[3]; // The cylinder mesh
      if (body) {
        body.rotation.z = (t.flex - 0.5) * 0.5;
        body.position.x = -(t.flex - 0.5) * 0.2;
      }
    }

    // Keep track of user completing the timeline check
    if (sliderValue > maxSliderViewed) {
      maxSliderViewed = sliderValue;
    }
    
    // Check if slider is fully scrubbed to unlock finish
    if (maxSliderViewed >= 6.8) {
      const btnComplete = document.getElementById('btn-complete-stage-2');
      if (btnComplete) {
        btnComplete.removeAttribute('disabled');
      }
    }

    updateAnnotationPanel();
  }

  // Initial render lifecycle
  renderHTML();
  updateAnnotationPanel();
  
  // Delay slightly to ensure layout rendering complete before measuring Canvas dimensions
  setTimeout(() => {
    initThree();
    
    // Wire up slider inputs
    const slider = document.getElementById('labor-slider');
    if (slider) {
      slider.addEventListener('input', (e) => {
        handleSliderInput(e.target.value);
      });
    }

    // Dashboard navigation back
    document.getElementById('btn-back-dashboard').addEventListener('click', () => {
      // Clean up Three animations
      if (animationFrameId) cancelAnimationFrame(animationFrameId);
      if (renderer) renderer.dispose();
      navigateTo('dashboard');
    });

    // Complete stage
    const btnComplete = document.getElementById('btn-complete-stage-2');
    if (btnComplete) {
      btnComplete.addEventListener('click', () => {
        if (animationFrameId) cancelAnimationFrame(animationFrameId);
        if (renderer) renderer.dispose();
        onComplete();
      });
    }
  }, 100);
}
