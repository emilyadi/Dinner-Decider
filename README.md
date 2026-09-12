# What should I eat for dinner? 🍴

An iPad app that ends the "I don't know, what do *you* want?" conversation.
Answer eight questions, get one dish that matches every answer — drawn from
what people actually eat in the United States, plus popular dishes from Asia,
Europe, Africa, the Middle East and Latin America.

## Getting it on the iPad

It's a self-contained web app — no App Store, no build step, no dependencies.

1. Serve the folder over HTTP, e.g. `npx http-server -p 8123` (or push it to
   GitHub Pages / any static host).
2. Open the URL in **Safari on the iPad**.
3. Tap **Share → Add to Home Screen**.

It then launches full-screen from its own icon, with no browser chrome, and
works offline thanks to `sw.js`. It supports both portrait and landscape.

To try it on a computer, just open the same URL in any browser.

## The questions

1. What utensil are you using? — hands / fork / spoon / chopsticks
2. How messy do you want to be? — neat / medium / messy
3. How much spice? — zero / medium / Arrakis
4. How fancy are you feeling? — I like toddler food / more than a hot dog, less than caviar / very fancy
5. Heavy on the — animal / vegetable / carbs
6. What's your appetite? — light / normal / all the food
7. What's the weather? — cold and rainy / it's a beautiful day / hot and sunny
8. Any dietary restrictions? — none / vegetarian / vegan

Choosing an answer moves straight to the next question — there is no Next
button. Every screen has **Back**, so you can change an answer without
starting over.
The result screen has **Give me another** (walks down the ranked matches) and
**Restart** (erases every answer and returns to the beginning). The result
screen is deliberately minimal: "Tonight, you should eat", the dish name as a
link that searches Google for it, and those two buttons.

## How the matching works

`js/meals.js` holds 272 dishes, each tagged against all eight questions:

| field | meaning |
|-------|---------|
| `u` | utensils it's eaten with |
| `m` | messiness, 1–3 |
| `s` | spice levels it suits, 0–2 |
| `f` | fanciness levels it fits, 1–3 |
| `h` | protein / veg / carbs forward |
| `a` | appetite sizes, 1–3 |
| `w` | weather it suits |
| `d` | `omni`, `veg` or `vegan` |
| `k` | present when the dish is plain, familiar American home cooking |

Each dish also carries an emoji (`e`), an origin (`o`) and a one-line blurb
(`b`). The result screen deliberately shows none of them — just the dish name
— but they're kept in the data if you ever want to surface them again.

The list includes signature and most-popular main courses from Allrecipes
(Marry Me Chicken, beef stroganoff, baked ziti, zuppa toscana, chicken and
dumplings, General Tso's, salisbury steak and more) and from NYT Cooking
(buttermilk-brined roast chicken, bo ssam, the spiced chickpea stew,
caramelized shallot pasta, chicken marbella, red lentil soup, gochujang
buttered noodles and more), and from Smitten Kitchen (pizza beans, zucchini
butter spaghetti, sheet-pan chicken tikka, broccoli melts, the squash and
caramelized onion galette, chicken with forty cloves of garlic, mushroom
bourguignon and more). Desserts are excluded.

Alongside those it carries the everyday American standards people actually
recognise — hot dogs, a BLT, a Reuben, a patty melt, hard-shell tacos, a
burrito bowl, pepperoni pizza, chicken tenders, orange chicken, lo mein,
fried rice, brisket, crab cakes, red beans and rice, stuffed shells, a
loaded baked potato and a chef salad among them.

`scoreMeal()` in `js/app.js` scores every dish against your answers. Utensil
and "heavy on the" carry the most weight; messiness, spice, fanciness,
appetite and weather score by how far the dish sits from what you asked for,
so there's always a sensible answer even for unusual combinations. Exact ties
are shuffled, so the same answers can surface different dishes.

**Dietary answers are a hard filter, not a preference.** Choosing vegetarian
removes every dish containing meat or fish; choosing vegan removes anything
with animal products at all. This is enforced before scoring, so no amount of
tapping "Give me another" can surface a dish that breaks it.

**"I like toddler food" does more than set the fancy level.** Fancy level 1 on
its own is a poor proxy for plain food — a crab boil and a crumbed cutlet are
both level 1 — so 63 dishes carry a separate `k` flag marking them as plain,
familiar American home cooking, and choosing that answer adds 28 points to
them. Where such a dish exists for the chosen utensil and diet, it wins 87% of
the time; where none exists (chopsticks, or some vegan combinations) the
utensil still governs, which is the right trade.

The weather answer works as the brief intended: cold and rainy leans into
stews, pot pies and braises; hot and sunny keeps things light and grilled;
"couldn't ask for better" avoids the heaviest dishes.

## The iOS app

`ios/` holds a native SwiftUI port of this app, structured for the App Store,
with its own README covering signing and submission. The dish database there is
generated from `js/meals.js` by `scripts/gen-swift-meals.js` — regenerate it
after changing the dishes.

## Files

```
index.html              markup for all three screens
css/styles.css          layout, palette, portrait + landscape rules
js/meals.js             the 272-dish database
js/app.js               quiz flow, scoring, result rendering
sw.js                   offline cache
manifest.webmanifest    home-screen app metadata
icons/                  app icon (SVG + PNGs for iOS)
```

## Palette

`#06D6A0` green is the app's solid background on every screen. `#FF7F50`
coral is the action colour (Find my dinner, Give me another, the selected
answer, the progress bar). `#FFD166` sun rings the plate mark, badges the
question counter, caps the result card and fills the Back and Restart
buttons. `#A63A12` deep coral sets the chosen dish.

The blue that was originally in the palette is gone — it never sat well
against the green and yellow, and at 3.96:1 on white it was the weakest
text colour in the app. The deep coral that replaced it reads at 6.49:1.
The neutrals were re-biased at the same time: they were blue-slate, which
looked like a leftover once the blue itself was removed.

Nothing is written in white or yellow directly on the green — at 1.9:1 and
1.3:1 those are unreadable. Text on the green uses `#073B32`, a darkened
form of the ground itself, at 6.6:1.
