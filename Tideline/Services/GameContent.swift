import Foundation

/// Static content for Tideline's mini-games — the True/False question pool
/// is the same 10 questions from the original prototype.
enum GameContent {
    static let trueFalsePool: [TrueFalseQuestion] = [
        TrueFalseQuestion(
            statement: "About 60% of the human body has been estimated to contain microplastic particles.",
            answer: true,
            explanation: "Recent studies have detected microplastic particles in human blood, lungs, and other tissue, with some estimates suggesting the majority of people carry measurable amounts."
        ),
        TrueFalseQuestion(
            statement: "Once a plastic bottle is placed in a recycling bin, it's guaranteed to be turned into a new bottle.",
            answer: false,
            explanation: "Contamination, sorting limits, and market demand mean a large share of collected plastic is still landfilled, incinerated, or downcycled into lower-value products."
        ),
        TrueFalseQuestion(
            statement: "Microplastics have been found in ocean water, soil, and drinking water.",
            answer: true,
            explanation: "Microplastics are now considered ubiquitous — they've turned up in seawater, freshwater, agricultural soil, and treated tap and bottled water alike."
        ),
        TrueFalseQuestion(
            statement: "Plastic labeled with a recycling symbol (the chasing arrows) is always recyclable in your curbside bin.",
            answer: false,
            explanation: "The number inside the arrows identifies the resin type, not a promise of recyclability — many resin codes, like PS (6) and PVC (3), are rarely accepted curbside."
        ),
        TrueFalseQuestion(
            statement: "A single-use plastic straw typically takes centuries to fully break down in the environment.",
            answer: true,
            explanation: "Most plastics don't biodegrade the way organic matter does — they photodegrade into ever-smaller fragments over hundreds of years instead of disappearing."
        ),
        TrueFalseQuestion(
            statement: "Switching from a disposable water bottle to a reusable one has no meaningful effect on your personal plastic footprint.",
            answer: false,
            explanation: "A single reusable bottle can replace hundreds of disposable ones a year, making it one of the highest-impact swaps an individual can make."
        ),
        TrueFalseQuestion(
            statement: "Flexible film plastics, like chip bags and bread bags, can usually go in a standard curbside recycling bin.",
            answer: false,
            explanation: "Thin films jam sorting machinery at most facilities, so they're typically routed to special store drop-off programs instead of curbside bins."
        ),
        TrueFalseQuestion(
            statement: "Marine animals can mistake small plastic fragments for food.",
            answer: true,
            explanation: "Fragments and pellets are often similar in size and color to prey, leading to ingestion by fish, seabirds, and other marine life."
        ),
        TrueFalseQuestion(
            statement: "Rinsing food residue off plastic containers before recycling them makes no difference.",
            answer: false,
            explanation: "Greasy or food-contaminated items can spoil an entire batch of otherwise recyclable material at sorting facilities."
        ),
        TrueFalseQuestion(
            statement: "Aluminum cans and glass jars can typically be recycled indefinitely without losing quality.",
            answer: true,
            explanation: "Unlike most plastics, which degrade in quality with each reprocessing, aluminum and glass can be recycled repeatedly with little to no quality loss."
        ),
    ]

    /// "Sort the Plastic" pool: Tideline's 20 seeded items (classified
    /// recyclable/not from their recyclability field's leading word — only
    /// "High" is treated as curbside-recyclable, matching how conservative
    /// real curbside programs are) plus a few common non-plastic recyclables
    /// for variety, matching the prototype's mix.
    static let sortPool: [SortableItem] = [
        SortableItem(name: "Plastic water bottle", subtitle: "PET (#1)", emoji: "🧴", recyclable: true),
        SortableItem(name: "Plastic straw", subtitle: "Usually PP (#5)", emoji: "🥤", recyclable: false),
        SortableItem(name: "Plastic grocery bag", subtitle: "Film plastic", emoji: "🛍️", recyclable: false),
        SortableItem(name: "Sandwich / zip-top bag", subtitle: "Film plastic", emoji: "🥪", recyclable: false),
        SortableItem(name: "Plastic utensils", subtitle: "Usually PS (#6)", emoji: "🍴", recyclable: false),
        SortableItem(name: "Styrofoam cup / container", subtitle: "PS (#6)", emoji: "☕️", recyclable: false),
        SortableItem(name: "Plastic takeout container", subtitle: "Mixed plastics", emoji: "🥡", recyclable: false),
        SortableItem(name: "Produce bag", subtitle: "Thin film plastic", emoji: "🥬", recyclable: false),
        SortableItem(name: "Bottle cap", subtitle: "Recyclable only if on bottle", emoji: "🔘", recyclable: false),
        SortableItem(name: "Shampoo / detergent bottle", subtitle: "HDPE (#2)", emoji: "🧴", recyclable: true),
        SortableItem(name: "Snack / chip bag", subtitle: "Mixed foil + plastic", emoji: "🍟", recyclable: false),
        SortableItem(name: "Cold drink cup", subtitle: "Mixed plastics", emoji: "🥤", recyclable: false),
        SortableItem(name: "Coffee cup plastic lid", subtitle: "Mixed plastics, small", emoji: "🫖", recyclable: false),
        SortableItem(name: "Plastic toothbrush", subtitle: "Mixed materials", emoji: "🪥", recyclable: false),
        SortableItem(name: "Disposable razor", subtitle: "Mixed materials", emoji: "🪒", recyclable: false),
        SortableItem(name: "Six-pack rings", subtitle: "HDPE, mixed", emoji: "🔗", recyclable: false),
        SortableItem(name: "Bubble wrap", subtitle: "Film plastic", emoji: "🫧", recyclable: false),
        SortableItem(name: "Plastic milk jug", subtitle: "HDPE (#2)", emoji: "🥛", recyclable: true),
        SortableItem(name: "Yogurt cup", subtitle: "PP (#5), small", emoji: "🥣", recyclable: false),
        SortableItem(name: "Cleaning product bottle", subtitle: "HDPE (#2)", emoji: "🧽", recyclable: true),
        SortableItem(name: "Aluminum can", subtitle: "Metal", emoji: "🥫", recyclable: true),
        SortableItem(name: "Glass jar", subtitle: "Glass", emoji: "🍯", recyclable: true),
        SortableItem(name: "Cardboard box", subtitle: "Paper fiber", emoji: "📦", recyclable: true),
    ]
}
