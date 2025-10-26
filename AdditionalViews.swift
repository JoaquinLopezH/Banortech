//
//  AdditionalViews.swift
//  BanorTech Finanzas
//
//  Vistas adicionales con diseño Banorte
//

import SwiftUI

// MARK: - Asistente View Renovado

struct AsistenteView: View {
    @ObservedObject var viewModel: FinanzasViewModel
    @State private var mensaje = ""
    @State private var mensajes: [MensajeChat] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.banorteBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header del chat
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient.banorteGradient
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    
                    Text("Asistente Financiero")
                        .font(.banorteTitleSmall())
                        .foregroundColor(.primary)
                    
                    Text("Pregúntame sobre tus finanzas")
                        .font(.banorteBodySmall())
                        .foregroundColor(.banorteGray)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                
                // Área de mensajes
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            if mensajes.isEmpty {
                                // Estado inicial
                                VStack(spacing: 20) {
                                    Spacer()
                                    
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.banorteGray.opacity(0.3))
                                    
                                    VStack(spacing: 8) {
                                        Text("Comienza la conversación")
                                            .font(.banorteTitleSmall())
                                            .foregroundColor(.primary)
                                        
                                        Text("Pregunta sobre tus ingresos, gastos, ahorros o cualquier métrica financiera")
                                            .font(.banorteBodySmall())
                                            .foregroundColor(.banorteGray)
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    // Sugerencias
                                    VStack(spacing: 12) {
                                        Text("Sugerencias:")
                                            .font(.banorteCaption())
                                            .fontWeight(.semibold)
                                            .foregroundColor(.banorteGray)
                                            .textCase(.uppercase)
                                        
                                        ForEach(sugerencias, id: \.self) { sugerencia in
                                            Button(action: { mensaje = sugerencia }) {
                                                HStack {
                                                    Image(systemName: "questionmark.circle.fill")
                                                        .foregroundColor(.banorteRed)
                                                    Text(sugerencia)
                                                        .font(.banorteBodySmall())
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                }
                                                .padding(16)
                                                .background(Color.white)
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    Spacer()
                                }
                                .padding(.top, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(mensajes) { msg in
                                        ChatBubbleView(mensaje: msg)
                                            .id(msg.id)
                                    }
                                }
                                .padding(20)
                            }
                            
                            if isLoading {
                                HStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.banorteRed)
                                    
                                    Text("Pensando...")
                                        .font(.banorteBodySmall())
                                        .foregroundColor(.banorteGray)
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .onChange(of: mensajes.count) { _ in
                        if let lastMessage = mensajes.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input de mensaje
                HStack(spacing: 12) {
                    TextField("Escribe tu pregunta...", text: $mensaje, axis: .vertical)
                        .font(.banorteBodyMedium())
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(24)
                        .lineLimit(1...4)
                    
                    Button(action: enviarMensaje) {
                        ZStack {
                            Circle()
                                .fill(
                                    mensaje.isEmpty
                                        ? AnyShapeStyle(Color.banorteGray)
                                        : AnyShapeStyle(LinearGradient.banorteGradient)
                                )

                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                    }
                    .disabled(mensaje.isEmpty || isLoading)
                }
                .padding(16)
                .background(Color.banorteBackground)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    let sugerencias = [
        "¿Cuánto he gastado este mes?",
        "¿Cuál es mi tasa de ahorro?",
        "¿En qué categoría gasto más?"
    ]
    
    func enviarMensaje() {
        guard !mensaje.isEmpty, let token = AuthManager.shared.authToken else { return }
        
        let textoMensaje = mensaje
        let mensajeUsuario = MensajeChat(texto: textoMensaje, esUsuario: true)
        mensajes.append(mensajeUsuario)
        mensaje = ""
        isLoading = true
        
        Task {
            do {
                let respuesta = try await NetworkManager.shared.enviarMensajeChatAuth(
                    perfil: viewModel.perfil,
                    usuarioId: viewModel.idActual,
                    mensaje: textoMensaje,
                    token: token
                )
                
                let mensajeAsistente = MensajeChat(texto: respuesta, esUsuario: false)
                await MainActor.run {
                    mensajes.append(mensajeAsistente)
                    isLoading = false
                }
            } catch {
                let mensajeError = MensajeChat(texto: "Error: \(error.localizedDescription)", esUsuario: false)
                await MainActor.run {
                    mensajes.append(mensajeError)
                    isLoading = false
                }
            }
        }
    }
}

struct MensajeChat: Identifiable {
    let id = UUID()
    let texto: String
    let esUsuario: Bool
}

struct ChatBubbleView: View {
    let mensaje: MensajeChat
    
    var body: some View {
        HStack {
            if mensaje.esUsuario { Spacer(minLength: 60) }
            
            VStack(alignment: mensaje.esUsuario ? .trailing : .leading, spacing: 8) {
                Text(mensaje.texto)
                    .font(.banorteBodyMedium())
                    .foregroundColor(mensaje.esUsuario ? .white : .primary)
                    .padding(16)
                    .background(
                        mensaje.esUsuario ?
                        AnyView(LinearGradient.banorteGradient) :
                        AnyView(Color.white)
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
            }
            
            if !mensaje.esUsuario { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Simulador View Renovado

struct SimuladorView: View {
    @ObservedObject var viewModel: FinanzasViewModel
    @State private var ajustes: [String: Double] = [:]
    @State private var mesesProyeccion = 3
    @State private var simulacion: Simulacion?
    @State private var isSimulating = false
    
    let categorias = ["restaurantes", "transporte", "entretenimiento", "servicios", "salud"]
    
    var body: some View {
        ZStack {
            Color.banorteBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient.banorteGradient
                                )
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        
                        Text("Simulador Financiero")
                            .font(.banorteTitleMedium())
                            .foregroundColor(.primary)
                        
                        Text("Proyecta el impacto de ajustes en tus gastos")
                            .font(.banorteBodySmall())
                            .foregroundColor(.banorteGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                    
                    // Controles de simulación
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Ajusta tus gastos")
                            .font(.banorteTitleSmall())
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 16) {
                            ForEach(categorias, id: \.self) { categoria in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(categoria.capitalized)
                                            .font(.banorteBodyMedium())
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(ajustes[categoria] ?? 0))%")
                                            .font(.banorteBodyMedium())
                                            .fontWeight(.bold)
                                            .foregroundColor(
                                                (ajustes[categoria] ?? 0) > 0 ? .banorteError :
                                                (ajustes[categoria] ?? 0) < 0 ? .banorteSuccess :
                                                .banorteGray
                                            )
                                    }
                                    
                                    Slider(
                                        value: Binding(
                                            get: { ajustes[categoria] ?? 0 },
                                            set: { ajustes[categoria] = $0 }
                                        ),
                                        in: -50...50,
                                        step: 5
                                    )
                                    .tint(.banorteRed)
                                    
                                    HStack {
                                        Text("-50%")
                                            .font(.banorteCaption())
                                            .foregroundColor(.banorteGray)
                                        Spacer()
                                        Text("+50%")
                                            .font(.banorteCaption())
                                            .foregroundColor(.banorteGray)
                                    }
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                            }
                        }
                        
                        // Selector de meses
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Proyección")
                                .font(.banorteBodyMedium())
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("\(mesesProyeccion) meses")
                                    .font(.banorteTitleSmall())
                                    .foregroundColor(.banorteRed)
                                
                                Spacer()
                                
                                Stepper("", value: $mesesProyeccion, in: 1...12)
                                    .labelsHidden()
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                        
                        // Botón de simulación
                        Button(action: simular) {
                            HStack(spacing: 12) {
                                if isSimulating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                }
                                Text(isSimulating ? "Simulando..." : "Ejecutar Simulación")
                            }
                        }
                        .buttonStyle(BanortePrimaryButtonStyle(isLoading: isSimulating))
                        .disabled(isSimulating)
                    }
                    .padding(24)
                    .background(Color.white)
                    .banorteCard()
                    .padding(.horizontal, 20)
                    
                    // Resultados
                    if let sim = simulacion {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 12) {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.banorteRed)
                                    .font(.system(size: 20))
                                
                                Text("Resultados")
                                    .font(.banorteTitleSmall())
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(spacing: 12) {
                                ResultadoSimulacionRow(
                                    titulo: "Balance Actual",
                                    valor: sim.balance_mensual_actual,
                                    icon: "calendar"
                                )
                                
                                ResultadoSimulacionRow(
                                    titulo: "Balance Proyectado",
                                    valor: sim.balance_mensual_proyectado,
                                    icon: "calendar.badge.clock"
                                )
                                
                                Divider()
                                    .padding(.vertical, 8)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Diferencia Total")
                                            .font(.banorteBodyMedium())
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        Text("\(mesesProyeccion) meses")
                                            .font(.banorteCaption())
                                            .foregroundColor(.banorteGray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(String(format: "$%.2f", sim.diferencia_vs_actual))
                                        .font(.banorteTitleSmall())
                                        .fontWeight(.bold)
                                        .foregroundColor(
                                            sim.diferencia_vs_actual >= 0 ? .banorteSuccess : .banorteError
                                        )
                                }
                                .padding(20)
                                .background(
                                    (sim.diferencia_vs_actual >= 0 ? Color.banorteSuccess : Color.banorteError)
                                        .opacity(0.1)
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .banorteCard()
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func simular() {
        guard let token = AuthManager.shared.authToken else { return }
        isSimulating = true
        
        Task {
            do {
                let resultado = try await NetworkManager.shared.simularEscenarioAuth(
                    perfil: viewModel.perfil,
                    usuarioId: viewModel.idActual,
                    ajustes: ajustes,
                    meses: mesesProyeccion,
                    token: token
                )
                
                await MainActor.run {
                    simulacion = resultado
                    isSimulating = false
                }
            } catch {
                await MainActor.run {
                    isSimulating = false
                }
            }
        }
    }
}

struct ResultadoSimulacionRow: View {
    let titulo: String
    let valor: Double
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.banorteGray)
                .font(.system(size: 18))
            
            Text(titulo)
                .font(.banorteBodyMedium())
                .foregroundColor(.banorteGray)
            
            Spacer()
            
            Text(String(format: "$%.2f", valor))
                .font(.banorteBodyMedium())
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color.banorteBackground)
        .cornerRadius(12)
    }
}

// MARK: - Perfil View Renovado

struct PerfilView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authManager = AuthManager.shared
    @State private var mostrarConfirmacionCierre = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.banorteBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header del perfil
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient.banorteGradient
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: authManager.currentUser?.tipo_cuenta == "personal" ? "person.fill" : "building.2.fill")
                                    .font(.system(size: 45))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text(authManager.currentUser?.nombre_completo ?? "Usuario")
                                    .font(.banorteTitleMedium())
                                    .foregroundColor(.primary)
                                
                                Text(authManager.currentUser?.email ?? "")
                                    .font(.banorteBodyMedium())
                                    .foregroundColor(.banorteGray)
                                
                                // Badge
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(authManager.currentUser?.tipo_cuenta == "personal" ? "Cuenta Personal" : "Cuenta Empresa")
                                        .font(.banorteBodySmall())
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.banorteSuccess)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.banorteSuccess.opacity(0.1))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.top, 24)
                        
                        // Información de la cuenta
                        VStack(spacing: 16) {
                            if let user = authManager.currentUser {
                                PerfilInfoRow(
                                    icon: "person.text.rectangle",
                                    label: "Usuario",
                                    value: user.username
                                )
                                
                                if let id = user.id_usuario {
                                    PerfilInfoRow(
                                        icon: "number",
                                        label: "ID Usuario",
                                        value: String(id)
                                    )
                                }
                                
                                if let empresaId = user.empresa_id {
                                    PerfilInfoRow(
                                        icon: "building.2",
                                        label: "ID Empresa",
                                        value: empresaId
                                    )
                                }
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .banorteCard()
                        .padding(.horizontal, 20)
                        
                        // Opciones
                        VStack(spacing: 16) {
                            PerfilOptionButton(
                                icon: "key.fill",
                                title: "Cambiar Contraseña",
                                action: {}
                            )
                            
                            PerfilOptionButton(
                                icon: "bell.fill",
                                title: "Notificaciones",
                                action: {}
                            )
                            
                            PerfilOptionButton(
                                icon: "gearshape.fill",
                                title: "Configuración",
                                action: {}
                            )
                        }
                        .padding(24)
                        .background(Color.white)
                        .banorteCard()
                        .padding(.horizontal, 20)
                        
                        // Botón de cerrar sesión
                        Button(action: { mostrarConfirmacionCierre = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar Sesión")
                            }
                        }
                        .buttonStyle(BanorteSecondaryButtonStyle())
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .font(.banorteBodyMedium())
                    .fontWeight(.semibold)
                    .foregroundColor(.banorteRed)
                }
            }
            .alert("Cerrar Sesión", isPresented: $mostrarConfirmacionCierre) {
                Button("Cancelar", role: .cancel) {}
                Button("Cerrar Sesión", role: .destructive) {
                    authManager.cerrarSesion()
                    dismiss()
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
        }
    }
}

struct PerfilInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.banorteGray)
                .font(.system(size: 18))
                .frame(width: 28)
            
            Text(label)
                .font(.banorteBodyMedium())
                .foregroundColor(.banorteGray)
            
            Spacer()
            
            Text(value)
                .font(.banorteBodyMedium())
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color.banorteBackground)
        .cornerRadius(12)
    }
}

struct PerfilOptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.banorteRed)
                    .font(.system(size: 18))
                    .frame(width: 28)
                
                Text(title)
                    .font(.banorteBodyMedium())
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.banorteGray)
            }
            .padding(16)
            .background(Color.banorteBackground)
            .cornerRadius(12)
        }
    }
}

