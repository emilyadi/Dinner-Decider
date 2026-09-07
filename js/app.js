/* ============================================================
   Dinner Decider — quiz flow + meal matcher
   ============================================================ */
(function () {
  'use strict';

  /* ─────────────  the eight questions  ───────────── */
  const QUESTIONS = [
    {
      key: 'utensil',
      text: 'Pretend you&rsquo;re eating. What utensil are you using?',
      options: [
        { v: 'hand',  e: '🙌', label: 'Hands' },
        { v: 'fork',  e: '🍴', label: 'Fork' },
        { v: 'spoon', e: '🥄', label: 'Spoon' },
        { v: 'chop',  e: '🥢', label: 'Chopsticks' }
      ]
    },
    {
      key: 'mess',
      text: 'How messy do you want to be?',
      options: [
        { v: 1, e: '✨', label: 'Neat. I&rsquo;ve got places to be' },
        { v: 2, e: '🧻', label: 'Medium &mdash; I&rsquo;ve got a napkin' },
        { v: 3, e: '🫧', label: 'Messy &mdash; washing machines exist for a reason' }
      ]
    },
    {
      key: 'spice',
      text: 'How much spice are you in the mood for?',
      options: [
        { v: 0, e: '🍼', label: 'Zero &mdash; toddler level' },
        { v: 1, e: '🌶️', label: 'Taco Bell Fire Sauce is my jam' },
        { v: 2, e: '🔥', label: 'I&rsquo;m from Arrakis &mdash; give me all spice' }
      ]
    },
    {
      key: 'fancy',
      text: 'How fancy are you feeling?',
      options: [
        { v: 1, e: '🧻', label: 'Paper plates and plastic forks' },
        { v: 2, e: '🛋️', label: 'A typical night in' },
        { v: 3, e: '🍽️', label: 'Non-plastic silverware' },
        { v: 4, e: '🥂', label: 'Pinkies up!' }
      ]
    },
    {
      key: 'heavy',
      text: 'Heavy on the:',
      options: [
        { v: 'protein', e: '🥩', label: 'Animal' },
        { v: 'veg',     e: '🥦', label: 'Vegetable' },
        { v: 'carbs',   e: '🍞', label: 'Carbs' }
      ]
    },
    {
      key: 'appetite',
      text: 'What&rsquo;s your appetite?',
      options: [
        { v: 1, e: '🥗', label: 'Something light' },
        { v: 2, e: '🙂', label: 'I could eat' },
        { v: 3, e: '🍖', label: 'GIVE ME ALL THE FOOD' }
      ]
    },
    {
      key: 'weather',
      text: 'What&rsquo;s the weather?',
      options: [
        { v: 'cold', e: '🌧️', label: 'Cold and rainy' },
        { v: 'hot',  e: '☀️', label: 'Hot and sunny' },
        { v: 'mild', e: '🌤️', label: 'Couldn&rsquo;t ask for better!' }
      ]
    },
    {
      key: 'diet',
      text: 'Any dietary restrictions?',
      options: [
        { v: 'none',  e: '🍗', label: 'Nope, anything goes' },
        { v: 'veg',   e: '🥕', label: 'Vegetarian' },
        { v: 'vegan', e: '🌱', label: 'Vegan' }
      ]
    }
  ];

  /* ─────────────  chip labels for the result card  ───────────── */
  const CHIPS = {
    utensil:  { hand: '🙌 Hands-on', fork: '🍴 Fork food', spoon: '🥄 Spoon food', chop: '🥢 Chopsticks' },
    mess:     { 1: '✨ Tidy', 2: '🧻 A napkin will do', 3: '🫧 Gloriously messy' },
    spice:    { 0: '🍼 No heat', 1: '🌶️ Nicely spiced', 2: '🔥 Properly hot' },
    fancy:    { 1: '🧻 Paper plates', 2: '🛋️ Night in', 3: '🍽️ Real silverware', 4: '🥂 Pinkies up' },
    heavy:    { protein: '🥩 Protein-forward', veg: '🥦 Veg-forward', carbs: '🍞 Carb-forward' },
    appetite: { 1: '🥗 Light', 2: '🙂 Just right', 3: '🍖 All the food' },
    weather:  { cold: '🌧️ Cold-weather food', hot: '☀️ Warm-weather food', mild: '🌤️ Any-weather food' },
    diet:     { veg: '🥕 Vegetarian', vegan: '🌱 Vegan' }
  };

  /* ─────────────  state  ───────────── */
  const answers = {};
  let current = 0;        // index into QUESTIONS
  let ranked = [];        // scored meal list for the current run
  let pick = 0;           // index into `ranked`

  /* ─────────────  dom  ───────────── */
  const $ = (id) => document.getElementById(id);
  const screens = {
    start:  $('screen-start'),
    quiz:   $('screen-quiz'),
    result: $('screen-result')
  };
  const optionsEl  = $('options');
  const questionEl = $('question-text');
  const stepEl     = $('quiz-step');
  const fillEl     = $('progress-fill');
  const backBtn    = $('btn-back');
  const nextBtn    = $('btn-next');

  /* ─────────────  screen switching  ───────────── */
  function show(name) {
    Object.keys(screens).forEach((k) => {
      screens[k].classList.toggle('is-active', k === name);
      screens[k].classList.remove('is-entering');
    });
    // restart the entry animation
    void screens[name].offsetWidth;
    screens[name].classList.add('is-entering');
  }

  /* ─────────────  render a question  ───────────── */
  function renderQuestion() {
    const q = QUESTIONS[current];

    questionEl.innerHTML = q.text;
    stepEl.textContent = 'Question ' + (current + 1) + ' of ' + QUESTIONS.length;
    fillEl.style.width = ((current + 1) / QUESTIONS.length * 100) + '%';
    fillEl.parentElement.setAttribute('aria-valuenow', String(current + 1));

    optionsEl.innerHTML = '';
    optionsEl.setAttribute('data-count', String(q.options.length));

    q.options.forEach((opt) => {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'option';
      btn.setAttribute('role', 'radio');
      const chosen = answers[q.key] === opt.v;
      btn.setAttribute('aria-checked', chosen ? 'true' : 'false');
      if (chosen) btn.classList.add('is-selected');

      btn.innerHTML =
        '<span class="option__emoji" aria-hidden="true">' + opt.e + '</span>' +
        '<span class="option__label">' + opt.label + '</span>' +
        '<span class="option__check" aria-hidden="true">✓</span>';

      btn.addEventListener('click', function () {
        answers[q.key] = opt.v;
        Array.prototype.forEach.call(optionsEl.children, function (child) {
          child.classList.remove('is-selected');
          child.setAttribute('aria-checked', 'false');
        });
        btn.classList.add('is-selected');
        btn.setAttribute('aria-checked', 'true');
        nextBtn.disabled = false;
      });

      optionsEl.appendChild(btn);
    });

    nextBtn.disabled = answers[q.key] === undefined;
    nextBtn.innerHTML = (current === QUESTIONS.length - 1)
      ? 'Feed me <span aria-hidden="true">→</span>'
      : 'Next <span aria-hidden="true">→</span>';
  }

  /* ─────────────  the matcher  ───────────── */

  // distance from a value to the nearest entry in a list of levels
  function nearest(levels, value) {
    let best = Infinity;
    for (let i = 0; i < levels.length; i++) {
      const d = Math.abs(levels[i] - value);
      if (d < best) best = d;
    }
    return best;
  }

  function scoreMeal(meal, a) {
    let score = 0;
    const matched = [];

    // utensil — the strongest single signal
    if (meal.u.indexOf(a.utensil) !== -1) { score += 30; matched.push(CHIPS.utensil[a.utensil]); }

    // heavy on
    if (meal.h.indexOf(a.heavy) !== -1) { score += 26; matched.push(CHIPS.heavy[a.heavy]); }

    // an "animal" answer with no dietary restriction prefers actual meat/fish
    if (a.heavy === 'protein' && a.diet === 'none' && meal.d === 'omni') score += 6;

    // messiness
    const messGap = Math.abs(meal.m - a.mess);
    score += Math.max(0, 22 - 11 * messGap);
    if (messGap === 0) matched.push(CHIPS.mess[a.mess]);

    // spice
    const spiceGap = nearest(meal.s, a.spice);
    score += Math.max(0, 20 - 12 * spiceGap);
    if (spiceGap === 0) matched.push(CHIPS.spice[a.spice]);

    // fanciness
    const fancyGap = nearest(meal.f, a.fancy);
    score += Math.max(0, 18 - 8 * fancyGap);
    if (fancyGap === 0) matched.push(CHIPS.fancy[a.fancy]);

    // appetite
    const appGap = nearest(meal.a, a.appetite);
    score += Math.max(0, 16 - 9 * appGap);
    if (appGap === 0) matched.push(CHIPS.appetite[a.appetite]);

    // weather
    if (meal.w.indexOf(a.weather) !== -1) {
      score += 14;
      matched.push(CHIPS.weather[a.weather]);
    } else if (meal.w.indexOf('mild') !== -1 || a.weather === 'mild') {
      score += 5;
    }

    return { meal: meal, score: score, matched: matched };
  }

  function buildRanking() {
    const a = answers;

    // dietary answers are a hard filter, never a preference
    const eligible = MEALS.filter(function (meal) {
      if (a.diet === 'vegan') return meal.d === 'vegan';
      if (a.diet === 'veg')   return meal.d === 'vegan' || meal.d === 'veg';
      return true;
    });

    const scored = eligible.map(function (meal) {
      const r = scoreMeal(meal, a);
      r.jitter = Math.random();          // shuffles ties, fresh each run
      return r;
    });

    scored.sort(function (x, y) {
      return (y.score - x.score) || (y.jitter - x.jitter);
    });

    ranked = scored;
    pick = 0;
  }

  /* ─────────────  render the result  ───────────── */
  function renderResult() {
    if (!ranked.length) return;
    const entry = ranked[pick % ranked.length];
    const meal = entry.meal;

    $('result-emoji').textContent = meal.e;
    $('result-name-text').textContent = meal.n;
    $('result-name').href = 'https://www.google.com/search?q=' + encodeURIComponent(meal.n);
    $('result-origin').textContent = meal.o;
    $('result-blurb').textContent = meal.b;

    const chips = entry.matched.slice(0, 5);
    if (answers.diet === 'veg' || answers.diet === 'vegan') chips.push(CHIPS.diet[answers.diet]);

    const tagList = $('result-tags');
    tagList.innerHTML = '';
    chips.forEach(function (c) {
      if (!c) return;
      const li = document.createElement('li');
      li.textContent = c;
      tagList.appendChild(li);
    });

    const card = $('result-card');
    card.classList.remove('is-swapping');
    void card.offsetWidth;
    card.classList.add('is-swapping');
  }

  /* ─────────────  navigation  ───────────── */
  function goNext() {
    if (answers[QUESTIONS[current].key] === undefined) return;
    if (current < QUESTIONS.length - 1) {
      current++;
      renderQuestion();
    } else {
      buildRanking();
      renderResult();
      show('result');
    }
  }

  function goBack() {
    if (current === 0) {
      show('start');
      return;
    }
    current--;
    renderQuestion();
  }

  function restart() {
    Object.keys(answers).forEach(function (k) { delete answers[k]; });
    current = 0;
    ranked = [];
    pick = 0;
    renderQuestion();
    show('start');
  }

  /* ─────────────  wiring  ───────────── */
  $('btn-start').addEventListener('click', function () {
    renderQuestion();
    show('quiz');
  });
  nextBtn.addEventListener('click', goNext);
  backBtn.addEventListener('click', goBack);
  $('btn-restart').addEventListener('click', restart);
  $('btn-another').addEventListener('click', function () {
    pick++;
    renderResult();
  });

  // keep iOS from bouncing / zooming the whole app around
  document.addEventListener('gesturestart', function (e) { e.preventDefault(); });
  document.addEventListener('touchmove', function (e) {
    if (e.touches.length > 1) e.preventDefault();
  }, { passive: false });

  renderQuestion();

  // offline support once the app is added to the Home Screen
  if ('serviceWorker' in navigator && location.protocol.indexOf('http') === 0) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('sw.js').catch(function () { /* not fatal */ });
    });
  }

  // exposed so the test harness can drive the matcher directly
  window.DinnerDecider = {
    QUESTIONS: QUESTIONS,
    scoreMeal: scoreMeal,
    get answers() { return answers; },
    get ranked() { return ranked; }
  };
})();
