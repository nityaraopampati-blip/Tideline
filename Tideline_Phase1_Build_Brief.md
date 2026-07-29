# Tideline — Phase 1 Build Brief (for Claude Code)

## Read this first, Claude Code

You are building **Tideline**, an iPhone app that helps people reduce plastic use by scanning
products and showing recyclability, alternatives, and environmental impact. This document is
the full spec for **Phase 1 only**. Games, events, and challenges are described at the bottom
under "Out of scope" — do not build them yet.

The person you're building this for is an 8th grader who is not a programmer. She will run you
(Claude Code) from Terminal and read your progress updates, but she cannot debug code herself.
That means:

- Explain what you're doing in plain English as you go, not just code output.
- If something is ambiguous or you have to make a judgment call, ask her directly instead of
  guessing silently, unless it's a minor implementation detail.
- After every milestone, tell her exactly how to see/test it (e.g., "run the app in the iOS
  Simulator and tap Scan").
- Keep the project buildable and runnable at every step — never leave it in a broken state
  between sessions.
- Commit to git after each working milestone with a clear message, so there's always a working
  save point to go back to.

Also keep this in mind for the app's tone: Tideline should feel encouraging, not preachy. After
a user completes something — a scan, the baseline quiz, anything — show a small warm
acknowledgment (e.g. "Nice work checking that before tossing it!" or "Quiz done — thanks for
learning with Tideline!") rather than just silently moving on. This matters more once points,
badges, and challenges exist in later phases, but start the habit now with simple, genuine
micro-copy after each completed action.

## 1. What Phase 1 delivers

A real, installable iPhone app where a user can:

1. Create an account and log in.
2. Right after their first sign-in, take a short baseline "how much do you know about plastic"
   quiz (10 questions, provided — see Section 4). Score is saved so a later Phase can show the
   user how much they've learned.
3. Scan a product's barcode, take a photo of an item, or type in a product name.
4. See a results screen with: recyclability, reusable alternative(s), where to get the
   alternative, plastic footprint, microplastic risk, decomposition time, environmental impact,
   and the best action to take — plus a short practical tip.
5. Look back at their past scans (a simple history list).

That's it for Phase 1. No games, no events, no badges yet. The follow-up quiz (retaking it later
and comparing scores) is part of the Phase 3 impact dashboard, not this phase — just make sure
the baseline score is saved somewhere Phase 3 can read it later.

## 2. Tech stack (and why)

| Piece | Choice | Why |
|---|---|---|
| Platform | iOS, Swift + SwiftUI | Native iPhone app, modern Apple-recommended approach |
| Minimum iOS version (app-wide) | iOS 17 | Keeps the app installable on most iPhones people actually own — do NOT raise this app-wide just for Foundation Models |
| Barcode scanning | Apple's built-in VisionKit / AVFoundation barcode scanner | Free, built into iOS, no extra account needed |
| Barcode → product lookup | Open Food Facts API first, then Open Beauty Facts and Open Products Facts (all free, no key required, same family of databases) | Open Food Facts mainly covers food/drink. Beauty Facts covers personal care (shampoo, razors, toothbrushes); Products Facts covers general household goods — together they cover far more of Tideline's target items |
| Photo → item recognition | Apple's **Foundation Models framework** (on-device AI, with automatic fallback to Apple's private cloud) | Free per request — no API key, no billing, no per-scan cost. Runs on-device when possible, otherwise Apple's free cloud fallback |
| Environmental info content | Local seed data file (`PlasticItems.json`, provided — see Section 4) first; Foundation Models as a fallback for items not in the list, clearly labeled "AI estimate" | Guarantees accurate, reviewed info for common items; still covers everything else, at no cost |
| Accounts & saved data | Apple **CloudKit** + Sign in with Apple | Free, native to iOS, no separate account/console needed beyond her own Apple ID — simpler than a third-party backend since the app already targets Apple hardware |
| Version control | Git, pushed to her GitHub repository | Keeps a full history and backup of the project |

### Important hardware limitation

The Foundation Models framework requires iOS 26 and **iPhone 15 Pro or newer** (Apple's A17 Pro
chip or later) — but that requirement applies only to the photo-recognition feature, not the
whole app. The app itself should keep a lower deployment target (iOS 17) so it still installs
and works (barcode scan + search) on older/other iPhones. On a device that doesn't meet the
Foundation Models requirement, that feature is simply unavailable — there is no paid fallback
to a cloud AI provider, by design, to keep this app free to run.

Detect capability at runtime (`SystemLanguageModel.default.availability` or equivalent) and
handle older devices gracefully:

- Barcode scanning and the verified `PlasticItems.json` database must work on **any** iPhone.
- The "Take Photo" scan option should only appear (or should explain itself and gracefully
  decline) on devices that support Foundation Models. Show a friendly message like "Photo
  scanning needs an iPhone 15 Pro or newer — try Barcode or Search instead" rather than
  crashing or silently failing.

## 3. Accounts she needs to set up (tell her, don't skip this)

No separate third-party account is needed for Phase 1. Accounts and saved data run on Apple
CloudKit, tied to her own Apple ID — set up by enabling the "iCloud" and "Sign in with Apple"
capabilities in the Xcode project (under Signing & Capabilities), using her Apple ID as the
developer signed into Xcode. No console signup, no separate API key, no per-scan billing to
manage.

