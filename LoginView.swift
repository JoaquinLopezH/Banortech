//
//  LoginView.swift
//  BanorTech Finanzas
//
//  Pantalla de inicio de sesión con diseño Banorte
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var username = ""
    @State private var password = ""
    @State private var recordarSesion = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var mostrarRegistro = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo blanco Banorte
                Color.banorteBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header con gradiente rojo
                        VStack(spacing: 24) {
                            // Logo Banorte
                            Image(systemName: "banknote.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                                .padding(.top, 60)
                            
                            VStack(spacing: 8) {
                                Text("Banorte Finanzas")
                                    .font(.banorteTitleLarge())
                                    .foregroundColor(.white)
                                
                                Text("Tu aliado financiero inteligente")
                                    .font(.banorteBodyMedium())
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 40)
                        .background(
                            LinearGradient.banorteGradient
                                .ignoresSafeArea(edges: .top)
                        )
                        
                        // Formulario de login
                        VStack(spacing: 24) {
                            // Campo de usuario
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.banorteGray)
                                        .font(.system(size: 16))
                                    Text("Usuario")
                                        .font(.banorteBodySmall())
                                        .fontWeight(.semibold)
                                        .foregroundColor(.banorteGray)
                                }
                                
                                TextField("Ingresa tu usuario", text: $username)
                                    .banorteTextFieldStyle()
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            
                            // Campo de contraseña
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.banorteGray)
                                        .font(.system(size: 16))
                                    Text("Contraseña")
                                        .font(.banorteBodySmall())
                                        .fontWeight(.semibold)
                                        .foregroundColor(.banorteGray)
                                }
                                
                                SecureField("Ingresa tu contraseña", text: $password)
                                    .banorteTextFieldStyle()
                            }
                            
                            // Recordar sesión
                            HStack {
                                Toggle(isOn: $recordarSesion) {
                                    Text("Recordar sesión")
                                        .font(.banorteBodySmall())
                                        .foregroundColor(.banorteGray)
                                }
                                .tint(.banorteRed)
                            }
                            .padding(.vertical, 8)
                            
                            // Mensaje de error
                            if let error = errorMessage {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.banorteError)
                                    Text(error)
                                        .font(.banorteBodySmall())
                                        .foregroundColor(.banorteGray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color.banorteError.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            // Botón de login
                            Button(action: iniciarSesion) {
                                HStack(spacing: 12) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.9)
                                    }
                                    Text(isLoading ? "Iniciando sesión..." : "Iniciar Sesión")
                                }
                            }
                            .buttonStyle(BanortePrimaryButtonStyle(isLoading: isLoading))
                            .disabled(isLoading || username.isEmpty || password.isEmpty)
                            .padding(.top, 8)
                            
                            // Botón de registro
                            Button(action: { mostrarRegistro = true }) {
                                HStack(spacing: 4) {
                                    Text("¿No tienes cuenta?")
                                        .font(.banorteBodySmall())
                                        .foregroundColor(.banorteGray)
                                    Text("Regístrate")
                                        .font(.banorteBodySmall())
                                        .fontWeight(.semibold)
                                        .foregroundColor(.banorteRed)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            // Usuarios demo
                            VStack(spacing: 16) {
                                Divider()
                                    .padding(.vertical, 8)
                                
                                Text("Acceso rápido")
                                    .font(.banorteCaption())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.banorteGray)
                                    .textCase(.uppercase)
                                
                                HStack(spacing: 16) {
                                    Button(action: {
                                        username = "demo_personal"
                                        password = "123456"
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 24))
                                            Text("Personal")
                                                .font(.banorteBodySmall())
                                                .fontWeight(.medium)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                                    }
                                    .buttonStyle(BanorteSecondaryButtonStyle())
                                    
                                    Button(action: {
                                        username = "demo_empresa"
                                        password = "123456"
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "building.2.fill")
                                                .font(.system(size: 24))
                                            Text("Empresa")
                                                .font(.banorteBodySmall())
                                                .fontWeight(.medium)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                                    }
                                    .buttonStyle(BanorteSecondaryButtonStyle())
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(Color.white)
                        .banorteCard()
                        .padding(.horizontal, 20)
                        .padding(.top, -20) // Overlap con el header
                    }
                }
            }
            .sheet(isPresented: $mostrarRegistro) {
                RegistroView()
            }
        }
    }
    
    func iniciarSesion() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await authManager.iniciarSesion(
                    username: username,
                    password: password,
                    recordarSesion: recordarSesion
                )
                
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Vista de Registro con Tema Banorte

