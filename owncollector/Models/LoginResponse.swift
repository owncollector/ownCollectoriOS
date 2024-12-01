//
//  LoginResponse.swift
//  owncollector
//
//  Created by Braian Avalos on 01/12/24.
//

import Foundation
struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: UserData
}

struct UserData: Codable {
    let id: Int
    let name: String
    let email: String
}
