//
//  GroceryController.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 14/04/2026.
//

import Foundation
import Vapor
import Fluent
import GroceryAppSharedDTO

struct GroceryController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        
        // api/users/:userId [Protected Routes]
        let api = routes
            .grouped("api", "users", ":userId")
            .grouped(JSONWebTokenAuthenticator())
        
        // POST: /api/users/:userId/grocery-categories
        api.post("grocery-categories", use: saveGroceryCategory)
        
        // GET: /api/users/:userId/grocery-categories
        api.get("grocery-categories", use: getGroceryCategoriesByUser)
        
        // DELETE: /api/users/:userId/grocery-categories/:groceryCategoryId
        api.delete("grocery-categories", ":groceryCategoryId", use: deleteGroceryCategoryById)
        
        // POST: /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items
        api.post("grocery-categories", ":groceryCategoryId" , "grocery-items", use: saveGroceryItem)
        
        // GET: /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items
        api.get("grocery-categories", ":groceryCategoryId" , "grocery-items", use: getGroceryItemsByGroceryCategory)
        
        // DELETE: /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items/:groceryItemId
        api.delete("grocery-categories", ":groceryCategoryId" , "grocery-items", ":groceryItemId", use: deleteGroceryItemById)
        
        // OPTIONAL: get all categories with their items
        // /api/users/:userId/grocery-categories-with-items
        api.get("grocery-categories-with-items", use: getGroceryCategoriesWithItems)
        
    }
    
    // MARK: Grocery Categories
    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        // get user id
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // DTO for request
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)
        
        let groceryCategory = GroceryCategory(title: groceryCategoryRequestDTO.title, colorCode: groceryCategoryRequestDTO.colorCode, userId: userId)
        
        try await groceryCategory.save(on: req.db)
        
        // DTO for response
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        return groceryCategoryResponseDTO
    }
    
    func getGroceryCategoriesByUser(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId) // filter grocery categories by user id
            .all() // make sure fethe all
            .compactMap { GroceryCategoryResponseDTO($0) } // use compact map to avoid any nil's and init every filtered record as GroceryCategoryResponseDTO
    }
    
    func deleteGroceryCategoryById(req: Request) async throws -> GroceryCategoryResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self)
        else {
            throw Abort(.badRequest)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        try await groceryCategory.delete(on: req.db)
        guard let groceryCategoryDTO = GroceryCategoryResponseDTO(groceryCategory) else { throw Abort(.internalServerError) }
        return groceryCategoryDTO
    }
    
    // MARK: Grocery Items
    
    func saveGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // find user
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        // find grocery category
        guard let _ = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        let groceryItemRequestDTO = try req.content.decode(GroceryItemRequestDTO.self)
        let groceryItem = GroceryItem(title: groceryItemRequestDTO.title,
                                      price: groceryItemRequestDTO.price,
                                      quantity: groceryItemRequestDTO.quantity,
                                      groceryCategoryId: groceryCategoryId)
        
        try await groceryItem.save(on: req.db)
        
        guard let item = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        
        return item
    }
    
    func getGroceryItemsByGroceryCategory(req: Request) async throws -> [GroceryItemResponseDTO] {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let _ = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        let items = try await GroceryItem.query(on: req.db)
            .filter(\.$category.$id == groceryCategoryId)
            .all()
            .compactMap(GroceryItemResponseDTO.init)
        
        return items
    }
    
    func deleteGroceryItemById(req: Request) async throws -> GroceryItemResponseDTO {
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) ,
              let groceryItemId = req.parameters.get("groceryItemId", as: UUID.self)
        else {
            throw Abort(.badRequest)
        }
        
        // make sure grocery category exists and belong to a user.
        guard let _ = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        guard let groceryItem = try await GroceryItem.query(on: req.db)
            .filter(\.$category.$id == groceryCategoryId)
            .filter(\.$id == groceryItemId)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        try await groceryItem.delete(on: req.db)
        guard let responseDTO = GroceryItemResponseDTO(groceryItem) else { throw Abort(.internalServerError) }
        return responseDTO
    }
    
    // MARK: [Optional] Grocery Categories & Items
    
    func getGroceryCategoriesWithItems(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .with(\.$items)
            .all()
            .compactMap(GroceryCategoryResponseDTO.init(groceryCategoryWithItems:))
    }
}
