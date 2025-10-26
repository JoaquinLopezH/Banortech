
//  AuthModels.swift
//  BanorTech Finanzas
//
//  Sistema de Autenticación - Modelos y NetworkManager
//

import SwiftUI
import Combine

// MARK: - Modelos de Autenticación

struct RegistroRequest: Codable {
    let username: String
    let password: String
    let email: String
    let nombre_completo: String
    let tipo_cuenta: String  // "personal" o "empresa"
}

struct LoginRequest: Codable {
    let username: String
    let password: String
    let recordar_sesion: Bool
}

struct LoginResponse: Codable {
    let status: String
    let token: String
    let perfil: PerfilUsuario
}

struct PerfilUsuario: Codable {
    let username: String
    let email: String
    let nombre_completo: String
    let tipo_cuenta: String
    let id_usuario: Int?
    let empresa_id: String?
}

struct APIResponse: Codable {
    let status: String
    let message: String?
}

// MARK: - Auth Manager

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: PerfilUsuario?
    @Published var authToken: String?
    
    private let baseURL = "http://127.0.0.1:8001"
    private let tokenKey = "banorte_auth_token"
    private let userKey = "banorte_user_profile"
    
    init() {
        cargarSesionGuardada()
    }
    
    // MARK: - Persistencia de Sesión
    
    func cargarSesionGuardada() {
        guard let token = UserDefaults.standard.string(forKey: tokenKey),
              let userData = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(PerfilUsuario.self, from: userData) else {
            return
        }
        
        // Verificar que el token siga siendo válido
        Task {
            do {
                let isValid = try await verificarToken(token)
                await MainActor.run {
                    if isValid {
                        self.authToken = token
                        self.currentUser = user
                        self.isAuthenticated = true
                        print("✅ Sesión restaurada para: \(user.username)")
                    } else {
                        self.cerrarSesion()
                    }
                }
            } catch {
                await MainActor.run {
                    self.cerrarSesion()
                }
            }
        }
    }
    
    func guardarSesion(token: String, user: PerfilUsuario) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
    }
    
    func cerrarSesion() {
        // Notificar al servidor
        if let token = authToken {
            Task {
                try? await cerrarSesionServidor(token: token)
            }
        }
        
        // Limpiar datos locales
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        
        authToken = nil
        currentUser = nil
        isAuthenticated = false
        
        print("🔓 Sesión cerrada")
    }
    
    // MARK: - API Calls
    
    func registrar(
        username: String,
        password: String,
        email: String,
        nombreCompleto: String,
        tipoCuenta: String
    ) async throws -> PerfilUsuario {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let registro = RegistroRequest(
            username: username,
            password: password,
            email: email,
            nombre_completo: nombreCompleto,
            tipo_cuenta: tipoCuenta
        )
        
        request.httpBody = try JSONEncoder().encode(registro)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            let errorResponse = try? JSONDecoder().decode(APIResponse.self, from: data)
            throw NSError(
                domain: "AuthError",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorResponse?.message ?? "Error desconocido"]
            )
        }
        
        struct RegistroResponse: Codable {
            let status: String
            let message: String
            let perfil: PerfilUsuario
        }
        
        let registroResponse = try JSONDecoder().decode(RegistroResponse.self, from: data)
        return registroResponse.perfil
    }
    
    func iniciarSesion(
        username: String,
        password: String,
        recordarSesion: Bool
    ) async throws {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let login = LoginRequest(
            username: username,
            password: password,
            recordar_sesion: recordarSesion
        )
        
        request.httpBody = try JSONEncoder().encode(login)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            let errorResponse = try? JSONDecoder().decode(APIResponse.self, from: data)
            throw NSError(
                domain: "AuthError",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorResponse?.message ?? "Credenciales inválidas"]
            )
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        await MainActor.run {
            self.authToken = loginResponse.token
            self.currentUser = loginResponse.perfil
            self.isAuthenticated = true
            
            if recordarSesion {
                self.guardarSesion(token: loginResponse.token, user: loginResponse.perfil)
            }
            
            print("✅ Sesión iniciada: \(loginResponse.perfil.username)")
        }
    }
    
    func verificarToken(_ token: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/verificar-token")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        
        return httpResponse.statusCode == 200
    }
    
    func cerrarSesionServidor(token: String) async throws {
        let url = URL(string: "\(baseURL)/logout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    // MARK: - Helper Methods
    
    var idActual: String {
        guard let user = currentUser else { return "1" }
        if user.tipo_cuenta == "personal" {
            return String(user.id_usuario ?? 1)
        } else {
            return user.empresa_id ?? "E001"
        }
    }
    
    var perfilActual: String {
        return currentUser?.tipo_cuenta ?? "personal"
    }
}
