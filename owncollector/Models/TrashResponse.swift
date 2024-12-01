//
//  TrashResponse.swift
//  owncollector
//
//  Created by Braian Avalos on 01/12/24.
//

import Foundation

struct TrashResponse: Codable {
    let success: Bool
    let trash: [TrashItem]
    let total: Double
}

// Modelo para cada ítem de basura
struct TrashItem: Codable, Identifiable {
    let id = UUID() // Agregar un identificador único
    let nombre: String
    let valor: Double
}