If CloudKit isn't configured yet in a given session, build the surrounding feature anyway using
placeholder/mock responses so the app still runs, and clearly mark in your update to her which
features need the real CloudKit capabilities enabled before they'll fully work.

## 4. Seed content data

A starter spreadsheet, `Tideline_Plastic_Items_Database.xlsx`, is provided in this same folder
with two tabs:

- **"Plastic Items"** — 20 common plastic items (water bottle, straw, grocery bag, utensils,
  etc.), each with all the info fields listed in Section 1. Convert this into a
  `PlasticItems.json` file bundled with the app, and use it as the primary source of truth for
  matching scanned/searched items. Match loosely (e.g. "plastic drinking straw" and "straw"
  should both match the "Plastic straw" entry).
- **"Quiz Questions"** — 10 fact-checked multiple-choice/true-false questions with answers and
  explanations. Convert this into a `QuizQuestions.json` bundled with the app and use it for the
  baseline quiz described in Section 1. Show the explanation after the user answers each
  question, right or wrong, so it's educational either way.

## 5. Screens & flow

1. **Welcome / Sign in** — "Sign in with Apple" (one tap, backed by CloudKit).
2. **Baseline quiz screen** — shown once, right after first sign-in. 10 questions from
   `QuizQuestions.json`, one at a time, showing the explanation after each answer. Save the final
   score. Let the user skip it if they really want to, but encourage completing it.
3. **Home** — three clear options: Scan Barcode, Take Photo, Search by Name. Also shows recent
   scan history.
4. **Scanning screen** — camera view for barcode or photo, with a loading state while it
   identifies the product.
5. **Search screen** — text field with basic search-as-you-type against `PlasticItems.json`.
6. **Result screen** — shows the product name and all info fields from Section 1 in a clean,
   readable layout. Include a "source" note at the bottom: either "From Tideline's verified
   database" or "AI-generated estimate" depending on where the info came from.
7. **History screen** — list of past scans, tappable to revisit the result screen.
8. **Profile screen** — shows account name/ID, baseline quiz score, a log out button. (Points/
   badges come in Phase 2 — just leave a placeholder here for now.)

## 6. Data model (suggested)

```
PlasticItem {
  name: String
  materialCode: String        // e.g. "PET (#1)"
  recyclability: String
  alternatives: String
  whereToGetAlternative: String
  plasticFootprint: String
  microplasticRisk: String
  decompositionTime: String
  environmentalImpact: String
  bestAction: String
  practicalTip: String
  source: String               // "database" or "on-device-ai-estimate"
}

ScanHistoryEntry {
  id: String
  itemName: String
  timestamp: Date
  scanMethod: String           // "barcode", "photo", or "search"
}

UserProfile {
  id: String                   // Apple ID user identifier
  displayName: String?         // Apple only shares this on first sign-in; store it then
  createdAt: Date
}

QuizResult {
  id: String
  type: String                 // "baseline" for Phase 1; "followup" is added in Phase 3
  score: Int
  totalQuestions: Int
  takenAt: Date
}
```

## 7. What "done" looks like for Phase 1

- The app builds and runs in the iOS Simulator with no errors.
- A user can sign up, log in, and stay logged in between app launches.
- All three scan methods (barcode, photo, search) successfully return a result screen for at
  least the 20 seeded items.
- If a scanned/photographed item isn't recognized at all, the app shows a friendly message
  instead of crashing, and lets the user type in what it was.
- On an iPhone that doesn't support Foundation Models, barcode scanning and search still work
  fully, and the photo-scan option fails gracefully with a clear explanation instead of crashing.
- The baseline quiz runs once after first sign-in, shows an explanation after each answer, and
  saves the final score to the user's profile.
- Scan history is saved and viewable.
- Completing a scan or the quiz shows a brief, genuine "thanks/nice work" acknowledgment.
- Write basic tests for the product-matching logic (does "water bottle" correctly match the
  seeded "Plastic water bottle" entry, etc.).
- No secrets/keys are committed to git.
- Code is committed to git with clear messages at each milestone.

## 8. Out of scope for Phase 1 (do not build yet)

- Games: True or False, Sort the Plastic, Recycle Runner, and Plastic-Go. Note for later: when
  Plastic-Go gets its own brief, build it first as a simple photo-log ("log/photograph plastic
  items you spot while out and about") rather than a full Pokémon-Go-style real-time map game —
  the full map version is a much bigger build and should be a stretch goal after the simple
  version works.
- Events (creating/inviting via WhatsApp, iMessage, Instagram)
- Challenges, badges, and points
- Overall environmental impact dashboard, including the follow-up quiz (retaking the baseline
  quiz later and showing improvement)

These will each get their own build brief once Phase 1 is working and tested.

## 9. First message to send Claude Code

When she opens Claude Code in this project folder for the first time, she can say:

> "Read Tideline_Phase1_Build_Brief.md and Tideline_Plastic_Items_Database.xlsx in this folder.
> Set up the iOS project and build Phase 1 as described. Ask me any questions before you start
> if anything is unclear, and explain each step in plain English since I'm not a programmer."
