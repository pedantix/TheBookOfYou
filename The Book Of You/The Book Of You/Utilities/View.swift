//
//  View.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/28/23.
//

import SwiftUI

extension View {
    typealias CancelAction = () -> Void

    func cancelableKeyboard(cancelAction: @escaping CancelAction) -> some View {
        toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(role: .cancel, action: cancelAction) {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}
