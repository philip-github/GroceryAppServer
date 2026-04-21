//
//  User.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 06/04/2026.
//

import Foundation
import Vapor
import Fluent

final class User: Model, Content, Validatable, @unchecked Sendable {
    static let schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
    
    static func validations(_ validations: inout Validations) {
        // validate for non-empty username
        validations.add("username", as: String.self, is: !.empty, customFailureDescription: "Username field cannot be empty.")
        // validate for non-empty password
        validations.add("password", as: String.self, is: !.empty, customFailureDescription: "Password field cannot be empty.")
        // validate password to be between 6 to 10 characters
        validations.add("password", as: String.self, is: .count(6...10), customFailureDescription: "Password must be between 6 to 10 characters long.")
    }
}
