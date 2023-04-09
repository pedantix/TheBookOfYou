//
//  CloudDefaults.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/8/23.
//

import Foundation
import SwiftUI

extension String {
    static let identityGoalsKey = "identityGoals"
}

/*


private let cloudJsonEncoder = JSONEncoder()
private let cloudJsonDecoder = JSONDecoder()
private class EmptyObs: NSObject, ObservableObject {}

@propertyWrapper
class CloudDefaults<ValueType: Codable>: DynamicProperty {
    let key: String
    let defaultValue: ValueType
    @State private var value: ValueType

    init(key: String, defaultValue: ValueType) {
        self.key = key
        self.defaultValue = defaultValue
        self._value = State(wrappedValue: defaultValue)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(change(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )
        viewLogger.info("add watcher")
    }

    deinit {
        viewLogger.info("Removing observer for \(key)")
        NotificationCenter.default.removeObserver(self)
    }

    @objc func change(_ note: Notification) {
        guard note.name == NSUbiquitousKeyValueStore.didChangeExternallyNotification else {
            return viewLogger.error("Received wrong notification in CloudDefaults property wrapper")
        }
        guard let userInfo = note.userInfo else {
            return viewLogger.error("Received note without userInfo for cloud defaults")
        }
        guard let changeKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String],
            changeKeys.contains(key) else {
            return viewLogger.error("Received note without key \(key) for cloud defaults")
        }

        NSUbiquitousKeyValueStore.default.synchronize()

        Task {
            await MainActor.run(body: {
                value = wrappedValue
            })
        }
    }

    var wrappedValue: ValueType {
        get {
            guard let data = NSUbiquitousKeyValueStore.default.object(forKey: key) as? Data else { return defaultValue }
            return (try? cloudJsonDecoder.decode(ValueType.self, from: data)) ?? defaultValue
        }
        set {
            let data = try? cloudJsonEncoder.encode(newValue)
            value = wrappedValue
            NSUbiquitousKeyValueStore.default.set(data, forKey: key)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }

    var projectedValue: Binding<ValueType> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
*/
