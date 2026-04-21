//
//  GroceryCategoryResponseDTO+Extension.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 14/04/2026.
//

import Foundation
import Vapor
import GroceryAppSharedDTO


extension GroceryCategoryResponseDTO: @retroactive Content, @unchecked Sendable {
    
    init?(_ groceryCategory: GroceryCategory) {
        guard let id = groceryCategory.id else { return nil }
        self.init(id: id, title: groceryCategory.title, colorCode: groceryCategory.colorCode)
    }
    
    init?(groceryCategoryWithItems: GroceryCategory) {
        guard let id = groceryCategoryWithItems.id else { return nil }
        self.init(id: id, title: groceryCategoryWithItems.title, colorCode: groceryCategoryWithItems.colorCode, items: groceryCategoryWithItems.items.compactMap(GroceryItemResponseDTO.init))
    }
}

