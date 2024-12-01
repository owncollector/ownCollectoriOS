import SwiftUI

struct RegisterView: View {
    @Binding var navigationPath: [String]
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isProcessing: Bool = false
    @State private var registrationStatus: Bool? = nil
    @State private var errorMessage: String? = nil
    @State private var passwordVisible: Bool = false


    var body: some View {
        VStack {
            Spacer()

            Image("logo")
                .resizable()
                .frame(width: 261, height: 58)
                .padding(.bottom, 20)

            VStack(spacing: 10) {
                Text("Registrame")
                    .font(.system(size: 26))
                    .foregroundColor(Color(red: 123 / 255, green: 168 / 255, blue: 69 / 255))
                
                TextField("Nombre", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                
                TextField("Correo", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                
                HStack {
                    if passwordVisible {
                        TextField("Contraseña", text: $password)
                    } else {
                        SecureField("Contraseña", text: $password)
                    }
                    Button(action: {
                        passwordVisible.toggle()
                    }) {
                        Image(systemName: passwordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 16)

                Button(action: {
                    registerUser()
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Registrarme")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 123 / 255, green: 168 / 255, blue: 69 / 255))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .disabled(isProcessing || name.isEmpty || username.isEmpty || password.isEmpty)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal, 16)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            // Back Button
            Button(action: {
                navigationPath.removeLast() // Navega hacia atrás
            }) {
                Text("Volver a inicio de sesión")
                    .foregroundColor(Color(red: 123 / 255, green: 168 / 255, blue: 69 / 255))
                    .font(.system(size: 20))
            }

            Spacer()
            
            Text("Derechos reservados owncollector\n2024 ©")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.gray)
                .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
        .background(Color(red: 198 / 255, green: 223 / 255, blue: 168 / 255))
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: Binding<Bool>(
            get: { registrationStatus == true },
            set: { _ in registrationStatus = nil }
        )) {
            Alert(
                title: Text("Registro Exitoso"),
                message: Text("Usuario listo para iniciar sesión"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func registerUser() {
        isProcessing = true
        errorMessage = nil

        guard let url = URL(string: "http://owncollector.mainu.com.mx/api/register") else {
            errorMessage = "URL inválida"
            isProcessing = false
            return
        }

        let body: [String: String] = [
            "name": name,
            "email": username,
            "password": password
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            errorMessage = "Error al crear JSON"
            isProcessing = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isProcessing = false

                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    errorMessage = "Error en el servidor"
                    return
                }

                registrationStatus = true
            }
        }.resume()
    }
}
