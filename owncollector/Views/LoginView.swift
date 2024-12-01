import SwiftUI

struct LoginView: View {
    @Binding var navigationPath: [String]
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var passwordVisible: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            Spacer()

            // Logo
            Image("logo")
                .resizable()
                .frame(width: 261, height: 58)
                .padding(.bottom, 20)

            VStack(spacing: 10) {
                Text("Iniciar Sesión")
                    .font(.system(size: 26))
                    .foregroundColor(Color(red: 123 / 255, green: 168 / 255, blue: 69 / 255))

                TextField("Correo", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)

                HStack {
                    if passwordVisible {
                        TextField("Contraseña", text: $password)
                    } else {
                        SecureField("Cotraseña", text: $password)
                    }
                    Button(action: {
                        passwordVisible.toggle()
                    }) {
                        Image(systemName: passwordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                .textFieldStyle(.roundedBorder)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 8)
                }

                Button(action: {
                    loginUser(email: username, password: password)
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Continuar")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 123 / 255, green: 168 / 255, blue: 69 / 255))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .disabled(isLoading || username.isEmpty || password.isEmpty)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal, 16)

            Button(action: {
                navigationPath.append("Register")
            }) {
                Text("¿No tienes cuenta? Registrate!")
                    .foregroundColor(Color(red: 123 / 255, green: 168 / 255, blue: 69 / 255))
                    .font(.system(size: 20))
            }

            Spacer()

            Text("Derechos reservados owncollector\n2024 ©")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.gray)
                .padding(.bottom, 20)
        }
        .background(Color(red: 198 / 255, green: 223 / 255, blue: 168 / 255))
        .edgesIgnoringSafeArea(.all)
    }

    private func loginUser(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "http://owncollector.mainu.com.mx/api/login") else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }

        let body: [String: String] = ["email": email, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            errorMessage = "Error al codificar los datos"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error de conexión: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "Respuesta vacía del servidor"
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                if decodedResponse.success {
                    DispatchQueue.main.async {
                        // Guardar datos globalmente
                        let user = GlobalUserData.shared
                        user.id = decodedResponse.data.id
                        user.name = decodedResponse.data.name
                        user.email = decodedResponse.data.email

                        // Navegar al Home
                        navigationPath.append("Home")
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = decodedResponse.message
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Hubo un error al iniciar sesión. Verifica usuario o contraseña"
                }
            }
        }.resume()
    }
}
