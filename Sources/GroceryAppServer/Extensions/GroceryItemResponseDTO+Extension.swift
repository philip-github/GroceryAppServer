//
//  GroceryItemResponseDTO+Extension.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 18/04/2026.
//

import Foundation
import Vapor
import GroceryAppSharedDTO

extension GroceryItemResponseDTO: @retroactive Content, @unchecked Sendable {
    init?(_ groceryItem: GroceryItem) {
        guard let id = groceryItem.id else { return nil }
        self.init(id: id, title: groceryItem.title, price: groceryItem.price, quantity: groceryItem.quantity)
    }
}
