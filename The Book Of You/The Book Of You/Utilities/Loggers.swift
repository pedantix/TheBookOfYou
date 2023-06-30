//
//  Loggers.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import Logging
import Foundation

let viewLogger = Logger(label: "View")
let viewModelLogger = Logger(label: "ViewModel")
let dataServiceLogger = Logger(label: "DataService")
let persistenceLogger = Logger(label: "Persistence")
let appLogger = Logger(label: "App")

extension Logger {
    func contextError(_ error: NSError, _ customMessage: String = "", file: String = #file, line: Int = #line) {
        let msgStamp: String
        if !customMessage.isBlank {
            msgStamp = ""
        } else {
            msgStamp = "Custom Message: \(customMessage),"
        }
        let errorText = " Err: \(error), LocalDesc: \(error.localizedDescription), UserInfo: \(error.userInfo)"
        self.error("\(file):\(line) -> \(msgStamp) there was an error with the context. \(errorText)")
    }
}
