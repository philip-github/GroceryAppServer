//
//  AuthPayload.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 07/04/2026.
//

import Foundation
import JWT

struct AuthPayload: JWTPayload {
    typealias Payload = AuthPayload
    
    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case userID     = "uid"
    }
    
    var expiration: ExpirationClaim
    var userID: UUID
    
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}
