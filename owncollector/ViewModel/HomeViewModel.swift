//
//  HomeViewModel.swift
//  owncollector
//
//  Created by Braian Avalos on 01/12/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var trashItems: [TrashItem] = []
    @Published var totalAmount: String = "0.00"
    @Published var name: String = "Usuario Demo"
    @Published var email: String = "demo@correo.com"
    var user: String = ""

    func fetchData(userId: String) {
        user = userId
        guard let url = URL(string: "http://owncollector.mainu.com.mx/api/getTrash/\(userId)") else {
            print("URL inválida")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error al realizar la solicitud: \(error)")
                return
            }

            guard let data = data else {
                print("No se recibieron datos")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TrashResponse.self, from: data)
                DispatchQueue.main.async {
                    self.trashItems = decodedResponse.trash
                    self.totalAmount = String(format: "%.2f", decodedResponse.total)
                }
            } catch {
                print("Error al decodificar JSON: \(error)")
            }
        }.resume()
    }

    func refreshData() {
        fetchData(userId: user) // Reutiliza la lógica de fetchData para el refresco
    }
    
    private func createQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
