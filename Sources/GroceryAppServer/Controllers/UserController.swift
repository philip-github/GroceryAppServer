//
//  UserController.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 06/04/2026.
//

import Foundation
import Vapor
import Fluent
import GroceryAppSharedDTO

struct UserController: RouteCollection {

    func boot(routes: any Vapor.RoutesBuilder) throws {
        let api = routes.grouped("api")
        // /api/register
        api.post("register", use: register)
        // /api/login
        api.post("login", use: login)
    }
    
    func login(req: Request) async throws -> LoginResponseDTO {
        // decode request to user object
        let user = try req.content.decode(User.self)
        
        // validate if username exist in database
        guard let existingUser = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() else {
            return LoginResponseDTO(error: true, reason: "User name is not found")
        }
        
        do {
            // validate password
            let result = try await req.password.async.verify(user.password, created: existingUser.password)
            if !result {
                return LoginResponseDTO(error: true, reason: "Incorrect Password")
            }
            
            // generate JSON WEB TOKEN (JWT)
            let authPayload = try AuthPayload(expiration: .init(value: .distantFuture), userID: existingUser.requireID())
            return try await LoginResponseDTO(error: false, token: req.jwt.sign(authPayload), userId: existingUser.requireID())
        } catch {
            throw error
        }
    }

    func register(req: Request) async throws -> RegisterResponseDTO {
        // validate the user
        try User.validate(content: req)

        let user = try req.content.decode(User.self)
        
        // check if user already exists
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            throw Abort(.conflict, reason: "Username is already taken.")
        }
        
        // hash password
        user.password = try await req.password.async.hash(user.password)
        
        // save the user to database
        try await user.save(on: req.db)
        
        return RegisterResponseDTO(error: false)
    }
}
