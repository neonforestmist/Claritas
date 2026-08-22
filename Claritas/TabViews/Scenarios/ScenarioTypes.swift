import SwiftUI

enum ScenarioDestination: String, Hashable, Identifiable {
    case everyday
    case homework
    case writing

    var id: String { rawValue }
}

/// Colour palette for an immersive full-screen story view.
struct StoryPalette {
    /// Full-screen background colour.
    let background: Color
    /// Primary text / icon colour (should contrast with background).
    let ink: Color
    /// Accent used for buttons, labels, etc.
    let accent: Color
    /// SF Symbol name for the large decorative backdrop.
    let symbol: String
}

struct ScenarioCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let heroTitle: String
    let heroSymbolName: String
    let points: [SIMD2<Float>]
    let colors: [Color]
    let destination: ScenarioDestination
}

/// A Goosebumps-style choice at the bottom of a story beat.
struct StoryChoice {
    /// Short prompt shown to the user describing this path.
    let prompt: String
    /// The beat ID this choice navigates to.
    let targetBeatID: String
}

/// A single line in an inline chat exchange shown mid-story.
struct ChatLine {
    let text: String
    /// true = character's message (right-aligned), false = AI response (left-aligned).
    let isUser: Bool
}

struct ScenarioBeat: Identifiable {
    let id: String
    let emoji: String
    let title: String
    /// Second-person narrative text for the immersive page.
    let story: String
    /// Optional continuation prose rendered after the inline chat block.
    let storyAfterChat: String?
    let aiMove: String
    /// Optional — nil on beats where inline chat already demonstrates the prompt,
    /// and on ending beats where no further action is needed.
    let promptToTry: String?
    /// When true the prompt block is labelled "PROMPT TO TRY" (a good example to copy).
    /// When false it is labelled "PROMPT TRIED" (shown for context, not recommended).
    let isPromptRecommended: Bool
    /// Optional — nil when aiMove covers the lesson sufficiently.
    let whyItMatters: String?
    /// Inline palette-aware chat exchange shown between prose and callouts.
    let inlineChat: [ChatLine]
    /// Inline to-do / checklist items (used in Joe's planning beats).
    let todoItems: [String]
    /// Two branching choices. Empty on the final beat.
    let choices: [StoryChoice]

    init(
        id: String,
        emoji: String,
        title: String,
        story: String,
        storyAfterChat: String? = nil,
        aiMove: String,
        promptToTry: String? = nil,
        isPromptRecommended: Bool = true,
        whyItMatters: String? = nil,
        inlineChat: [ChatLine] = [],
        todoItems: [String] = [],
        choices: [StoryChoice] = []
    ) {
        self.id = id
        self.emoji = emoji
        self.title = title
        self.story = story
        self.storyAfterChat = storyAfterChat
        self.aiMove = aiMove
        self.promptToTry = promptToTry
        self.isPromptRecommended = isPromptRecommended
        self.whyItMatters = whyItMatters
        self.inlineChat = inlineChat
        self.todoItems = todoItems
        self.choices = choices
    }
}

struct ScenarioStory {
    let title: String
    let subtitle: String
    /// Second-person teaser shown on the intro page.
    let introText: String
    let importanceHeadline: String
    let palette: StoryPalette
    /// All beats including branching ones. Looked up by id.
    let beats: [ScenarioBeat]
    /// The id of the first beat to show.
    let firstBeatID: String
    let bestUseMoves: [String]
    let watchOuts: [String]

    /// Look up a beat by id, falling back to the first beat.
    func beat(id: String) -> ScenarioBeat {
        beats.first(where: { $0.id == id }) ?? beats[0]
    }

    /// 1-based page number for display.
    func pageNumber(for id: String) -> Int {
        (beats.firstIndex(where: { $0.id == id }) ?? 0) + 1
    }
}

extension ScenarioCard {
    static let stableGridPoints: [SIMD2<Float>] = [
        SIMD2<Float>(0.00, 0.00), SIMD2<Float>(0.50, 0.00), SIMD2<Float>(1.00, 0.00),
        SIMD2<Float>(0.00, 0.50), SIMD2<Float>(0.50, 0.50), SIMD2<Float>(1.00, 0.50),
        SIMD2<Float>(0.00, 1.00), SIMD2<Float>(0.50, 1.00), SIMD2<Float>(1.00, 1.00)
    ]

