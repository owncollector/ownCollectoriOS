//
//  GlobalUserData.swift
//  owncollector
//
//  Created by Braian Avalos on 01/12/24.
//

import Foundation
class GlobalUserData: ObservableObject {
    static let shared = GlobalUserData()
    
    @Published var id: Int?
    @Published var name: String?
    @Published var email: String?
    
    private init() {}
}
