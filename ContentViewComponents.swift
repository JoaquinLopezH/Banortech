//
//  ContentViewComponents.swift
//  BanorTech Finanzas
//
//  Componentes visuales con diseño Banorte
//

import SwiftUI
import Charts

// MARK: - MetricCard Renovado

struct BanorteMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: String? = nil
    var showTrend: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Ícono
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                // Tendencia opcional
                if showTrend, let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend == "aumentando" ? "arrow.up.right" : trend == "disminuyendo" ? "arrow.down.right" : "minus")
                            .font(.system(size: 12))
                        Text(trend.capitalized)
                            .font(.banorteCaption())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        trend == "aumentando" ? Color.banorteError.opacity(0.1) :
                        trend == "disminuyendo" ? Color.banorteSuccess.opacity(0.1) :
                        Color.banorteGray.opacity(0.1)
                    )
                    .foregroundColor(
                        trend == "aumentando" ? Color.banorteError :
                        trend == "disminuyendo" ? Color.banorteSuccess :
                        Color.banorteGray
                    )
                    .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.banorteBodySmall())
                    .foregroundColor(.banorteGray)
                
                Text(value)
                    .font(.banorteTitleSmall())
                    .foregroundColor(.primary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .banorteCard()
    }
}

// MARK: - Header del Dashboard

struct DashboardHeader: View {
    let usuario: PerfilUsuario?
    let onProfileTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra superior
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(saludo)
                        .font(.banorteBodySmall())
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(usuario?.nombre_completo ?? "Usuario")
                        .font(.banorteTitleMedium())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Botón de perfil
                Button(action: onProfileTap) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: usuario?.tipo_cuenta == "personal" ? "person.fill" : "building.2.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Badge de tipo de cuenta
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: usuario?.tipo_cuenta == "personal" ? "person.circle.fill" : "building.2.circle.fill")
                        .font(.system(size: 16))
                    Text(usuario?.tipo_cuenta == "personal" ? "Cuenta Personal" : "Cuenta Empresa")
                        .font(.banorteBodySmall())
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(
            LinearGradient.banorteGradient
                .ignoresSafeArea(edges: .top)
        )
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

// MARK: - Grid de Métricas

struct MetricasGrid: View {
    let metricas: Metricas
    
    var body: some View {
        VStack(spacing: 16) {
            // Primera fila
            HStack(spacing: 16) {
                BanorteMetricCard(
                    title: "Ingresos",
                    value: String(format: "$%.2f", metricas.ingresos_totales),
                    icon: "arrow.down.circle.fill",
                    color: .banorteSuccess
                )
                
                BanorteMetricCard(
                    title: "Gastos",
                    value: String(format: "$%.2f", metricas.gastos_totales),
                    icon: "arrow.up.circle.fill",
                    color: .banorteError,
                    trend: metricas.tendencia,
                    showTrend: true
                )
            }
            
            // Segunda fila
            HStack(spacing: 16) {
                BanorteMetricCard(
                    title: "Balance",
                    value: String(format: "$%.2f", metricas.balance),
                    icon: "chart.line.uptrend.xyaxis",
                    color: metricas.balance >= 0 ? .banorteSuccess : .banorteError
                )
                
                BanorteMetricCard(
                    title: "Ahorro",
                    value: String(format: "%.1f%%", metricas.ahorro_porcentaje),
                    icon: "banknote.fill",
                    color: .banorteRed
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, -20) // Overlap con el header
    }
}

// MARK: - Gráfica de Gastos Renovada

struct GastosChartCard: View {
    let gastos: [String: Double]
    
    var gastosSorted: [(categoria: String, monto: Double)] {
        gastos.sorted { $0.value > $1.value }
            .map { (categoria: $0.key, monto: $0.value) }
    }
    
    var totalGastos: Double {
        gastos.values.reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Distribución de Gastos")
                .font(.banorteTitleSmall())
                .foregroundColor(.primary)
            
            if !gastos.isEmpty {
                // Gráfica de barras horizontales
                VStack(spacing: 12) {
                    ForEach(Array(gastosSorted.prefix(5)), id: \.categoria) { item in
                        VStack(spacing: 8) {
                            HStack {
                                Text(item.categoria.capitalized)
                                    .font(.banorteBodySmall())
                                    .fontWeight(.medium)
                                    .foregroundColor(.banorteGray)
                                
                                Spacer()
                                
                                Text(String(format: "$%.2f", item.monto))
                                    .font(.banorteBodySmall())
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Fondo
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.banorteGray.opacity(0.1))
                                        .frame(height: 8)
                                    
                                    // Progreso
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.banorteRed, Color.banorteRed.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width * (item.monto / totalGastos),
                                            height: 8
                                        )
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.banorteGray.opacity(0.3))
                    
                    Text("No hay gastos registrados")
                        .font(.banorteBodyMedium())
                        .foregroundColor(.banorteGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
        .padding(24)
        .background(Color.white)
        .banorteCard()
        .padding(.horizontal, 20)
    }
}

// MARK: - Recomendaciones Renovadas

struct RecomendacionesCard: View {
    let recomendaciones: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.banorteWarning.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.banorteWarning)
                        .font(.system(size: 20))
                }
                
                Text("Recomendaciones")
                    .font(.banorteTitleSmall())
                    .foregroundColor(.primary)
            }
            
            if recomendaciones.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.banorteSuccess.opacity(0.5))
                    
                    Text("¡Todo en orden!")
                        .font(.banorteBodyMedium())
                        .foregroundColor(.banorteGray)
                    
                    Text("Tus finanzas están en buen camino")
                        .font(.banorteBodySmall())
                        .foregroundColor(.banorteGray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(recomendaciones.enumerated()), id: \.offset) { index, recomendacion in
                        HStack(alignment: .top, spacing: 12) {
                            // Número
                            ZStack {
                                Circle()
                                    .fill(Color.banorteRed.opacity(0.1))
                                    .frame(width: 28, height: 28)
                                
                                Text("\(index + 1)")
                                    .font(.banorteCaption())
                                    .fontWeight(.bold)
                                    .foregroundColor(.banorteRed)
                            }
                            
                            // Texto
                            Text(recomendacion)
                                .font(.banorteBodySmall())
                                .foregroundColor(.banorteGray)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.banorteBackground)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .banorteCard()
        .padding(.horizontal, 20)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let onReload: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 80))
                .foregroundColor(.banorteGray.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No hay datos disponibles")
                    .font(.banorteTitleSmall())
                    .foregroundColor(.primary)
                
                Text("Intenta recargar la información")
                    .font(.banorteBodyMedium())
                    .foregroundColor(.banorteGray)
            }
            
            Button(action: onReload) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Recargar")
                }
            }
            .buttonStyle(BanortePrimaryButtonStyle())
            .frame(width: 200)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading State

struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.banorteRed)
            
            Text("Cargando datos...")
                .font(.banorteBodyMedium())
                .foregroundColor(.banorteGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
