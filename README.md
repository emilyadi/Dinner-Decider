# Dinner Decider 🍴

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
4. How fancy are you feeling? — paper plates → pinkies up
5. Heavy on the — animal / vegetable / carbs
6. What's your appetite? — light / normal / all the food
7. What's the weather? — cold and rainy / hot and sunny / couldn't ask for better
8. Any dietary restrictions? — none / vegetarian / vegan

Every screen has **Back**, so you can change an answer without starting over.
The result screen has **Give me another** (walks down the ranked matches) and
**Restart** (erases every answer and returns to the beginning). The dish name
is a link that searches Google for it.

## How the matching works

`js/meals.js` holds 178 dishes, each tagged against all eight questions:

| field | meaning |
|-------|---------|
| `u` | utensils it's eaten with |
| `m` | messiness, 1–3 |
| `s` | spice levels it suits, 0–2 |
| `f` | fanciness levels it fits, 1–4 |
| `h` | protein / veg / carbs forward |
| `a` | appetite sizes, 1–3 |
| `w` | weather it suits |
| `d` | `omni`, `veg` or `vegan` |

`scoreMeal()` in `js/app.js` scores every dish against your answers. Utensil
and "heavy on the" carry the most weight; messiness, spice, fanciness,
appetite and weather score by how far the dish sits from what you asked for,
so there's always a sensible answer even for unusual combinations. Exact ties
are shuffled, so the same answers can surface different dishes.

**Dietary answers are a hard filter, not a preference.** Choosing vegetarian
removes every dish containing meat or fish; choosing vegan removes anything
with animal products at all. This is enforced before scoring, so no amount of
tapping "Give me another" can surface a dish that breaks it.

The weather answer works as the brief intended: cold and rainy leans into
stews, pot pies and braises; hot and sunny keeps things light and grilled;
"couldn't ask for better" avoids the heaviest dishes.

## Files

```
index.html              markup for all three screens
css/styles.css          layout, palette, portrait + landscape rules
js/meals.js             the 178-dish database
js/app.js               quiz flow, scoring, result rendering
sw.js                   offline cache
manifest.webmanifest    home-screen app metadata
icons/                  app icon (SVG + PNGs for iOS)
```

## Palette

`#FF7F50` coral · `#FFD166` sun · `#06D6A0` mint · `#118AB2` sea
