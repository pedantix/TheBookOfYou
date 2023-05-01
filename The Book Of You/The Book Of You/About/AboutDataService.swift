//
//  AboutData.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/8/23.
//

import Foundation

class GithubData: Codable, Identifiable {
    let github: String
    let title: String
    let function: String
}

class AboutDataService: ObservableObject {
    @Published var githubData: [GithubData] = []
    @Published var citations: [String] = []
    @Published var loadErrors = [String]()

    init() {
        guard let reposUrl = Bundle.main.url(forResource: "Repositories", withExtension: "plist") else {
            loadErrors.append("Could not get Repositories.plist from bundle")
            dataServiceLogger.error("Error loading url for Repositories.plist from main bundle")
            return
        }

        let plistDecoder = PropertyListDecoder()

        do {
            let repoData = try Data(contentsOf: reposUrl)
            githubData = try plistDecoder.decode([GithubData].self, from: repoData)
        } catch {
            loadErrors.append("Could not read data from Repositories URL")
            dataServiceLogger.error("Could not read data from Repositories URL \(error.localizedDescription)")
        }

        guard let citationsUrl = Bundle.main.url(forResource: "CitedWorks", withExtension: "plist") else {
            loadErrors.append("Could not get CitedWorks.plist from bundle")
            dataServiceLogger.error("Error loading url for CitedWorks.plist from main bundle")
            return
        }

        do {
            let repoData = try Data(contentsOf: citationsUrl)
            citations = try plistDecoder.decode([String].self, from: repoData)
        } catch {
            loadErrors.append("Could not read data from CitedWorks URL")
            dataServiceLogger.error("Could not read data from CitedWorks URL \(error.localizedDescription)")
        }
    }
}