    static let samples: [ScenarioCard] = [
        ScenarioCard(
            title: "A Day in Joe's Life ☀️",
            subtitle: "See how AI can help Joe juggle a full day of classes, groceries, and bills without taking over his life.",
            heroTitle: "Everyday",
            heroSymbolName: "sun.max.fill",
            points: stableGridPoints,
            colors: [
                Color(.sRGB, red: 0.99, green: 0.95, blue: 0.66, opacity: 1.0),
                Color(.sRGB, red: 0.98, green: 0.92, blue: 0.58, opacity: 1.0),
                Color(.sRGB, red: 0.72, green: 0.84, blue: 0.97, opacity: 1.0),
                Color(.sRGB, red: 0.97, green: 0.88, blue: 0.54, opacity: 1.0),
                Color(.sRGB, red: 1.00, green: 0.96, blue: 0.72, opacity: 1.0),
                Color(.sRGB, red: 0.97, green: 0.75, blue: 0.82, opacity: 1.0),
                Color(.sRGB, red: 0.99, green: 0.90, blue: 0.62, opacity: 1.0),
                Color(.sRGB, red: 0.94, green: 0.66, blue: 0.78, opacity: 1.0),
                Color(.sRGB, red: 0.62, green: 0.78, blue: 0.95, opacity: 1.0)
            ],
            destination: .everyday
        ),
        ScenarioCard(
            title: "Alan's Homework 🧠",
            subtitle: "See how AI can turn Alan's dreaded fraction homework into something he actually understands — with a little help from Max the Math Pug.",
            heroTitle: "Homework",
            heroSymbolName: "graduationcap.fill",
            points: stableGridPoints,
            colors: [
                Color(.sRGB, red: 0.03, green: 0.06, blue: 0.14, opacity: 1.0),
                Color(.sRGB, red: 0.07, green: 0.09, blue: 0.21, opacity: 1.0),
                Color(.sRGB, red: 0.17, green: 0.24, blue: 0.41, opacity: 1.0),
                Color(.sRGB, red: 0.04, green: 0.07, blue: 0.17, opacity: 1.0),
                Color(.sRGB, red: 0.10, green: 0.16, blue: 0.31, opacity: 1.0),
                Color(.sRGB, red: 0.20, green: 0.30, blue: 0.50, opacity: 1.0),
                Color(.sRGB, red: 0.02, green: 0.04, blue: 0.11, opacity: 1.0),
                Color(.sRGB, red: 0.08, green: 0.12, blue: 0.24, opacity: 1.0),
                Color(.sRGB, red: 0.52, green: 0.70, blue: 0.93, opacity: 1.0)
            ],
            destination: .homework
        ),
        ScenarioCard(
            title: "Sam's Short Story ✍️",
            subtitle: "See how AI can help Sam break through writer's block and finish a short story that's still unmistakably their own.",
            heroTitle: "Writing",
            heroSymbolName: "pencil.and.outline",
            points: stableGridPoints,
            colors: [
                Color(.sRGB, red: 0.26, green: 0.28, blue: 0.33, opacity: 1.0),
                Color(.sRGB, red: 0.78, green: 0.80, blue: 0.84, opacity: 1.0),
                Color(.sRGB, red: 0.32, green: 0.34, blue: 0.39, opacity: 1.0),
                Color(.sRGB, red: 0.18, green: 0.20, blue: 0.24, opacity: 1.0),
                Color(.sRGB, red: 0.86, green: 0.87, blue: 0.90, opacity: 1.0),
                Color(.sRGB, red: 0.94, green: 0.94, blue: 0.96, opacity: 1.0),
                Color(.sRGB, red: 0.24, green: 0.26, blue: 0.30, opacity: 1.0),
                Color(.sRGB, red: 0.70, green: 0.72, blue: 0.76, opacity: 1.0),
                Color(.sRGB, red: 0.96, green: 0.96, blue: 0.98, opacity: 1.0)
            ],
            destination: .writing
        )
    ]

    static func sample(for destination: ScenarioDestination) -> ScenarioCard {
        samples.first(where: { $0.destination == destination }) ?? samples[0]
    }
}

