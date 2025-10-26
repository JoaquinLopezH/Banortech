//
//  ContentView.swift
//  BanorTech Finanzas
//
//  Created by Joaquin
//

import SwiftUI
import Charts
import Combine

extension JSONDecoder {
    func debugDecode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try self.decode(type, from: data)
        } catch {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("❌ Error decodificando JSON:")
                print(jsonString)
            }
            print("❌ Error de decodificación: \(error)")
            throw error
        }
    }
}

// MARK: - Modelos de Datos
struct TransaccionPersonal: Codable, Identifiable {
    var id = UUID()
    let id_usuario: Int
    let fecha: String
    let categoria: String
    let descripcion: String
    let monto: Double
    let tipo: String
    
    enum CodingKeys: String, CodingKey {
        case id_usuario, fecha, categoria, descripcion, monto, tipo
    }
}

struct TransaccionEmpresarial: Codable, Identifiable {
    var id = UUID()
    let empresa_id: Int
    let fecha: String
    let tipo: String
    let concepto: String
    let categoria: String
    let monto: Double
    
    enum CodingKeys: String, CodingKey {
        case empresa_id, fecha, tipo, concepto, categoria, monto
    }
}

struct Metricas: Codable {
    let ingresos_totales: Double
    let gastos_totales: Double
    let balance: Double
    let ahorro_porcentaje: Double
    let gastos_por_categoria: [String: Double]
    let tendencia: String
    let promedio_gasto_diario: Double?
}

struct Simulacion: Codable {
    let ingresos_mensuales: Double
    let gastos_actuales: Double
    let gastos_proyectados: Double
    let balance_mensual_actual: Double
    let balance_mensual_proyectado: Double
    let balance_total_proyectado: Double
    let diferencia_vs_actual: Double
    let meses: Int
    let gastos_por_categoria: [String: Double]
}

