//
//  HomeVIew.swift
//  owncollector
//
//  Created by Braian Avalos on 01/12/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showQr: Bool = false
    let user = GlobalUserData.shared
    var body: some View {
        VStack {
            // Encabezado
            VStack(spacing: 10) {
                Spacer().frame(height: 50)
                Image("placeholder")
                    .resizable()
                    .frame(width: 112, height: 112)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(red: 80 / 255, green: 115 / 255, blue: 37 / 255), lineWidth: 2))
                Text(user.name ?? "default")
                    .foregroundColor(Color(red: 80 / 255, green: 115 / 255, blue: 37 / 255))
                    .fontWeight(.bold)
                Text(user.email ?? "defaultEmail@default.com")
                    .foregroundColor(Color(red: 112 / 255, green: 112 / 255, blue: 112 / 255))

                if showQr {
                    QrGetter(content: String(user.id ?? 12))
                        .transition(.opacity.combined(with: .scale))
                }

                ShowQRButton(
                    text: showQr ? "Ocultar QR" : "Mostrar QR",
                    onClick: { showQr.toggle() }
                )
                Spacer().frame(height: 10)
            }
            .background(Color(red: 198 / 255, green: 223 / 255, blue: 168 / 255))
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])


            Spacer().frame(height: 20)

            // Contenido principal
            ScrollView {
                if !showQr {
                    BigAmount(amount: viewModel.totalAmount)
                        .transition(.opacity.combined(with: .slide))
                }
              
                Text("Historial de Transacciones")
                    .font(.headline)
                    .foregroundColor(Color(red: 123 / 255, green: 168 / 255, blue: 69 / 255))
                    .padding(.top, 10)

                if viewModel.trashItems.isEmpty {
                    Text("No hay datos disponibles")
                        .foregroundColor(Color.gray)
                        .padding()
                } else {
                    ForEach(viewModel.trashItems) { trashItem in
                        ListItem(type: trashItem.nombre, formattedAmount: String(format: "%.2f", trashItem.valor))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.fetchData(userId: String(user.id ?? 12) )
        }
        .refreshable {
            viewModel.refreshData()
        }
        .navigationBarHidden(true)

    }
}


struct QrGetter: View {
    var content: String
    @State private var qrImage: UIImage? = nil
    @State private var isLoading: Bool = true

    private let ciContext = CIContext() // Contexto reutilizable

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.green))
                    .frame(width: 250, height: 250)
            } else if let qrImage = qrImage {
                Image(uiImage: qrImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
            } else {
                Text("No se pudo generar el QR")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            generateQRCode(from: content)
        }
    }

    private func generateQRCode(from id: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let qr = self.createQRCode(from: id) {
                DispatchQueue.main.async {
                    self.qrImage = qr
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    private func createQRCode(from string: String) -> UIImage? {
        // Crear datos del string
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("L", forKey: "inputCorrectionLevel") // Nivel más rápido

        guard let outputImage = filter.outputImage else { return nil }

        // Escalar la imagen a resolución adecuada
        let transform = CGAffineTransform(scaleX: 8, y: 8) // Ajustar escala
        let scaledImage = outputImage.transformed(by: transform)

        // Convertir a UIImage con contexto reutilizable
        if let cgImage = ciContext.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

struct ListItem: View {
    var type: String
    var formattedAmount: String
    let fontColor :Color = Color(red: 80 / 255, green: 115 / 255, blue: 37 / 255)
    var body: some View {
        HStack {
            Text(type)
                .font(.headline)
                .foregroundColor(fontColor)
            Spacer()
            Text("+ $\(formattedAmount)")
                .font(.subheadline)
                .foregroundColor(fontColor)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
struct BigAmount: View {
    var amount: String
    let colorTitle: Color = Color(red: 112 / 255, green: 168 / 255, blue: 69 / 255)
    let colorOther: Color = Color(red: 80 / 255, green: 115 / 255, blue: 37 / 255)
    var body: some View {
        VStack {
            Text("Créditos")
                .font(.title2)
                .foregroundColor(colorTitle)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("MXN")
                    .font(.headline)
                    .foregroundColor(colorOther)
                Text("$\(amount)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorOther)
            }
        }
        .padding()
    }
}
struct ShowQRButton: View {
    var text: String
    var onClick: () -> Void
    let backgroundColor = Color(red: 241 / 255, green: 251 / 255, blue: 239 / 255)
    var body: some View {
        Button(action: onClick) {
            Text(text)
                .font(.headline)
                .foregroundColor( Color(red: 91 / 255, green: 137 / 255, blue: 80 / 255))
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 130 / 255, green: 174 / 255, blue: 112 / 255), lineWidth: 2)
                )
            
        }

        .padding(.horizontal, 32)
        
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
