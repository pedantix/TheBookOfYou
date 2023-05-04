//
//  Validator.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/1/23.
//

import Foundation

protocol Validator: AnyObject {
    associatedtype TypeToValidate
    associatedtype ValidationError: Error & Equatable
    associatedtype Success: Equatable

    func validate(_ object: TypeToValidate) -> Result<Success, ValidationError>
}
