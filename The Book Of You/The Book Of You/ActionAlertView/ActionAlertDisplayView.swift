//
//  ActionAlertDisplayView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/28/23.
//

import SwiftUI

struct ActionAlertData {
    let title: String
    let message: String
    let sfSymbolText: String
}

struct ActionAlertDisplayView: View {
    let data: ActionAlertData

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
    static var previews: some View {
        ActionAlertDisplayView(data: .init(
            title: "Not Added",
            message: "The list was already full, please remove an object from the list form in order to add",
            sfSymbolText: "square.3.layers.3d.down.right.slash")
        )
    }
}