// MARK: - Network Manager

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    let baseURL = "http://127.0.0.1:8000"
    
    struct MetricasResponse: Codable {
        let status: String
        let metricas: Metricas
    }
    
    struct RecomendacionesResponse: Codable {
        let status: String
        let recomendaciones: [String]
    }
    
    struct ChatResponse: Codable {
        let status: String
        let respuesta: String
    }
    
    struct SimulacionResponse: Codable {
        let status: String
        let simulacion: Simulacion
    }
    
    func fetchMetricas(perfil: String, usuarioId: String) async throws -> Metricas {
        let urlString = "\(baseURL)/analyze?perfil=\(perfil)&usuario_id=\(usuarioId)"
        print("📡 Llamando a: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Status Code: \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 JSON recibido (primeros 200 chars):")
            print(jsonString.prefix(200))
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(MetricasResponse.self, from: data)
        
        print("✅ Métricas decodificadas: Ingresos=\(apiResponse.metricas.ingresos_totales)")
        
        return apiResponse.metricas
    }
    
    func fetchRecomendaciones(perfil: String, usuarioId: String) async throws -> [String] {
        let url = URL(string: "\(baseURL)/recommendations?perfil=\(perfil)&usuario_id=\(usuarioId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(RecomendacionesResponse.self, from: data)
        
        print("✅ Recomendaciones: \(apiResponse.recomendaciones.count) items")
        
        return apiResponse.recomendaciones
    }
    
    func enviarMensajeChat(perfil: String, usuarioId: String, mensaje: String) async throws -> String {
        var request = URLRequest(url: URL(string: "\(baseURL)/chat")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["perfil": perfil, "usuario_id": usuarioId, "mensaje": mensaje]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(ChatResponse.self, from: data)
        
        return apiResponse.respuesta
    }
    
    func simularEscenario(perfil: String, usuarioId: String, ajustes: [String: Double], meses: Int) async throws -> Simulacion {
        var request = URLRequest(url: URL(string: "\(baseURL)/simulate")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "perfil": perfil,
            "usuario_id": usuarioId,
            "ajustes": ajustes,
            "meses_proyeccion": meses
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(SimulacionResponse.self, from: data)
        
        return apiResponse.simulacion
    }
    
    func agregarTransaccion(_ transaccion: [String: Any]) async throws {
        var request = URLRequest(url: URL(string: "\(baseURL)/update-transaction")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: transaccion)
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    // Métodos con autenticación
    func fetchMetricasAuth(perfil: String, usuarioId: String, token: String) async throws -> Metricas {
        let urlString = "\(baseURL)/analyze?perfil=\(perfil)&usuario_id=\(usuarioId)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 403 {
            throw NSError(
                domain: "AuthError",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Acceso denegado a estos datos"]
            )
        }
        
        if httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(MetricasResponse.self, from: data)
        
        return apiResponse.metricas
    }
    
    func fetchRecomendacionesAuth(perfil: String, usuarioId: String, token: String) async throws -> [String] {
        let url = URL(string: "\(baseURL)/recommendations?perfil=\(perfil)&usuario_id=\(usuarioId)")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(RecomendacionesResponse.self, from: data)
        
        return apiResponse.recomendaciones
    }
}
// Extension to add the missing methods with "Auth" at the end

extension NetworkManager {
    func enviarMensajeChatAuth(perfil: String, usuarioId: String, mensaje: String, token: String) async throws -> String {
        // For now, just call the original method without auth
        return try await enviarMensajeChat(perfil: perfil, usuarioId: usuarioId, mensaje: mensaje)
        // Or if your backend needs an Authorization token, add the header as in your fetchMetricasAuth
    }

    func simularEscenarioAuth(perfil: String, usuarioId: String, ajustes: [String: Double], meses: Int, token: String) async throws -> Simulacion {
        // For now, just call the original method without auth
        return try await simularEscenario(perfil: perfil, usuarioId: usuarioId, ajustes: ajustes, meses: meses)
        // Or if your backend needs an Authorization token, add the header as in your fetchMetricasAuth
    }
}

// MARK: - View Models

class FinanzasViewModel: ObservableObject {
    @Published var perfil: String = "personal"
    @Published var usuarioId: Int = 1
    @Published var empresaId: String = "E016"
    @Published var metricas: Metricas?
    @Published var recomendaciones: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var idActual: String {
        return perfil == "personal" ? String(usuarioId) : empresaId
    }
    
    func cargarDatos() async {
        print("🔄 Iniciando carga de datos...")
        print("   - Perfil: \(perfil)")
        print("   - ID: \(idActual)")
        
        // Verificar autenticación
        guard let token = AuthManager.shared.authToken else {
            await MainActor.run {
                self.errorMessage = "No autenticado"
                self.isLoading = false
            }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
            self.metricas = nil
        }
        
        do {
            print("📡 Fetching métricas con autenticación...")
            let metricas = try await NetworkManager.shared.fetchMetricasAuth(
                perfil: perfil,
                usuarioId: idActual,
                token: token
            )
            
            print("📡 Fetching recomendaciones con autenticación...")
            let recs = try await NetworkManager.shared.fetchRecomendacionesAuth(
                perfil: perfil,
                usuarioId: idActual,
                token: token
            )
            
            await MainActor.run {
                self.metricas = metricas
                self.recomendaciones = recs
                self.isLoading = false
                print("✅ Datos cargados exitosamente")
            }
        } catch {
            print("❌ ERROR: \(error)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// MARK: - Vista Principal (Ya no se usa directamente)

struct ContentView: View {
    @StateObject private var viewModel = FinanzasViewModel()
    
    var body: some View {
        // Redirigir a AppRootView
        AppRootView()
    }
}

// MARK: - Vistas Componentes (EXTRAÍDAS de ContentView)

struct MetricasGridView: View {
    let metricas: Metricas
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                MetricCard(
                    title: "Ingresos",
                    value: metricas.ingresos_totales,
                    icon: "arrow.down.circle.fill",
                    color: .green
                )
                
                MetricCard(
                    title: "Gastos",
                    value: metricas.gastos_totales,
                    icon: "arrow.up.circle.fill",
                    color: .red
                )
            }
            
            HStack(spacing: 15) {
                MetricCard(
                    title: "Balance",
                    value: metricas.balance,
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Ahorro",
                    value: metricas.ahorro_porcentaje,
                    icon: "percent",
                    color: .purple,
                    isPercentage: true
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct MetricCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    var isPercentage: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(isPercentage ? String(format: "%.1f%%", value) : String(format: "$%.2f", value))
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct GastosChartView: View {
    let gastos: [String: Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Gastos por Categoría")
                .font(.headline)
                .padding(.horizontal)
            
            if !gastos.isEmpty {
                Chart {
                    ForEach(Array(gastos.keys.sorted()), id: \.self) { categoria in
                        SectorMark(
                            angle: .value("Monto", gastos[categoria] ?? 0),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(by: .value("Categoría", categoria))
                    }
                }
                .frame(height: 250)
                .padding()
                
                // Leyenda
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(gastos.keys.sorted()), id: \.self) { categoria in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                            Text(categoria)
                                .font(.caption)
                            Spacer()
                            Text(String(format: "$%.0f", gastos[categoria] ?? 0))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No hay datos de gastos")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct RecomendacionesView: View {
    let recomendaciones: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Recomendaciones")
                    .font(.headline)
            }
            .padding(.horizontal)
            
            if recomendaciones.isEmpty {
                Text("No hay recomendaciones disponibles")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(Array(recomendaciones.enumerated()), id: \.offset) { index, recomendacion in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text(recomendacion)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}






struct ChatBubble: View {
    let mensaje: MensajeChat
    
    var body: some View {
        HStack {
            if mensaje.esUsuario { Spacer() }
            
            Text(mensaje.texto)
                .padding()
                .background(mensaje.esUsuario ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(mensaje.esUsuario ? .white : .primary)
                .cornerRadius(15)
            
            if !mensaje.esUsuario { Spacer() }
        }
    }
}



struct ResultadoSimulacion: View {
    let titulo: String
    let valor: Double
    var destacar: Bool = false
    
    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            Text(String(format: "$%.2f", valor))
                .fontWeight(destacar ? .bold : .regular)
                .foregroundColor(destacar ? (valor >= 0 ? .green : .red) : .primary)
        }
    }
}

// MARK: - App Root View (Manejo de Autenticación)

struct AppRootView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var viewModel = FinanzasViewModel()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainAppContent(viewModel: viewModel)
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
    }
}

// MARK: - Contenido Principal Autenticado

struct MainAppContent: View {
    @StateObject private var authManager = AuthManager.shared
    @ObservedObject var viewModel: FinanzasViewModel
    @State private var selectedTab = 0
    @State private var mostrarPerfil = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            ProgressView("Cargando datos...")
                                .padding()
                        } else if let metricas = viewModel.metricas {
                            HeaderDashboard(usuario: authManager.currentUser)
                            MetricasGridView(metricas: metricas)
                            GastosChartView(gastos: metricas.gastos_por_categoria)
                            RecomendacionesView(recomendaciones: viewModel.recomendaciones)
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No hay datos disponibles")
                                    .font(.headline)
                                if let error = viewModel.errorMessage {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                Button("Recargar") {
                                    Task { await viewModel.cargarDatos() }
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .navigationTitle("Banorte Finanzas")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Image(systemName: authManager.currentUser?.tipo_cuenta == "personal" ? "person.fill" : "building.2.fill")
                            Text(authManager.currentUser?.nombre_completo ?? "Usuario")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { mostrarPerfil = true }) {
                            Image(systemName: "person.circle")
                                .font(.title3)
                        }
                    }
                }
                .refreshable {
                    await viewModel.cargarDatos()
                }
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            .tag(0)
            
            // Tab 2: Transacciones
            TransaccionesView()
                .tabItem {
                    Label("Transacciones", systemImage: "list.bullet")
                }
                .tag(1)

            



            
            NavigationView {
                AsistenteModernoConGemini(viewModel: viewModel)
            }
            .tabItem {
                Label("Asistente", systemImage: "message.fill")
            }
            .tag(2)
            
            NavigationView {
                SimuladorModernoConGemini(viewModel: viewModel)
            }
            .tabItem {
                Label("Simulador", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(3)
        }
        .sheet(isPresented: $mostrarPerfil) {
            PerfilView()
        }
        .task {
            if let user = authManager.currentUser {
                viewModel.perfil = user.tipo_cuenta
                if user.tipo_cuenta == "personal" {
                    viewModel.usuarioId = user.id_usuario ?? 1
                } else {
                    viewModel.empresaId = user.empresa_id ?? "E001"
                }
            }
            await viewModel.cargarDatos()
        }
    }
}

// MARK: - Header Dashboard

struct HeaderDashboard: View {
    let usuario: PerfilUsuario?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(saludo)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(usuario?.nombre_completo ?? "Usuario")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if usuario?.tipo_cuenta == "personal" {
                        Label("Personal", systemImage: "person.fill")
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    } else {
                        Label("Empresa", systemImage: "building.2.fill")
                            .font(.caption)
                            .padding(6)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(6)
                    }
                    
                    Text("ID: \(usuario?.id_usuario.map(String.init) ?? usuario?.empresa_id ?? "N/A")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    var saludo: String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 0..<12: return "Buenos días"
        case 12..<19: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }
}

// MARK: - Vista de Perfil


