//
// TransaccionesView.swift
// BanorTech Finanzas
//
// Vista completa de transacciones con historial, filtros y formulario
//

import SwiftUI
import Combine

// MARK: - Vista Principal de Transacciones
struct TransaccionesView: View {
    @StateObject private var viewModel = TransaccionesViewModel()
    @State private var mostrarAgregarTransaccion = false
    @State private var mostrarFiltros = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo degradado
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Barra de estadísticas rápidas
                    EstadisticasTransaccionesView(viewModel: viewModel)
                        .padding()
                    
                    // Lista de transacciones
                    if viewModel.isLoading {
                        ProgressView("Cargando transacciones...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.transacciones.isEmpty {
                        VistaSinTransacciones()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.transaccionesAgrupadas.keys.sorted(by: >), id: \.self) { fecha in
                                    SeccionFecha(
                                        fecha: fecha,
                                        transacciones: viewModel.transaccionesAgrupadas[fecha] ?? []
                                    )
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.cargarTransacciones()
                        }
                    }
                }
            }
            .navigationTitle("Transacciones")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Botón de filtros
                        Button(action: { mostrarFiltros.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(.blue)
                        }
                        
                        // Botón agregar
                        Button(action: { mostrarAgregarTransaccion.toggle() }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                }
            }
            .sheet(isPresented: $mostrarAgregarTransaccion) {
                AgregarTransaccionView(viewModel: viewModel)
            }
            .sheet(isPresented: $mostrarFiltros) {
                FiltrosTransaccionesView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.cargarTransacciones()
            }
        }
    }
}

// MARK: - Estadísticas Rápidas
struct EstadisticasTransaccionesView: View {
    @ObservedObject var viewModel: TransaccionesViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            EstadisticaCard(
                titulo: "Total",
                valor: "\(viewModel.transacciones.count)",
                icono: "list.bullet",
                color: .blue
            )
            
            // CORREGIDO: Usando currentUser?.tipocuenta
            if AuthManager.shared.currentUser?.tipo_cuenta == "personal" {
                EstadisticaCard(
                    titulo: "Ingresos",
                    valor: String(format: "$%.0f", viewModel.totalIngresos),
                    icono: "arrow.down.circle.fill",
                    color: .green
                )
                
                EstadisticaCard(
                    titulo: "Gastos",
                    valor: String(format: "$%.0f", viewModel.totalGastos),
                    icono: "arrow.up.circle.fill",
                    color: .red
                )
            }
        }
    }
}

struct EstadisticaCard: View {
    let titulo: String
    let valor: String
    let icono: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icono)
                .font(.title2)
                .foregroundColor(color)
            
            Text(valor)
                .font(.headline)
                .bold()
            
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Sección de Fecha
struct SeccionFecha: View {
    let fecha: String
    let transacciones: [TransaccionItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header de fecha
            Text(formatearFecha(fecha))
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Transacciones
            ForEach(transacciones) { transaccion in
                TransaccionRowView(transaccion: transaccion)
            }
        }
    }
    
    func formatearFecha(_ fecha: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: fecha) else {
            return fecha
        }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Hoy"
        } else if calendar.isDateInYesterday(date) {
            return "Ayer"
        } else {
            formatter.dateFormat = "d 'de' MMMM, yyyy"
            formatter.locale = Locale(identifier: "es_ES")
            return formatter.string(from: date)
        }
    }
}

// MARK: - Fila de Transacción
struct TransaccionRowView: View {
    let transaccion: TransaccionItem
    
