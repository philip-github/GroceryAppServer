//
//  JSONWebTokenAuthenticator.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 20/04/2026.
//

import Foundation
import Vapor

struct JSONWebTokenAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {
        try await request.jwt.verify(as: AuthPayload.self)
    }
}
