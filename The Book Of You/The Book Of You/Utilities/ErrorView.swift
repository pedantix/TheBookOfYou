//
//  ErrorView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/21/23.
//

import SwiftUI

struct ErrorView: View {
    let reasons: [String]

    var body: some View {
        VStack {
            Text("Sorry, there has been an error dispaying your view")
            ForEach(reasons, id: \.self) {
                Text("Reason: \($0)")
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(reasons: ["You made a mistake", "fool!"])
    }
}
