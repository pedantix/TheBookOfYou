//
//  FilteredFetchRequest.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/27/23.
//

import SwiftUI
import CoreData

struct FilteredFetchRequest<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>

    let content: (T) -> Content

    var body: some View {
        ForEach(fetchRequest, id: \.self) { managedObject in
            content(managedObject)
        }
    }

    init(fetchRequest: NSFetchRequest<T>, @ViewBuilder content: @escaping (T) -> Content) {
        _fetchRequest = FetchRequest(fetchRequest: fetchRequest)
        self.content = content
    }
}
