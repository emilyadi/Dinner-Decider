# What should I eat for dinner? — iOS app

A native SwiftUI port of the web app, structured for the App Store.

> **Read this first.** This project was written on Linux. Xcode only runs on
> macOS and the Swift toolchain was unreachable from that machine, so **none of
> this Swift has been compiled or run.** Expect to fix a compile error or two on
> the first build. What *has* been verified is the part most likely to be wrong
> silently: the 272-dish database was generated from `js/meals.js` rather than
> retyped, and a field-by-field diff confirms the two are identical.

## Why native rather than a web view

Wrapping the existing web app in a `WKWebView` would have been an afternoon's
work, but App Review Guideline 4.2 (Minimum Functionality) routinely rejects
apps that are a repackaged website. So the questions, the 272 dishes and the
scoring are all ported to Swift, and the UI is real SwiftUI. The app does not
load anything from the network and works fully offline.

## Opening it

```
open ios/DinnerDecider.xcodeproj
```

If it refuses to open on an older Xcode, regenerate it:

```
brew install xcodegen
cd ios && xcodegen generate
```

## Before you can build

Three things are yours to set, because they are tied to your Apple account:

1. **Signing.** Target *DinnerDecider* → Signing & Capabilities → tick
   *Automatically manage signing* and choose your Team. `DEVELOPMENT_TEAM` is
   deliberately empty in the project.
2. **Bundle identifier.** It ships as `com.example.whatshouldieatfordinner`,
   which is a placeholder and will be rejected. Change it to a reverse-DNS id on
   a domain you control.
3. **An Apple Developer Program membership** ($99/year). Without one you can run
   on your own device but cannot submit.

## Submitting

1. In App Store Connect, create the app record. The store name can be the full
   `What should I eat for dinner?`; the Home Screen label stays `Dinner`,
   because iOS truncates at roughly a dozen characters.
2. In Xcode: choose *Any iOS Device* as the destination, then
   **Product → Archive**.
3. In the Organizer: **Distribute App → App Store Connect → Upload**.
4. Back in App Store Connect, add screenshots (6.7" iPhone and 13" iPad are the
   required sizes), a description, keywords, a support URL, and a privacy
   policy URL.
5. Answer the privacy questionnaire. **This app collects nothing** — no
   analytics, no accounts, no network calls — so every answer is "No". Age
   rating is 4+.

## Layout

```
DinnerDecider/
  DinnerDeciderApp.swift     @main entry point
  Model/
    Meal.swift               the dish type and its tags
    Meals.swift              GENERATED — 272 dishes, do not hand-edit
    Questions.swift          the eight questions and their options
    Answers.swift            what the person picked
    Matcher.swift            scoring; a direct port of scoreMeal() in js/app.js
    QuizModel.swift          screen state, auto-advance, Back, Give me another
  Views/
    Theme.swift              palette and the button style
    RootView.swift           switches between the three screens
    StartView.swift          plate mark, title, Find my dinner!
    QuizView.swift           question, answer cards, progress, Back
    ResultView.swift         the dish, as a link to a Google search
  Assets.xcassets            app icon (1024, opaque) and accent colour
DinnerDeciderTests/
  MatcherTests.swift         the web suite's checks, ported to XCTest
```

## Keeping the two in step

`Meals.swift` is generated. After changing `js/meals.js`, run:

```
node scripts/gen-swift-meals.js
```

The scoring lives in two places — `js/app.js` and `Model/Matcher.swift` — with
identical weights. Change one, change the other.

## What the tests cover

`MatcherTests` walks all 15,552 answer combinations and asserts the dietary
filter holds across every one of them, that no combination is a dead end, that
the top match honours the chosen utensil and emphasis better than 95% of the
time, and that "Give me another" keeps producing new dishes. These are the same
checks the web version runs, and they are the ones that have caught real bugs.