struct RegistroView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var email = ""
    @State private var nombreCompleto = ""
    @State private var tipoCuenta = "personal"
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var mostrarExito = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.banorteBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 24) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .padding(.top, 50)
                            
                            VStack(spacing: 8) {
                                Text("Crear Cuenta")
                                    .font(.banorteTitleMedium())
                                    .foregroundColor(.white)
                                
                                Text("Únete a Banorte Finanzas")
                                    .font(.banorteBodyMedium())
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 40)
                        .background(
                            LinearGradient.banorteGradient
                                .ignoresSafeArea(edges: .top)
                        )
                        
                        // Formulario
                        VStack(spacing: 24) {
                            // Selector de tipo de cuenta
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tipo de cuenta")
                                    .font(.banorteBodySmall())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.banorteGray)
                                
                                Picker("Tipo de cuenta", selection: $tipoCuenta) {
                                    Label("Personal", systemImage: "person.fill").tag("personal")
                                    Label("Empresa", systemImage: "building.2.fill").tag("empresa")
                                }
                                .pickerStyle(.segmented)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            
                            // Nombre completo
                            BanorteTextField(
                                label: tipoCuenta == "personal" ? "Nombre completo" : "Nombre de la empresa",
                                icon: tipoCuenta == "personal" ? "person.text.rectangle" : "building.2",
                                text: $nombreCompleto
                            )
                            
                            // Email
                            BanorteTextField(
                                label: "Correo electrónico",
                                icon: "envelope.fill",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            // Username
                            BanorteTextField(
                                label: "Nombre de usuario",
                                icon: "at",
                                text: $username
                            )
                            
                            // Contraseña
                            BanorteSecureField(
                                label: "Contraseña",
                                icon: "lock.fill",
                                text: $password
                            )
                            
                            // Confirmar contraseña
                            BanorteSecureField(
                                label: "Confirmar contraseña",
                                icon: "lock.shield.fill",
                                text: $confirmPassword
                            )
                            
                            // Validación de contraseña
                            if !password.isEmpty && !confirmPassword.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(password == confirmPassword ? .banorteSuccess : .banorteError)
                                    Text(password == confirmPassword ? "Las contraseñas coinciden" : "Las contraseñas no coinciden")
                                        .font(.banorteCaption())
                                        .foregroundColor(.banorteGray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Error message
                            if let error = errorMessage {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.banorteError)
                                    Text(error)
                                        .font(.banorteBodySmall())
                                        .foregroundColor(.banorteGray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color.banorteError.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            // Botón de registro
                            Button(action: registrar) {
                                HStack(spacing: 12) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.9)
                                    }
                                    Text(isLoading ? "Creando cuenta..." : "Crear Cuenta")
                                }
                            }
                            .buttonStyle(BanortePrimaryButtonStyle(isLoading: isLoading))
                            .disabled(isLoading || !formularioValido)
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(Color.white)
                        .banorteCard()
                        .padding(.horizontal, 20)
                        .padding(.top, -20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                            Text("Cerrar")
                        }
                        .font(.banorteBodySmall())
                        .fontWeight(.semibold)
                        .foregroundColor(.banorteRed)
                    }
                }
            }
            .alert("¡Cuenta creada!", isPresented: $mostrarExito) {
                Button("Iniciar Sesión") {
                    dismiss()
                }
            } message: {
                Text("Tu cuenta ha sido creada exitosamente. Ya puedes iniciar sesión.")
            }
        }
    }
    
    var formularioValido: Bool {
        !username.isEmpty &&
        !password.isEmpty &&
        !email.isEmpty &&
        !nombreCompleto.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    func registrar() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                _ = try await authManager.registrar(
                    username: username,
                    password: password,
                    email: email,
                    nombreCompleto: nombreCompleto,
                    tipoCuenta: tipoCuenta
                )
                
                await MainActor.run {
                    isLoading = false
                    mostrarExito = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Componentes Custom con Tema Banorte

struct BanorteTextField: View {
    let label: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.banorteGray)
                    .font(.system(size: 16))
                Text(label)
                    .font(.banorteBodySmall())
                    .fontWeight(.semibold)
                    .foregroundColor(.banorteGray)
            }
            
            TextField("", text: $text)
                .banorteTextFieldStyle()
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        }
    }
}

struct BanorteSecureField: View {
    let label: String
    let icon: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.banorteGray)
                    .font(.system(size: 16))
                Text(label)
                    .font(.banorteBodySmall())
                    .fontWeight(.semibold)
                    .foregroundColor(.banorteGray)
            }
            
            SecureField("", text: $text)
                .banorteTextFieldStyle()
        }
    }
}

#Preview {
    LoginView()
}

