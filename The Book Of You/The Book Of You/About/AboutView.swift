//
//  AboutView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/8/23.
//

import SwiftUI

struct AboutView: View {
    @StateObject private var dataService = AboutDataService()

    var body: some View {
        List {
            aboutHeadingContent
                .listRowSeparator(.hidden)
            repositoriesView
                .listRowSeparator(.hidden)
            citationsView
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .listRowSeparatorTint(.clear)
    }

    @ViewBuilder
    private var aboutHeadingContent: some View {
        HStack {
            Spacer()
            Text("About")
                .font(.title)
                .padding(0)
            Spacer()
        }
        // swiftlint:disable line_length
        Text("""
        \tIt's critically important when making anything to show your work and credit the work of others in order to acknowledge your sources for both ethical and inspirational reasons. To that end I have setup this about section as one of the very first features that I built. This section is divided into two parts, inspiration and resources used.

        \tIn the case of inspirations I have opted for MLA format that will be listed below. Please read these books, articles and other sources as I have found them immensly helpful and am using them to build this app out of.

        \tIn the case of resources, for this app the Swift Package Manager will be used on iOS so a list of the GitHubs, their tilte and their function will be all that is provided.

        * I may at any point opt to change the way I list resources or inspirations as this project evolves. However I will seek to credit those that are due.
        """)
        // swiftlint:enable line_length
        .font(.body)
        .padding(.fs5)
    }

    @ViewBuilder
    private var repositoriesView: some View {
        Text("Repositories")
            .font(.title2)
        ForEach(dataService.githubData) { repo in
            VStack(alignment: .leading) {
                Text(repo.title)
                    .font(.subheadline)
                    .padding([.bottom], .fs3)
                Text(repo.function)
                    .padding([.bottom], .fs4)
                Link(repo.github, destination: URL(string: repo.github)!)
                    .padding([.bottom], .fs3)
            }
        }
    }

    @ViewBuilder
    private var citationsView: some View {
        Text("Citations")
            .font(.title2)
        VStack(alignment: .leading) {
            ForEach(dataService.citations, id: \.self) { citation in
                Text("- \(citation)")
                    .font(.body)
                    .padding([.bottom], .fs3)
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
