//
//  CreateUserTableMigration.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 06/04/2026.
//

import Foundation
import Fluent

final class CreateUserTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required).unique(on: "username")
            .field("password", .string, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
