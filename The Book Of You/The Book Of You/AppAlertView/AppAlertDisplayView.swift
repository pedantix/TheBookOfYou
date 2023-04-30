//
//  ActionAlertDisplayView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/28/23.
//

import SwiftUI

struct AppAlertDisplayView: View {
    let data: AppAlert

    var body: some View {
        ZStack {
            VStack(spacing: .fs6) {
                Text(data.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Image(systemName: data.sfSymbolText)
                    .font(.system(size: .fs11))
                    .fontWeight(.thin)
                    .foregroundStyle(.ultraThinMaterial)
                Text(data.message)
                    .font(.callout)
                    .fontWeight(.bold)
            }
            .padding()
        }
        .foregroundStyle(.ultraThinMaterial)
        .background(Color.surface)
        .cornerRadius(.fs5)
        .frame(maxWidth: 380)
    }
}

struct ActionAlertDisplayView_Previews: PreviewProvider {
    private static let examples: [(String, AppAlert)] = [
        ("Duplicate Chapter Alert", .duplicateChapterAlert),
        ("Max Goals Alert", .maxGoalsAlert)
    ]

    static var previews: some View {
        Group {
            ForEach(examples, id: \.0) {
                AppAlertDisplayView(data: $0.1)
                    .environment(\.colorScheme, .dark)
                    .previewDisplayName("\($0.0) - Dark")
                AppAlertDisplayView(data: $0.1)
                    .environment(\.colorScheme, .light)
                    .previewDisplayName("\($0.0) - Light")
            }
        }
    }
}
