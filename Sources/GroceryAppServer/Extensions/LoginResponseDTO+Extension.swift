//
//  LoginResponseDTO+Extension.swift
//  GroceryAppServer
//
//  Created by Philip Al-Twal on 10/04/2026.
//

import Foundation
import Vapor
import GroceryAppSharedDTO

extension LoginResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}