    var body: some View {
        HStack(spacing: 15) {
            // Icono de categoría
            Image(systemName: iconoCategoria(transaccion.categoria))
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .background(colorCategoria(transaccion.categoria))
                .cornerRadius(10)
            
            // Información
            VStack(alignment: .leading, spacing: 4) {
                Text(transaccion.descripcion ?? transaccion.concepto ?? "Sin descripción")
                    .font(.headline)
                
                Text(transaccion.categoria)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Monto
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatearMonto(transaccion.monto, tipo: transaccion.tipo))
                    .font(.headline)
                    .foregroundColor(colorMonto(transaccion.tipo))
                    .bold()
                
                if let tipo = transaccion.tipo {
                    Text(tipo.capitalized)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
    
    func formatearMonto(_ monto: Double, tipo: String?) -> String {
        let signo = tipo == "ingreso" ? "+" : "-"
        return "\(signo)$\(String(format: "%.2f", abs(monto)))"
    }
    
    func colorMonto(_ tipo: String?) -> Color {
        return tipo == "ingreso" ? .green : .red
    }
    
    func iconoCategoria(_ categoria: String) -> String {
        switch categoria.lowercased() {
        case "comida": return "fork.knife"
        case "transporte": return "car.fill"
        case "entretenimiento": return "tv.fill"
        case "salud": return "heart.fill"
        case "educación": return "book.fill"
        case "servicios": return "bolt.fill"
        case "otros": return "ellipsis.circle.fill"
        case "salario": return "dollarsign.circle.fill"
        case "inversión": return "chart.line.uptrend.xyaxis"
        default: return "tag.fill"
        }
    }
    
    func colorCategoria(_ categoria: String) -> Color {
        switch categoria.lowercased() {
        case "comida": return .orange
        case "transporte": return .blue
        case "entretenimiento": return .purple
        case "salud": return .red
        case "educación": return .green
        case "servicios": return .teal
        case "salario": return .green
        case "inversión": return .indigo
        default: return .gray
        }
    }
}

// MARK: - Vista Sin Transacciones
struct VistaSinTransacciones: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No hay transacciones")
                .font(.title2)
                .bold()
            
            Text("Agrega tu primera transacción usando el botón +")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Modelo de Transacción
struct TransaccionItem: Identifiable, Codable {
    var id = UUID()
    let fecha: String
    let categoria: String
    let monto: Double
    let tipo: String?
    let descripcion: String?
    let concepto: String?
    
    enum CodingKeys: String, CodingKey {
        case fecha, categoria, monto, tipo, descripcion, concepto
    }
}

// MARK: - API Client Helper
class APIClient {
    static let shared = APIClient()
    private let baseURL = "http://127.0.0.1:8000"
    
    func get(endpoint: String) async throws -> [String: Any] {
        guard let token = AuthManager.shared.authToken else {
            throw NSError(domain: "APIClient", code: 401, userInfo: [NSLocalizedDescriptionKey: "No autenticado"])
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "APIClient", code: httpResponse.statusCode,
                         userInfo: [NSLocalizedDescriptionKey: "Error del servidor: \(httpResponse.statusCode)"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "APIClient", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Error al parsear JSON"])
        }
        
        return json
    }
    
    func post(endpoint: String, body: [String: Any]) async throws -> [String: Any] {
        guard let token = AuthManager.shared.authToken else {
            throw NSError(domain: "APIClient", code: 401, userInfo: [NSLocalizedDescriptionKey: "No autenticado"])
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "APIClient", code: httpResponse.statusCode,
                         userInfo: [NSLocalizedDescriptionKey: "Error del servidor: \(httpResponse.statusCode)"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "APIClient", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Error al parsear JSON"])
        }
        
        return json
    }
}

// MARK: - ViewModel de Transacciones
@MainActor
class TransaccionesViewModel: ObservableObject {
    @Published var transacciones: [TransaccionItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var transaccionesAgrupadas: [String: [TransaccionItem]] {
        Dictionary(grouping: transacciones, by: { $0.fecha })
    }
    
    var totalIngresos: Double {
        transacciones.filter { $0.tipo == "ingreso" }.reduce(0) { $0 + $1.monto }
    }
    
    var totalGastos: Double {
        transacciones.filter { $0.tipo == "gasto" }.reduce(0) { $0 + $1.monto }
    }
    
    func cargarTransacciones() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let datos = try await APIClient.shared.get(endpoint: "/api/transacciones")
            
            if let transaccionesArray = datos["transacciones"] as? [[String: Any]] {
                self.transacciones = transaccionesArray.compactMap { dict in
                    guard let fecha = dict["fecha"] as? String,
                          let categoria = dict["categoria"] as? String,
                          let monto = dict["monto"] as? Double else {
                        return nil
                    }
                    
                    return TransaccionItem(
                        fecha: fecha,
                        categoria: categoria,
                        monto: monto,
                        tipo: dict["tipo"] as? String,
                        descripcion: dict["descripcion"] as? String,
                        concepto: dict["concepto"] as? String
                    )
                }
            }
        } catch {
            errorMessage = "Error al cargar transacciones: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func agregarTransaccion(_ transaccion: [String: Any]) async -> Bool {
        do {
            let _ = try await APIClient.shared.post(endpoint: "/api/transacciones", body: transaccion)
            await cargarTransacciones()
            return true
        } catch {
            errorMessage = "Error al agregar transacción: \(error.localizedDescription)"
            return false
        }
    }
}
