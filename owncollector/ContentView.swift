//
//  ContentView.swift
//  owncollector
//
//  Created by Braian Avalos on 01/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationPath: [String] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            LoginView(navigationPath: $navigationPath)
                .navigationDestination(for: String.self) { route in
                    switch route {
                    case "Home":
                        HomeView()
                    case "Register":
                        RegisterView(navigationPath: $navigationPath)
                    default:
                        Text("Ruta no encontrada")
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


