//
//  CreateGroceryCategoryTableMigration 2.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 16/04/2026.
//


import Foundation
import Fluent

final class CreateGroceryCategoryTableMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema("grocery_categories")
            .id()
            .field("title", .string, .required)
            .field("color_code", .string, .required)
            .field("user_id", .uuid, .references("users", "id"))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("grocery_categories").delete()
    }
}
