//
//  IntroView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import CloudStorage
import SwiftUI

// swiftlint:disable line_length
let introText = """
\tI believe in the power of habit, identity, and focus. The purpose of building this app was to reassert my identity as an app developer and software engineer and create a feature to help me make habits and strengthen my identity. I believe in goals, dreams, and consistency.

\tGood habits are a reflection of one's identity. We are who we are because of all our actions yesterday, and today is tomorrow's yesterday. Today is the day we can get just 1% better than yesterday.

\tTo that end, I built this journal to help me chronicle and build my habits. I hope it helps you too.
"""

let processImprovement = """
\tThe importance of aggregating incremental change is a topic heavily emphasized in James Clear's book and on his along with other websites. He speaks of the story of the British cycling team having a coach with a talented team that did not win. The coach's approach to fixing this was finding minor optimizations in everything the team did. These optimizations included equipment, nutrition, training regimens, and apparel. These small changes led to victory after victory because their effects stacked up.
\tBuilding habits is the same way. At first, they are small changes, some with noticeable positive effects and others with more difficult-to-see merit. But over time, these things add up. I invite you to join me in embracing a lifestyle of continued improvement via an aggregate change to become what you desire to see in the mirror. It will not happen overnight.
"""

let reflectionText = """
\tEvery day we can reflect on our day and write to write. I think about what went well and what did not and reflect on how I can improve it.
"""

let vacationModeText = """
\tEveryone Needs a Vacation from time to time. These do not need to signal a new chapter in our life unless it changes our identity or goals. For these sorts of walkabout or sabbatical situations, please turn on the following "Vacation Mode"  to create a chapter. If you want to journal a reflection for the occasional day off, hit the vacation mode on the edit screen of your current day.
"""

let identityText = """
\tGoals come in many forms: financial, learning, and other accomplishments. However, goals are flimsy things to work for. For two reasons, long-term goals are often too far away to be attainable to the exhausted mind, and we, as people, are better off dealing with short-term risk-reward situations. For this reason, I wanted to focus on habits in my journey habits start small and we can build on them until they are just part of us which feeds into the concept of identity.

\tOnce I determined how I wanted to develop my inner and outer identity, I realized this could bloat into many goals. I reflected on Warren Buffet's 5:25 rule, where you list out twenty-five goals and eliminate all but five of them, and the five you focus on. I wanted to become "literate, fit, studious, an excellent engineer, and cultured." For this reason, I have set up the "Goals & Identity" section to set an intention on what kind of identity I want to cultivate.

\tTo accomplish this, I created a concept of chapters in the journal. You can list out all of the Identity goals you want, but you can only focus on so many. Some people may want to have ten or two, so I made this adjustable below.

\tEach Identity Goal will produce, amongst other things(features yet to come), a text section you can write in daily.
"""
// swiftlint:enable line_length

struct IntroView: View {
    @EnvironmentObject var navStore: NavStore
    @CloudStorage(.identityGoalsKey) private var goals = 5

    var body: some View {
        List {
            ZStack {
                ClickableBackgroundView {

                }
                VStack {
                    IntroEntryView(title: "Introduction", bodyText: introText)
                    IntroEntryView(title: "Aggregate Change", bodyText: processImprovement)
                    IntroEntryView(title: "Daily Reflection", bodyText: reflectionText)
                    IntroEntryView(title: "Goals & Identity", bodyText: identityText) {
                        Stepper("Identity Goals: \(goals)", value: $goals, in: 1...1000)
                    }
                    IntroEntryView(title: "Vacation Mode", bodyText: vacationModeText)
                }
                .listRowSeparator(.hidden)
            }
            .padding(0)
        }
        .listStyle(.plain)
        .padding(0)
        .toolbar {
            Button("About") {
                viewLogger.info("Navigate To About")
                navStore.navigate(to: .about)
            }
            Button("Index") {
                viewLogger.info("Navigate To Index")
                navStore.navigate(to: .about)
            }
        }
    }
}

private let defaultFooterContent: () -> EmptyView = { EmptyView() }
private struct IntroEntryView<ContentView: View>: View {
    typealias Content = () -> ContentView
    let title: String
    let bodyText: String
    let footerContent: Content

    init(title: String, bodyText: String, footer: @escaping Content = defaultFooterContent) {
        self.title = title
        self.bodyText = bodyText
        self.footerContent = footer
    }

    var body: some View {
        Text(title)
            .font(.title)
            .padding(.fs6)
        Text(bodyText)
            .font(.body)
            .padding(.fs5)
        footerContent()
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
