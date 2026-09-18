import type { Dictionary } from "./fr";

/** English translation. The `Dictionary` type guarantees full coverage. */
export const en: Dictionary = {
  code: "en",
  htmlLang: "en",
  documentTitle: "WC Connect — track your breaks, on iPhone and Apple Watch",
  switchLabel: "Switch the site to French",
  switchTo: "FR",

  nav: {
    label: "Main navigation",
    skip: "Skip to content",
    cta: "Availability",
    links: [
      { href: "#fonctions", label: "Features" },
      { href: "#aide", label: "Help" },
      { href: "#detente", label: "Unwind" },
      { href: "#live", label: "Live Activity" },
      { href: "#watch", label: "Watch" },
      { href: "#suivi", label: "Tracking" },
      { href: "#palmares", label: "Trophies" },
      { href: "#meteo", label: "Forecast" },
      { href: "#faq", label: "FAQ" },
    ],
  },

  hero: {
    eyebrow: "iPhone · Apple Watch · Live Activity",
    titleLine1: "Every break",
    titleLine2: "really counts.",
    lead: "WC Connect times your bathroom visits in a single tap, shows the elapsed time on the Lock Screen and in the Dynamic Island, and lets you run everything from your wrist. No account, no server, no judgement.",
    primary: "See what it does",
    secondary: "See the Live Activity",
    facts: [
      { value: "1 tap", label: "to get started" },
      { value: "0 data", label: "sent anywhere" },
      { value: "2 devices", label: "kept in sync" },
    ],
    phoneAlt: "iPhone Lock Screen showing the WC Connect Live Activity",
    watchAlt: "Apple Watch showing the WC Connect timer",
    activityLabel: "Visit in progress",
    activityMeta: "Standard · Home",
    lockTime: "9:41",
    lockDate: "Wednesday 18 March",
    watchPlace: "Home",
    watchButton: "Finish",
  },

  features: {
    title: "Everything you need, nothing else",
    lead: "An app you open, use and close in under three seconds.",
    cards: [
      {
        title: "One-tap timer",
        description: "One button, one progress ring, and you're off. Visit type and place are remembered from one time to the next.",
      },
      {
        title: "Live Activity",
        description: "The elapsed time stays visible on the Lock Screen and in the Dynamic Island, with a “Finish” button right inside it.",
      },
      {
        title: "Apple Watch",
        description: "A native app on your wrist: start, finish, browse history and stats, with haptic feedback.",
      },
      {
        title: "Widgets & complications",
        description: "Today's visits on the Home Screen, the timer on the Lock Screen and on your watch face.",
      },
      {
        title: "When it won't come",
        description: "After a few minutes the app suggests concrete moves — posture, feet raised, never holding your breath to push — and says when you should see a doctor instead.",
      },
      {
        title: "Guided breathing",
        description: "Three animated rhythms, one of them hold-free and meant for the throne, with haptics on your wrist so you can keep your eyes closed.",
      },
      {
        title: "Soundscapes & music",
        description: "Four built-in loops that layer over your music instead of interrupting it, plus playback controls for your own library inside the app.",
      },
      {
        title: "Clear statistics",
        description: "Average duration, favourite time slot, home / work / out split, running streak and seven-day charts.",
      },
      {
        title: "Siri & shortcuts",
        description: "“Hey Siri, I'm going to the bathroom.” The timer starts, even on the Lock Screen, without opening the app.",
      },
    ],
  },

  help: {
    eyebrow: "When it won't come",
    title: "Concrete moves, right when things stall",
    body: "After a few minutes — before the five-minute mark at which you're better off standing up — the app offers three moves you can do sitting down, the guided breathing and a soundscape. One tap hides the card if you'd rather not.",
    cardAlt: "Advice card shown by the app during a visit",
    cardTitle: "Stuck?",
    immediate: ["Raise your feet", "Lean forward", "Don't hold your breath"],
    actions: { breathe: "Breathe", sound: "Sound" },
    warningTitle: "When to see a doctor",
    redFlags: [
      "Blood in your stool",
      "Severe or persistent pain",
      "Vomiting",
      "More than a week without improvement",
    ],
    disclaimer: "WC Connect is not a medical device and does not replace professional advice. Its tips are everyday-habit pointers, and it flags the situations where you should see a doctor instead.",
    families: [
      {
        title: "Posture",
        examples: [
          "Raise your feet: knees above your hips",
          "Lean forward, elbows on your thighs",
          "Feet flat, knees slightly apart",
        ],
      },
      {
        title: "Breathing",
        examples: [
          "Never hold your breath to push",
          "Let your belly expand as you breathe in",
          "Breathe out slowly, as if onto a candle",
        ],
      },
      {
        title: "Letting go",
        examples: [
          "Release shoulders, jaw and pelvic floor",
          "Six slow breaths before trying again",
          "After five minutes, stand up",
        ],
      },
      {
        title: "Habits",
        examples: [
          "Go as soon as the urge shows up",
          "Use the after-meal reflex",
          "Keep visits short, five to ten minutes",
        ],
      },
      {
        title: "Food & drink",
        examples: [
          "Drink steadily through the day",
          "Add fibre gradually",
          "Prunes, kiwis, pears",
        ],
      },
      {
        title: "Moving",
        examples: [
          "Walk for ten to fifteen minutes",
          "Massage your belly clockwise",
          "Stretch your lower back",
        ],
      },
    ],
  },

  breath: {
    eyebrow: "Unwind",
    title: "Breathe instead of pushing",
    body: "Holding your breath to push raises the pressure and tires the pelvic floor. The app guides three rhythms; the one offered during a visit has no breath hold, and the watch marks each phase with a tap — enough to follow with your eyes closed.",
    demoAlt: "Guided breathing demo, 4-6 rhythm",
    inhale: "Breathe in",
    exhale: "Breathe out",
    caption: "The app's real rhythm: 4 seconds in, 6 seconds out.",
    recommended: "on the throne",
    rhythms: [
      {
        title: "Belly",
        rhythm: "4-6",
        detail: "No breath hold: the one to use on the throne, since holding your breath amounts to pushing.",
        recommended: true,
      },
      {
        title: "Box",
        rhythm: "4-4-4-4",
        detail: "Four equal counts, to slow things down and settle.",
        recommended: false,
      },
      {
        title: "Relax",
        rhythm: "4-7-8",
        detail: "A long exhale, to release your shoulders and jaw.",
        recommended: false,
      },
    ],
  },

  sound: {
    eyebrow: "Soundscapes & music",
    title: "Your music, plus a backdrop",
    body: "WC Connect streams no catalogue of its own: it remote-controls whatever you're already playing, Apple Music included. And it adds four synthesised soundscapes that blend into the current track instead of cutting it off.",
    playerAlt: "The app's player: current track and soundscapes",
    trackTitle: "Your track",
    trackSubtitle: "From your library",
    points: [
      "A “Meeting” soundscape — office chatter and keyboard — to cover your tracks",
      "One-tap sound cover: the Meeting loop, at full volume",
      "Soundscapes layer over your music instead of cutting it",
      "They keep playing when the screen locks",
      "Play, pause and skip your own library from inside the app",
      "No catalogue streamed, no subscription needed: it's your music",
    ],
    soundscapes: [
      { title: "Rain", detail: "Covers the noises around you" },
      { title: "Brown noise", detail: "Deep and steady, very masking" },
      { title: "Breath", detail: "Swells over ten seconds" },
      { title: "Meeting", detail: "Office chatter and keyboard" },
    ],
  },

  live: {
    eyebrow: "Live Activity",
    title: "The timer where you're already looking",
    body: "As soon as a visit starts, iOS shows a Live Activity: Lock Screen, compact Dynamic Island, expanded view on touch. The system animates the timer — the app stays closed and the battery doesn't move.",
    points: [
      "Interactive “Finish” button, without unlocking the app",
      "Progress bar towards the target duration for that visit type",
      "The activity is picked back up if the app relaunches",
      "Carried over to the Apple Watch Smart Stack",
    ],
    kind: "Standard",
    place: "Home",
    action: "Finish",
  },

  watch: {
    eyebrow: "Apple Watch",
    title: "Your wrist is enough",
    body: "The Watch app stands on its own: start a visit from your watch face, finish it with a tap. Everything syncs back to the iPhone as soon as it's in range, including a visit started out of range.",
    points: [
      "Full-screen timer with a progress ring",
      "Guided breathing on your wrist, paced by haptics",
      "History and statistics by scrolling vertically",
      "Complications: circular, rectangular, corner and inline",
      "Haptic feedback when you start and when you finish",
    ],
    complicationTitle: "Visit in progress",
    complicationPlace: "Home",
    complicationInline: "WC · 3 today",
  },

  tracking: {
    eyebrow: "Tracking",
    title: "Enough to see what's actually going on",
    body: "Every recorded visit feeds a history and readable statistics: average duration, favourite time slot, running streak. Enough to spot a trend — or to show a doctor something concrete.",
    points: [
      "History grouped by day, filterable by place",
      "Comfort rated 1 to 5 and a free note at the end of a visit",
      "Home / work / out split",
      "Full CSV export, and instant deletion",
    ],
    chartTitle: "Visits over the last 7 days",
    visitOne: "visit",
    visitMany: "visits",
    days: ["M", "T", "W", "T", "F", "S", "S"],
    tiles: [
      { value: "4 min 12 s", label: "Average duration" },
      { value: "8 am", label: "Favourite slot" },
      { value: "12 d", label: "Current streak" },
      { value: "2.4", label: "Visits per day" },
    ],
  },

  fun: {
    eyebrow: "Useless, therefore essential",
    title: "A trophy room for a subject that deserved none",
    body: "14 achievements computed from your real visits, rigorously absurd equivalences, an honorary title and a certificate to pass around to people who never asked for it.",
    badgesAlt: "Examples of achievements to unlock",
    points: [
      "An honorary title that evolves, from “Bathroom Nobody” to “Deity of the Latrines”",
      "Five secret achievements, revealed only when unlocked",
      "A haiku composed at the end of every visit, from its duration and hour",
      "A fanfare and a banner when an achievement drops",
      "An official certificate to share, with no legal value whatsoever",
      "A hidden throne mode: press and hold the timer",
      "Fourteen achievements to unlock, computed from your real visits",
    ],
    badges: [
      { title: "Lightning", detail: "A visit in under 45 seconds" },
      { title: "Marathoner", detail: "Over twenty minutes. Respect." },
      { title: "Night owl", detail: "A visit between 2 and 5 am" },
      { title: "Globetrotter", detail: "Home, work and out on the same day" },
      { title: "Swiss clock", detail: "Three days in a row at the same time" },
      { title: "The Thinker", detail: "A quarter of an hour, and comfort 5 out of 5" },
    ],
    haiku: {
      title: "Haiku of the visit",
      lines: ["The cold tiled floor", "time stretches out peacefully here", "the coffee will wait"],
      foot: "Composed from the duration, the hour and the place. Nobody asked for it.",
    },
    absurdTitle: "Your time, in more telling units",
    absurdFoot: "Example for a few hours of history.",
    equivalences: [
      { value: "7", label: "TV episodes watched sitting down" },
      { value: "45", label: "songs played all the way through" },
      { value: "1.38", label: "train rides from Paris to Lyon" },
      { value: "13.3 km", label: "covered had you walked instead" },
    ],
  },

  weather: {
    eyebrow: "Gut forecast",
    title: "A bulletin nobody asked for",
    body: "The app compares the past week with the one before and issues a full bulletin: pressure, chance of showers, visibility, wind. No predictive value, a real method of calculation. It also works out your profile and the time of your next visit.",
    cardAlt: "Gut forecast bulletin shown by the app",
    kicker: "Gut forecast",
    points: [
      "A bulletin computed from the past week, compared with the one before",
      "Pressure, chance of showers, visibility and wind — meaningless, properly calculated",
      "A profile drawn from your habits, from Morning Sprinter to Hermit of the Night",
      "A forecast of your next visit, with honestly low confidence",
      "A Home Screen widget, to read the bulletin without opening the app",
    ],
    forecast: {
      condition: "Changeable",
      summary: "Bright spells alternating with a few cloudy periods. Nothing alarming.",
      wind: "moderate southerly wind",
      rows: [
        { label: "Pressure", value: "1021 hPa" },
        { label: "Showers", value: "34 %" },
        { label: "Visibility", value: "fair" },
      ],
      personaTitle: "The Morning Regular",
      personaDetail: "4 min 12 s on average, with a marked preference for 8 am. A clock.",
      prediction: "Next visit expected around 8 am — 37 % confidence",
      lifetime: "At this rate, you'll spend 4.3 months of your life on it. Sitting.",
    },
  },

  privacy: {
    eyebrow: "Privacy",
    title: "Your breaks are nobody's business",
    lead: "No account, no analytics, no server. Your history lives in a space shared between the app, the widgets and the watch, on your devices only. iPhone ↔ Watch syncing goes through WatchConnectivity, directly, device to device.",
    tags: ["0 trackers", "0 network requests", "CSV export", "Instant deletion"],
  },

  faq: {
    title: "Frequently asked questions",
    questions: [
      {
        question: "Do I need a recent iPhone?",
        answer: "WC Connect requires iOS 17 and watchOS 10. The Dynamic Island appears on models that have one; on the others, the Live Activity still shows on the Lock Screen.",
      },
      {
        question: "Does the app work without an iPhone nearby?",
        answer: "Yes. The Watch app records the visit locally and sends it to the iPhone as soon as it's reachable again. Duplicates are merged automatically.",
      },
      {
        question: "Does the Live Activity drain the battery?",
        answer: "Barely: the system renders the timer from a start date. The app is never woken up to animate it.",
      },
      {
        question: "Do I need a music subscription?",
        answer: "No. The app streams no catalogue: it drives playback from your own library or the Music app, and its four soundscapes ship inside the app. The controls work even if you deny library access — only showing the current track needs that permission.",
      },
      {
        question: "A “Meeting” soundscape, really?",
        answer: "Really. Office chatter with a few keystrokes, to play from the bathroom at work. Like the other soundscapes it's synthesised and bundled in the app. What you do with it is your business.",
      },
      {
        question: "Do the tips replace a doctor?",
        answer: "No, and the app says so. They are everyday-habit pointers — posture, breathing, hydration, movement. The app also lists the situations that call for medical advice rather than exercises: blood in your stool, severe pain, vomiting, or constipation lasting more than a week.",
      },
      {
        question: "Can I get my data back?",
        answer: "A CSV export is available in the settings: start date, end date, duration, type, place, comfort, device and note.",
      },
      {
        question: "A haiku, seriously?",
        answer: "Seriously. Three lines composed at the end of every visit, picked from its duration, hour and place — so always the same for the same visit. Thirty lines in stock, in both languages. It is the most useless feature in the app, and it is staying.",
      },
      {
        question: "Is this thing serious?",
        answer: "Half of it. The subject raises a smile, the code doesn't: tested logic, local data, native interface. Which half you're in is up to you.",
      },
    ],
  },

  cta: {
    title: "Coming to your pocket",
    body: "WC Connect is under development, privately. The app will land on iPhone and Apple Watch; until then, the beta is invitation-only.",
    action: "Back to the features",
    legal: "Independent project, not affiliated with Apple. iPhone, Apple Watch, Siri and Dynamic Island are trademarks of Apple Inc.",
  },

  footer: {
    tagline: "Made seriously, about something that isn't.",
  },
};