extension ScenarioStory {
    static func content(for destination: ScenarioDestination) -> ScenarioStory {
        switch destination {

        // ── EVERYDAY (Joe, 21) ──────────────────────────────────────────
        // Graph: e1 → (A→e2 | B→e3), e2 → (A→e4 | B→e5), e3 → (A→e6 | B→e7)
        case .everyday:
            return ScenarioStory(
                title: "A Day in Joe's Life",
                subtitle: "Joe's to-do list is already buzzing. How he uses AI today decides whether it becomes a helpful sidekick or an overwhelming boss.",
                introText: "Your phone's alarm starts another day. Classes and work, groceries to buy, bills to manage, a reminder to exercise, and figuring out what to cook tonight. It's a lot to juggle, and being on your own means all the decisions fall on you.\n\nYou're Joe, 21 years old. You've got an AI assistant on your phone that you've never really tried. Today, you decide to experiment. The question is — how heavily do you rely on it?",
                importanceHeadline: "AI works best as an assistant, not a boss — the best results come when you stay in control.",
                palette: StoryPalette(
                    background: Color(
                        red: 215.0 / 255.0,
                        green: 178.0 / 255.0,
                        blue: 54.0 / 255.0
                    ),
                    ink: Color(red: 0.10, green: 0.08, blue: 0.04),
                    accent: Color(red: 0.20, green: 0.12, blue: 0.00),
                    symbol: "sun.max"
                ),
                beats: [
                    // e1 — opening
                    ScenarioBeat(
                        id: "e1",
                        emoji: "☕",
                        title: "A new experiment",
                        story: "You pull out your phone and open an AI assistant for the first time. Coffee in hand, you type out everything on your plate and hit send, curious what it'll say.",
                        aiMove: "Before going all-in or ignoring it, think about what role you want AI to play. Is it planning your whole day, or helping with specific tasks where you need a hand?",
                        whyItMatters: "The way you set up your relationship with AI on day one shapes whether it becomes a helpful tool or an overwhelming taskmaster.",
                        inlineChat: [
                            ChatLine(text: "I've got a packed day — classes, groceries, bills, a workout. Where should I even start?", isUser: true),
                            ChatLine(text: "Let's get you sorted! Here's a simple plan — you decide how closely to follow it:", isUser: false)
                        ],
                        todoItems: [
                            "Pay electricity bill — due today!",
                            "Attend 10 am – 12 pm class",
                            "Grocery run: chicken, rice, veg",
                            "20-min workout (bodyweight, no equipment)",
                            "Cook dinner — one-pot chicken rice",
                            "Review weekly budget"
                        ],
                        choices: [
                            StoryChoice(prompt: "Go all-in: let AI plan and handle as much of your day as possible", targetBeatID: "e2"),
                            StoryChoice(prompt: "Use AI as an assistant, not a boss — you make the final calls", targetBeatID: "e3")
                        ]
                    ),
                    // e2 — all-in with AI
                    ScenarioBeat(
                        id: "e2",
                        emoji: "🤖",
                        title: "All-in with AI",
                        story: "Determined to maximise convenience, you start the morning by telling the AI to plan your entire day. Almost instantly, it replies with a schedule: when to eat, when to study, when to work out, and what to have for each meal. For breakfast, it suggests a kale smoothie because it's 'nutritious' — never mind that you're not a fan of kale. You gulp it down anyway since the AI said so.\n\nYou ask for a grocery list for the week. The AI comes up with seven days of meals, optimised for budget and health — but it's a long list of ingredients you've never heard of. Shopping takes ages hunting for quinoa flour and exotic spices. You skip cheaper alternatives because the AI's recipe specifically calls for these.\n\nIn the afternoon, the AI picks your workout: a high-intensity 5km run with sprints. You haven't jogged in months, but you push on because it's 'part of the plan.' By early evening, you're drained. You're starting to feel like a robot following orders.",
                        aiMove: "You asked AI to plan everything — meals, workouts, schedule. It optimised for health and efficiency, but forgot to account for what you actually enjoy or how your body feels.",
                        promptToTry: "Plan my entire day: meals, study schedule, workout, and evening tasks. Optimise for health and productivity.",
                        isPromptRecommended: false,
                        whyItMatters: "AI doesn't have your taste buds, your energy levels, or your friendships. A perfectly optimised plan can feel robotic when it ignores what makes you human.",
                        choices: [
                            StoryChoice(prompt: "Stick to the AI's plan for the rest of the week — stay disciplined", targetBeatID: "e4"),
                            StoryChoice(prompt: "Regain control — start adjusting the suggestions that don't feel right", targetBeatID: "e5")
                        ]
                    ),
                    // e3 — assistant, not boss
                    ScenarioBeat(
                        id: "e3",
                        emoji: "🤝",
                        title: "Assistant, not boss",
                        story: "You choose a balanced approach. In the morning, you ask the AI for quick help on specific tasks — a simple meal and a workout routine. The AI suggests a one-pot chicken rice dish with veggies and a 20-minute bodyweight routine.",
                        storyAfterChat: "Throughout the day, you sprinkle in the AI's assistance where it makes sense. Before class, you ask it to organise your to-do list by priority. It puts your bill-paying at the top — good call, you almost forgot the electricity bill is due tomorrow. During lunch, you have the AI help set up a simple budget plan. You adjust a few numbers where you know your habits differ.\n\nAfter classes, you hit the grocery store with the AI's short list. In and out in 10 minutes. While cooking, you add chili flakes the AI didn't mention — you love a little kick. The meal turns out tasty and within budget. After a 20-minute workout, you ask the AI for some reflection prompts to wind down.",
                        aiMove: "You asked AI for help on specific tasks — a simple meal, a quick workout, and a sorted to-do list. You made the final calls and adjusted where needed.",
                        promptToTry: "You are a practical daily assistant. I am a busy 21-year-old on a tight budget. Give me: 1) a simple chicken dinner I can cook in under 20 minutes, and 2) a beginner-friendly 20-minute workout I can do at home with no equipment. Answer in short bullet points.",
                        whyItMatters: "Using AI for targeted help keeps you in the driver's seat. You get the benefits of its suggestions without surrendering your judgment or preferences.",
                        inlineChat: [
                            ChatLine(text: "What's a simple, cheap meal I can make tonight with chicken?", isUser: true),
                            ChatLine(text: "One-pot chicken rice! Fry chicken pieces 5 min, add rice + broth + frozen peas, cover and cook 15 min. ~£2.50 per serving. 🍚", isUser: false),
                            ChatLine(text: "Perfect. Also — quick 20-min workout for someone who hasn't exercised in a while?", isUser: true),
                            ChatLine(text: "Bodyweight circuit — 3 rounds: 10 squats, 8 push-ups, 10 lunges, 30-sec plank. Rest 60 sec between rounds. No equipment needed! 💪", isUser: false)
                        ],
                        choices: [
                            StoryChoice(prompt: "Chat a bit more with the AI before sleeping — a joke and tomorrow's plan", targetBeatID: "e6"),
                            StoryChoice(prompt: "Power down for the night — give yourself tech-free relaxation", targetBeatID: "e7")
                        ]
                    ),
                    // e4 — ending: stuck with rigid plan
                    ScenarioBeat(
                        id: "e4",
                        emoji: "😤",
                        title: "The robotic week",
                        story: "You commit to following the AI's plan for several more days. You wake up at the times it says, study when it dictates, and keep eating the meals it plans—even the ones you don't entirely like. There are moments of convenience, but by mid-week you feel oddly disconnected from your own life.\n\nOne evening, a friend calls to invite you out for a burger. You hesitate — the AI's meal plan says steamed veggies tonight. You decline to stay 'on track,' but as you sit there picking at broccoli, you realise you're missing out. The next day, you push through an AI-prescribed workout despite a slight pain in your knee. You end up aggravating it.\n\nBy week's end, you're more stressed than when you started. Your budget spreadsheet looks tidy and you stuck to a healthy routine — but you didn't enjoy the meals, you're nursing a minor injury, and you feel burned out. You decide to dial back. There's nothing wrong with getting suggestions, but living on autopilot isn't for you.",
                        aiMove: "You committed to the AI's plan for a full week. Some things were efficient, but you missed a friend hangout, aggravated an injury, and felt more stressed than when you started.",
                        promptToTry: "I've been following your plan strictly but I'm burned out. Help me build a more flexible version that accounts for how I'm actually feeling.",
                        whyItMatters: "AI is a tool, not a boss. Blindly following AI instructions for every aspect of life left you unhappy. Even the best AI can't account for your changing needs and spontaneous opportunities."
                    ),
                    // e5 — ending: took back control
                    ScenarioBeat(
                        id: "e5",
                        emoji: "😊",
                        title: "Taking back the reins",
                        story: "By dinnertime, you've grown tired of the AI's generic recommendations. When it suggests another complicated recipe, you decide to cook something you actually crave — a simple spaghetti dish. You swap out the AI's plan with your own common-sense choices. The meal turns out great.\n\nAfter dinner, instead of the next 'scheduled' task, you call a friend and spend the evening together. Over the next few days, you keep using the AI but on your terms. You still ask for help — like a budget plan — but tweak the categories to fit your actual habits. For workouts, you adjust to a gentle yoga session when feeling sore instead of the AI's 5km run.\n\nLife gets smoother. You save money using AI's budgeting tips but still buy your favourite snack. Your meals are healthier because of the AI's ideas, but you're not afraid to spice them up. This balance feels empowering — you're getting the benefits of AI's organisation without feeling controlled by it.",
                        aiMove: "You swapped the AI's complicated recipe for something you actually crave, called a friend instead of following the schedule, and tweaked the budget to fit your real habits.",
                        promptToTry: "I like your suggestions but I'm going to adjust them. Help me modify the meal plan to include foods I actually enjoy, and add a 'fun money' category to the budget.",
                        whyItMatters: "Co-pilot, not autopilot. AI became your assistant — helping you eat better, budget smarter, and plan efficiently — while you remained the driver of decisions."
                    ),
                    // e6 — ending: chat more with AI before sleep
                    ScenarioBeat(
                        id: "e6",
                        emoji: "😴",
                        title: "One last assist",
                        story: "Before fully turning in, you decide to use the AI for one last little thing. You ask for a funny bedtime joke. 'Why did the robot go to therapy? Because it had too many bytes on its brain!' It's silly, but you chuckle. Feeling optimistic, you also ask, 'What are the top 3 things I should focus on tomorrow?' The AI suggests reviewing for your exam, paying that bill, and scheduling a study break with a friend.\n\nSatisfied, you say goodnight to the AI and silence your phone. Lying in bed, you reflect on the day. With the AI's help, you cooked a great meal, stuck to your budget, got some exercise, and even took time to reflect. None of those tasks felt too hard with a bit of guidance. Importantly, you still felt in charge — tweaking the plan when needed and doing things you enjoy. The AI didn't replace your common sense; it augmented it. Life feels just a bit easier and more organised, but still your life.",
                        aiMove: "You asked for a bedtime joke and tomorrow's top three priorities. Small AI interactions at the end of the day wrapped things up on a positive note.",
                        whyItMatters: "Little interactions show AI's everyday value — it's there anytime, even for a laugh or late-night planning. Having an AI buddy to remind you of priorities reduces stress."
                    ),
                    // e7 — ending: unplug for the night
                    ScenarioBeat(
                        id: "e7",
                        emoji: "🌙",
                        title: "Unplugged",
                        story: "You decide you've gotten plenty of help from the AI today and choose to end the night screen-free. You put your phone on do-not-disturb and take a few quiet minutes to reflect on the day yourself. It feels good — that workout, dinner, and the fact that you're on top of your budget now.\n\nLying in bed, you notice how calm you feel. The usual anxiety about 'Did I forget something?' isn't there — the AI's gentle reminders and your proactive planning saw to that. And now, by intentionally stepping away from tech, you're proving that you're not dependent on it. You've used the AI where it helped and then confidently switched it off when you didn't need it. That realisation is empowering: you are in control of your life, with AI as a helpful sidekick, not an indispensable crutch.",
                        aiMove: "You put the phone on do-not-disturb and reflected on your own. The AI was helpful today, but you proved you're equally comfortable handling things without it.",
                        whyItMatters: "Healthy boundaries. While AI is available 24/7, you don't have to use it all the time. Unplugging when you want to is healthy — you remain in charge of when and how to use technology."
                    )
                ],
                firstBeatID: "e1",
                bestUseMoves: [
                    "Use AI for specific tasks — meals, budgets, workouts — not your entire day.",
                    "Always adjust AI suggestions to fit your actual preferences and energy level.",
                    "Small AI interactions (a joke, a reminder) can brighten your day without taking over.",
                    "End the day on your own terms — AI is a sidekick, not a life manager."
                ],
                watchOuts: [
                    "Don't blindly follow AI's plans — it doesn't know your body, your mood, or your friendships.",
                    "Don't skip real-life moments (friend hangouts, rest days) just because the AI scheduled something else.",
                    "Don't mistake efficiency for happiness — a perfectly optimised day can feel empty without personal touches."
                ]
            )

        // ── HOMEWORK (Alan, 11) ──────────────────────────────────────────
        // Graph: h1 → (A→h2 | B→h3), h2 → (A→h4 | B→h5), h3 → (A→h6 | B→h7)
        case .homework:
            return ScenarioStory(
                title: "Alan's Homework",
                subtitle: "Alan is stuck on mixed fractions and a pug named Max won't stop nudging his foot. What he does next changes everything.",
                introText: "You have a blinking cursor and two hours to finish your math homework. Mixed fractions stare back at you, and you feel stuck. Your pet pug, Max, nudges a toy at your feet, reminding you of what you love. If only math could be as fun as playing with Max.\n\nYou're Alan, 11 years old. You've heard about an AI chatbot that might help — like a tutor available 24/7. Taking a deep breath, you decide to give it a try.",
                importanceHeadline: "How you use AI for homework decides whether you actually learn or just survive tonight.",
                palette: StoryPalette(
                    background: Color(red: 0.07, green: 0.07, blue: 0.10),
                    ink: Color(red: 0.95, green: 0.95, blue: 1.00),
                    accent: Color(red: 0.55, green: 0.70, blue: 1.00),
                    symbol: "dog"
                ),
                beats: [
                    // h1 — opening
                    ScenarioBeat(
                        id: "h1",
                        emoji: "😬",
                        title: "Stuck and staring",
                        story: "Max tilts his head and nudges the keyboard with his nose — almost like he's telling you to just type something. You open the chatbot. The real question is: what do you actually ask it?",
                        aiMove: "Think about what you really need. Do you want someone to just do the work for you, or do you want to understand it? How you ask AI sets the direction.",
                        whyItMatters: "The first thing you type into AI shapes the entire experience. Asking for answers gives you answers. Asking to learn gives you understanding.",
                        inlineChat: [
                            ChatLine(text: "I'm 11 and totally stuck on mixed fractions. Can you help? 😬", isUser: true),
                            ChatLine(text: "Of course! Mixed fractions are easier than they look. Are you more of a step-by-step person, or do you learn better by jumping into an example first?", isUser: false)
                        ],
                        choices: [
                            StoryChoice(prompt: "Ask the AI for the answers to the fraction problems so you can finish quickly", targetBeatID: "h2"),
                            StoryChoice(prompt: "Ask the AI to act like your pug Max teaching math and make fractions fun", targetBeatID: "h3")
                        ]
                    ),
                    // h2 — asked for answers
                    ScenarioBeat(
                        id: "h2",
                        emoji: "📋",
                        title: "The quick answers",
                        story: "You open the chatbot and type the first thing that comes to mind — just the problem, nothing more.",
                        storyAfterChat: "You jot down 9¼, relieved to be 'done.' But as you write the answer, a small voice wonders: why does that even work? You still don't really understand mixed fractions. Tomorrow the teacher might ask you to show your working, and you'll have nothing. Max tilts his head as if sensing your doubt. Getting the answer was fast — but was it actually helpful?",
                        aiMove: "You asked for the answer and got it — nothing more. A bare result with no explanation is easy to copy and impossible to learn from.",
                        whyItMatters: "Copying answers gets the homework done, but it doesn't prepare you for when you need to show your work, and so you don't really learn anything.",
                        inlineChat: [
                            ChatLine(text: "What is 5½ + 3¾?", isUser: true),
                            ChatLine(text: "5½ + 3¾ = 9¼", isUser: false)
                        ],
                        choices: [
                            StoryChoice(prompt: "Press for understanding: ask the AI to explain how it got the answers", targetBeatID: "h4"),
                            StoryChoice(prompt: "Move on: trust the AI's answers and close your books", targetBeatID: "h5")
                        ]
                    ),
                    // h3 — pug tutor
                    ScenarioBeat(
                        id: "h3",
                        emoji: "🐶",
                        title: "Max the Math Pug",
                        story: "You type a creative request: 'Pretend you're my pug, Max, and teach me how to add mixed fractions.' The AI's response appears: 'Woof! I'm Max the Math Pug! Let's solve this with treats!' You giggle — the AI is talking like Max, complete with dog emojis and a silly joke. It shows a problem: 'You have 5½ dog treats and I give you 3¾ more…' Suddenly, fractions feel like a game.\n\nYou work through the treat problem with Max the Math Pug cheering you on. The explanation clicks — for the first time, mixed fractions make sense and make you smile. After a couple of fun examples, you've actually solved a real homework question on your own. The AI asks if you want another practice question or if you're ready to tackle the rest of your homework.",
                        aiMove: "You gave the AI three things in one prompt: a role ('You are Max the Math Pug — a cheerful pug who loves maths'), your context ('I'm Alan, 11 years old, struggling with mixed fractions'), and how to respond ('step by step, using dog treats, keep it fun, use dog emojis'). That combination — role, context, format — is what turned a basic chatbot into a tutor that actually worked very well for you.",
                        whyItMatters: "When you bring your interests into learning, the material sticks. A creative prompt turned AI into a tutor that feels like a friend, not a textbook.",
                        inlineChat: [
                            ChatLine(text: "You are Max the Math Pug 🐾 — a cheerful, patient pug who LOVES maths. I'm Alan, I'm 11 years old, and I'm really struggling to add mixed fractions like 5½ + 3¾. Teach me step by step using dog treats as examples, keep it simple and fun, and use dog emojis so it doesn't feel like boring homework! 🐶", isUser: true),
                            ChatLine(text: "🐾 Woof woof! I'm Max the Math Pug — treats are my JAM!\n\nOk Alan, here we go 🦴\n\nYou have 5½ treats. I bring you 3¾ more.\n\nStep 1 — whole numbers first: 5 + 3 = 8 🐶\nStep 2 — fractions next: ½ + ¾ = 1¼ 🐾\nStep 3 — combine them: 8 + 1¼ = 9¼ treats!\n\nThat's it! You just added mixed fractions! 🏆 Wanna try one yourself?", isUser: false)
                        ],
                        choices: [
                            StoryChoice(prompt: "Practice one more problem with your pug tutor to make sure you've got it", targetBeatID: "h6"),
                            StoryChoice(prompt: "Dive into homework now that you're feeling confident", targetBeatID: "h7")
                        ]
                    ),
                    // h4 — ending: asked for explanation (good recovery)
                    ScenarioBeat(
                        id: "h4",
                        emoji: "💡",
                        title: "Understanding clicks",
                        story: "9¼ is written in your notebook, but it doesn't feel real. You go back to the chatbot — this time with a different question.",
                        storyAfterChat: "Something shifts. You re-read the steps slowly and it makes sense — you can see exactly why 5½ plus 3¾ equals 9¼. You try one more problem on your own, and it clicks. By bedtime, you've finished your homework and actually understand mixed fractions. You smile, grateful you went back and asked.",
                        aiMove: "You pushed past the quick answer and asked the AI to explain. That one extra question turned a shortcut into actual learning.",
                        promptToTry: "You are a patient maths tutor for primary school students. I am Alan, 11 years old, and I just copied an answer without understanding it. Walk me through how to add mixed fractions like 5½ + 3¾ so I actually get it — not just the answer. Answer in short, numbered steps with one idea per step.",
                        whyItMatters: "Understanding over answers. Getting the answer isn't the same as knowing how to do it. By asking 'why' and 'how,' the AI became a helpful teacher.",
                        inlineChat: [
                            ChatLine(text: "Actually — can you explain *how* you got 9¼? I want to understand the steps, not just the answer.", isUser: true),
                            ChatLine(text: "Great question! Here's how it works:\n\nStep 1: Add the whole numbers → 5 + 3 = 8\nStep 2: Add the fractions → ½ + ¾. Make the denominators match: ½ = 2⁄4, so 2⁄4 + 3⁄4 = 5⁄4 = 1¼\nStep 3: Add them together → 8 + 1¼ = 9¼\n\nWant to try one yourself? Practising helps it really stick! 😊", isUser: false)
                        ]
                    ),
                    // h5 — ending: moved on without understanding
                    ScenarioBeat(
                        id: "h5",
                        emoji: "😣",
                        title: "The morning after",
                        story: "You shut your laptop, deciding the answers are 'good enough.' The next day in class, your teacher asks you to explain how you solved one problem. You have no idea. At home, you sigh as you realise you'll face the same confusion on the next homework or test. Max hops into your lap as if to comfort you, but you know this could have gone better. Relying on the AI for quick answers saved time tonight, but it didn't help you learn.",
                        aiMove: "You decided the answers were good enough. But without understanding the method, you had nothing to fall back on when it mattered.",
                        whyItMatters: "Quick fixes have lasting costs. Copy-pasting answers with AI might save time tonight, but you end up unprepared when you need to explain or apply the knowledge."
                    ),
                    // h6 — ending: practiced more with pug
                    ScenarioBeat(
                        id: "h6",
                        emoji: "🏆",
                        title: "Mastery through practice",
                        story: "You decide to stick with Max the Math Pug for one more round. 'Great! Here's another!' the AI replies enthusiastically. This time it's a bit harder: 'Max has 2¼ chewy bones and finds 4½ more…' You solve it with the AI's guidance, and it feels even easier than before. Each practice solidifies what you've learned.\n\nBy the time you turn to your actual homework, it's a breeze — you solve every fraction problem correctly and even double-check your work. When you hand in your assignment, you feel proud because you truly understand the material. Your teacher notices your improved confidence. At home, you give the real Max a big hug, thanking him (and the AI) for being awesome tutors.",
                        aiMove: "You stuck with your creative tutor for one more round. Each practice problem solidified what you learned, making the actual homework a breeze.",
                        whyItMatters: "Mastery through practice. Even with AI's help, doing that one more problem built your confidence. AI can offer endless practice and patience — take advantage of it."
                    ),
                    // h7 — ending: skipped to homework
                    ScenarioBeat(
                        id: "h7",
                        emoji: "🤏",
                        title: "Almost nailed it",
                        story: "Feeling upbeat, you tell the AI, 'Thanks, Max, I got it from here!' and close the chat to finish the rest on your own. The first few homework problems go well — you apply the method the AI showed you. But one question is worded differently, and you start getting unsure. Without additional practice, your new understanding feels a bit shaky on the trickier problem.\n\nIn class the next day, you do okay on a fractions quiz — most problems right, except the one that was similar to the tricky question. 'You were so close to an A,' your teacher says, 'just a small mistake.' You realise a bit more practice might have prevented that error. Still, you feel worlds better about fractions than before, and you actually had fun learning.",
                        aiMove: "You felt confident and jumped straight to the homework. Most of it went well — but one tricky question showed that a bit more practice might have sealed the deal.",
                        whyItMatters: "Balance speed and learning. It was great to finish quickly, but skipping extra practice meant you nearly mastered the topic instead of completely nailing it."
                    )
                ],
                firstBeatID: "h1",
                bestUseMoves: [
                    "Stay curious: ask 'why' and 'how,' not just 'what.'",
                    "Make it personal; bring your interests into the prompt to make learning fun.",
                    "Practice one more problem than you think you need — it locks in the concept.",
                ],
                watchOuts: [
                    "Don't let AI become a homework vending machine; quick answers don't build understanding.",
                    "Don't skip more practice just because you feel confident; one more problem can really make the difference.",
                ]
            )

        // ── WRITING (Sam, teenager) ──────────────────────────────────────
        // Graph: w1 → (A→w2 | B→w3), w2 → (A→w4 | B→w5), w3 → (A→w6 | B→w7)
        case .writing:
            return ScenarioStory(
                title: "Sam's Short Story",
                subtitle: "Sam has a dozen half-formed ideas and zero pages written. The short story is due tomorrow.",
                introText: "You stare at the blank document on your screen. The short story assignment is due tomorrow, and you expected to be typing away by now. Instead, nothing feels right. You start one idea, then doubt it and jump to another. Now you've got a dozen half-formed concepts and zero pages written.\n\nYou're Sam, a teenager with a head full of ideas. You remember a friend mentioning an AI writing assistant. At this point, any help sounds good. But you wonder: if you use AI, will it still be your story?",
                importanceHeadline: "AI can help you past the blank page, but the story is only yours if your voice is in it.",
                palette: StoryPalette(
                    background: Color(red: 0.96, green: 0.96, blue: 0.92),
                    ink: Color(red: 0.13, green: 0.13, blue: 0.11),
                    accent: Color(red: 0.20, green: 0.40, blue: 0.20),
                    symbol: "pencil.and.outline"
                ),
                beats: [
                    // w1 — opening
                    ScenarioBeat(
                        id: "w1",
                        emoji: "🧩",
                        title: "The blank page",
                        story: "Aliens or detectives? First-person diary or fairy tale? Nothing feels right, so you decide to give AI a shot.",
                        aiMove: "You're frozen between ideas. Before diving in, decide what role you want AI to play — is it writing for you, or helping you find your own direction?",
                        whyItMatters: "How you use AI from the start determines whether the final story feels like yours. The first choice matters more than any edit later.",
                        inlineChat: [
                            ChatLine(text: "I have a short story due tomorrow and I literally cannot start. I have like a million ideas and none of them feel right 😩", isUser: true),
                            ChatLine(text: "Writer's block is the worst! What are the ideas rattling around in your head — even the half-formed ones? Let's look at them together...", isUser: false)
                        ],
                        choices: [
                            StoryChoice(prompt: "Have the AI write the story for you — you're desperate to get it done", targetBeatID: "w2"),
                            StoryChoice(prompt: "Brainstorm with the AI — use it as a creative partner, but you'll write the story", targetBeatID: "w3")
                        ]
                    ),
                    // w2 — AI writes the story
                    ScenarioBeat(
                        id: "w2",
                        emoji: "🤖",
                        title: "The ghostwriter",
                        story: "You type a prompt explaining your assignment and a couple of your story ideas, then ask the AI to 'write a short story for me.' Within seconds, paragraphs start appearing. Your eyes widen as the AI neatly crafts an introduction, a plot twist, and a tidy conclusion. In less than a minute, there's a complete story on the screen.\n\nYou scroll through it. The story is... fine. It makes sense, and the characters do things, but something feels off. It's generic — like reading a story from someone who doesn't know you at all. The plot is predictable, and the style doesn't quite sound like you. It might get a passing grade, but would your teacher or friends believe you wrote it?",
                        aiMove: "The AI produced a complete story in seconds. It's grammatically fine but feels generic — no personality, no you. Now you decide: hand it in or make it yours.",
                        whyItMatters: "AI can generate text fast, but speed doesn't equal quality. A story without your voice is just words on a page — technically correct but emotionally empty.",
                        inlineChat: [
                            ChatLine(text: "Can you just write the whole essay for me? Make it a school mystery with a plot twist and ending.", isUser: true),
                            ChatLine(text: "Absolutely — here's a complete draft:\n\nIt was a dark and stormy day at Maplewood Middle School. Something very mysterious had happened, and everyone was very surprised...", isUser: false)
                        ],
                        choices: [
                            StoryChoice(prompt: "Submit it as-is — it's not perfect, but it's done", targetBeatID: "w4"),
                            StoryChoice(prompt: "Make it your own — edit it, rewrite parts, add your personal flair", targetBeatID: "w5")
                        ]
                    ),
                    // w3 — brainstorm with AI
                    ScenarioBeat(
                        id: "w3",
                        emoji: "💬",
                        title: "The brainstorm",
                        story: "You decide to use the AI as a creative partner rather than a ghostwriter. You type, 'I have to write a short story and I have too many ideas. Can I brainstorm with you?' The AI replies: 'Sure! Tell me what ideas you have, and let's pick one and flesh it out.'\n\nYou start listing your half-formed ideas: a space adventure, a mystery in your school, and a fantasy world with talking trees. The AI asks questions about each idea — it's like having a friendly writing coach. 'Which idea excites you most?' it prompts. You find yourself drawn to the mystery-in-school idea.",
                        storyAfterChat: "With the AI's help, you narrow it down: a detective story set in your school's library, involving a missing painting. It helps you outline a beginning, a middle with a twist, and an end. You toss in your own twist — what if the painting was hidden in plain sight all along? Before you know it, the blank page is filled with notes and a direction for your story.",
                        aiMove: "You used AI as a creative partner — bouncing ideas, narrowing down, and building an outline together. The blank page isn't blank anymore.",
                        promptToTry: "You are a creative writing coach who asks one question at a time. I am a teenager with too many story ideas and no clear direction. Help me narrow down my ideas by asking thoughtful questions.",
                        whyItMatters: "AI shines as a brainstorming partner. By asking questions instead of writing for you, it helped you discover what you actually want to say.",
                        inlineChat: [
                            ChatLine(text: "I have three story ideas: space adventure, school mystery, or talking trees fantasy. I can't choose!", isUser: true),
                            ChatLine(text: "Fun options! Which one do you find yourself daydreaming about most when you're bored in class? 😄", isUser: false),
                            ChatLine(text: "Honestly... the school mystery. I like figuring things out.", isUser: true),
                            ChatLine(text: "Go with your gut! Is there somewhere specific in your school that feels a bit mysterious — somewhere with a story to tell?", isUser: false),
                            ChatLine(text: "The old library upstairs. Nobody goes there anymore.", isUser: true),
                            ChatLine(text: "Perfect setting. Now — what goes missing? Something valuable, something personal, or something strange?", isUser: false)
                        ],
                        choices: [
                            StoryChoice(prompt: "Co-write with AI — have it help expand the outline scene by scene", targetBeatID: "w6"),
                            StoryChoice(prompt: "Write it solo — take your outline and write the story on your own", targetBeatID: "w7")
                        ]
                    ),
                    // w4 — ending: submit AI story unchanged
                    ScenarioBeat(
                        id: "w4",
                        emoji: "😕",
                        title: "Lacks voice",
                        story: "You sigh, close the laptop, and decide to accept the AI's work. The next day, you hand in the paper. Your teacher raises an eyebrow at the neat but impersonal tale. 'Is this really your best work?' she asks. You shrug awkwardly. It's hard to feel proud of something you didn't truly write. You get a passing grade, but the comments say 'lacks voice' and 'feels a bit formulaic.'\n\nYour friends discuss their stories — one wrote about a personal memory, another spun a wild fantasy — and you feel a pang of regret. Sure, you avoided an all-nighter, but you also missed the chance to put yourself into the story.",
                        aiMove: "You submitted the AI's work as your own. The grade was passing, but the feedback stung — no voice, no personality. The easy path wasn't the rewarding one.",
                        whyItMatters: "Your voice matters. Turning in a story you didn't really write may feel like a relief, but it won't feel like your achievement. In creative work, your unique voice is the real reward."
                    ),
                    // w5 — ending: edit and personalise
                    ScenarioBeat(
                        id: "w5",
                        emoji: "✨",
                        title: "Your voice, your story",
                        story: "You roll up your sleeves and dive back into the draft. The AI's version gives you a baseline, but now you add what it was missing: your ideas and style. You change the main character, insert a funny incident from last summer, and rewrite the ending to be less predictable. With each edit, the story sounds more like something you'd write. It has your humour, your perspective, your creativity.\n\nIn class, you hand in the edited story. When you get it back, there's a note from the teacher: 'Great improvement! I can hear your voice in this.' You grin, knowing you earned that.",
                        aiMove: "You took the AI's draft and made it yours — adding personal incidents, your humour, and a less predictable ending. The teacher noticed the difference.",
                        whyItMatters: "AI can jumpstart creativity, but you remain the author. The story worked because you made it your own. AI helped shape the clay, but you did the sculpting."
                    ),
                    // w6 — ending: co-write with AI
                    ScenarioBeat(
                        id: "w6",
                        emoji: "🤝",
                        title: "The writing partner",
                        story: "You decide to keep the momentum by writing alongside the AI. 'Let's write the first paragraph,' you suggest, using the outline as a guide. The AI generates a lively opening, and you tweak a sentence or two. For the next scene, you write a few lines yourself and then ask the AI to continue. It's a back-and-forth dance — the AI expands a dialogue exchange, then you add a personal joke. When a line feels off, you edit it or tell the AI to try again.\n\nIn a couple of hours, you have a full first draft of your mystery story. Reading through it, you recognise a lot of your ideas and style, but also see places where the AI's suggestions helped — a cool metaphor here, a sharper sentence there. Your teacher is pleased. You did put in creative effort, and you met your deadline with a story you're not only relieved but also proud to turn in.",
                        aiMove: "You wrote the story scene by scene with AI — a back-and-forth dance. You stayed in control with your outline, editing AI's suggestions and adding your own ideas.",
                        whyItMatters: "Co-writing with AI is like having a supercharged collaborator. By providing an outline and making edits, you ensured the story still felt like yours while moving faster."
                    ),
                    // w7 — ending: write solo with outline
                    ScenarioBeat(
                        id: "w7",
                        emoji: "🎉",
                        title: "All yours",
                        story: "You close the AI chat, now brimming with ideas and a clear roadmap for your story. Armed with the outline and all the twists and character notes you brainstormed, you begin typing. The words flow easier now. When you get to a tricky transition, you pause and think about the AI's questions: 'What is my character feeling here?' You can answer that yourself.\n\nIn a couple of hours, you have a draft. It's rough in places, but it's entirely your creation. When you turn it in, your teacher returns it with a big smile and a note: 'Excellent work! Creative plot and great voice.'",
                        aiMove: "With a solid outline from brainstorming, you wrote the entire story yourself. Every word came from you, and the result was deeply satisfying.",
                        whyItMatters: "Brainstorm boost — AI served as your creative coach for the hardest part: getting started. 100% of the writing was yours. The best of both worlds."
                    )
                ],
                firstBeatID: "w1",
                bestUseMoves: [
                    "When you decide to use AI for writing, always remember, quality over convenience; a bit more effort makes the story truly yours.",
                    "Share your half-formed ideas with AI and let it ask questions; it can help you figure out what you actually want to say."
                ],
                watchOuts: [
                    "Don't submit AI-generated text without adding your own voice; it reads as generic.",
                    "Don't let speed replace craft; a fast story that 'lacks voice' isn't worth the time saved."
                ]
            )

        }
    }
}
