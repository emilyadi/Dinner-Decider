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
        { v: 'hand',  label: 'Hands' },
        { v: 'fork',  label: 'Fork' },
        { v: 'spoon', label: 'Spoon' },
        { v: 'chop',  label: 'Chopsticks' }
      ]
    },
    {
      key: 'mess',
      text: 'How messy do you want to be?',
      options: [
        { v: 1, label: 'Not at all.' },
        { v: 2, label: 'Medium' },
        { v: 3, label: 'Messy' }
      ]
    },
    {
      key: 'spice',
      text: 'How much spice are you in the mood for?',
      options: [
        { v: 0, label: 'Zero-toddler level.' },
        { v: 1, label: 'Medium' },
        { v: 2, label: 'Hot like the sun.' }
      ]
    },
    {
      key: 'fancy',
      text: 'How fancy are you feeling?',
      options: [
        { v: 1, label: 'Not at all' },
        { v: 2, label: 'A little fancy' },
        { v: 3, label: 'Very fancy&mdash;pinkies up!' }
      ]
    },
    {
      key: 'heavy',
      text: 'Heavy on the:',
      options: [
        { v: 'protein', label: 'Animal' },
        { v: 'veg',     label: 'Vegetable' },
        { v: 'carbs',   label: 'Carbs' }
      ]
    },
    {
      key: 'appetite',
      text: 'What&rsquo;s your appetite?',
      options: [
        { v: 1, label: 'Not very hungry' },
        { v: 2, label: 'I could eat' },
        { v: 3, label: 'GIVE ME ALL THE FOOD.' }
      ]
    },
    {
      key: 'weather',
      text: 'What&rsquo;s the weather?',
      options: [
        { v: 'cold', label: 'Cold and rainy' },
        { v: 'hot',  label: 'Hot and sunny' },
        { v: 'mild', label: 'It&rsquo;s a beautiful day' }
      ]
    },
    {
      key: 'diet',
      text: 'Any dietary restrictions?',
      options: [
        { v: 'none',  label: 'Nope&mdash;anything goes' },
        { v: 'veg',   label: 'Vegetarian' },
        { v: 'vegan', label: 'Vegan' }
      ]
    }
  ];

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

  // blocks the double-tap that would otherwise skip a question
  let advancing = false;

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
        '<span class="option__label">' + opt.label + '</span>' +
        '<span class="option__check" aria-hidden="true">✓</span>';

      btn.addEventListener('click', function () {
        if (advancing) return;
        answers[q.key] = opt.v;
        Array.prototype.forEach.call(optionsEl.children, function (child) {
          child.classList.remove('is-selected');
          child.setAttribute('aria-checked', 'false');
        });
        btn.classList.add('is-selected');
        btn.setAttribute('aria-checked', 'true');

        // let the choice register visibly, then move on by itself
        advancing = true;
        setTimeout(function () {
          advancing = false;
          goNext();
        }, 260);
      });

      optionsEl.appendChild(btn);
    });

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

    // utensil — the strongest single signal
    if (meal.u.indexOf(a.utensil) !== -1) score += 30;

    // heavy on
    if (meal.h.indexOf(a.heavy) !== -1) score += 26;

    // an "animal" answer with no dietary restriction prefers actual meat/fish
    if (a.heavy === 'protein' && a.diet === 'none' && meal.d === 'omni') score += 6;

    // the ordinal traits score by how far the dish sits from what was asked for
    score += Math.max(0, 22 - 11 * Math.abs(meal.m - a.mess));
    score += Math.max(0, 20 - 12 * nearest(meal.s, a.spice));
    score += Math.max(0, 18 - 8 * nearest(meal.f, a.fancy));
    score += Math.max(0, 16 - 9 * nearest(meal.a, a.appetite));

    // weather
    if (meal.w.indexOf(a.weather) !== -1) score += 14;
    else if (meal.w.indexOf('mild') !== -1 || a.weather === 'mild') score += 5;

    return { meal: meal, score: score };
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

    $('result-name-text').textContent = meal.n;
    $('result-name').href = 'https://www.google.com/search?q=' + encodeURIComponent(meal.n);

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
    if (advancing) return;
    if (current === 0) {
      show('start');
      return;
    }
    current--;
    renderQuestion();
  }

  function restart() {
    Object.keys(answers).forEach(function (k) { delete answers[k]; });
    advancing = false;
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
