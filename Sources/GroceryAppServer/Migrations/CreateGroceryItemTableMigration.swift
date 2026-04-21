//
//  CreateGroceryItemTableMigration.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 18/04/2026.
//

import Foundation
import Fluent

final class CreateGroceryItemTableMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("grocery_items")
            .id()
            .field("title", .string, .required)
            .field("price", .double, .required)
            .field("quantity", .int, .required)
            .field("grocery_category_id", .uuid, .required, .references("grocery_categories", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("grocery-items").delete()
    }
}
