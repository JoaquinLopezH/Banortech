//
//  BanorteTheme.swift
//  BanorTech Finanzas
//
//  Sistema de diseño Banorte
//

import SwiftUI

// MARK: - Colores Banorte

extension Color {
    // Colores primarios
    
    static let banorteRed = Color(hex: "EC0029")
    static let banorteWhite = Color(hex: "F5F5F5")
    
    // Color secundario
    static let banorteGray = Color(hex: "6A6867")
    
    // Colores complementarios para estados
    static let banorteSuccess = Color(hex: "00A859")
    static let banorteWarning = Color(hex: "FFB400")
    static let banorteError = Color(hex: "EC0029")
    
    // Colores de fondo
    static let banorteBackground = Color(hex: "F5F5F5")
    static let banorteCardBackground = Color.white
     
    
    // Helper para crear colores desde hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Tipografía Banorte

extension Font {
    // Títulos - Poppins Bold
    
    static func banorteTitleLarge() -> Font {
        return .system(size: 32, weight: .bold, design: .default)
    }
    
    static func banorteTitleMedium() -> Font {
        return .system(size: 24, weight: .bold, design: .default)
    }
    
    static func banorteTitleSmall() -> Font {
        return .system(size: 20, weight: .bold, design: .default)
    }
    
    // Cuerpo - Inter Regular (simulado con system)
    static func banorteBodyLarge() -> Font {
        return .system(size: 18, weight: .regular, design: .default)
    }
    
    static func banorteBodyMedium() -> Font {
        return .system(size: 16, weight: .regular, design: .default)
    }
    
    static func banorteBodySmall() -> Font {
        return .system(size: 14, weight: .regular, design: .default)
    }
    
    static func banorteCaption() -> Font {
        return .system(size: 12, weight: .regular, design: .default)
    }
}

// MARK: - Estilos de Botón

struct BanortePrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.banorteBodyMedium())
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                isLoading ? Color.banorteGray : Color.banorteRed
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .shadow(color: Color.banorteRed.opacity(0.3), radius: 8, y: 4)
    }
}

struct BanorteSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.banorteBodyMedium())
            .fontWeight(.semibold)
            .foregroundColor(.banorteRed)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.banorteWhite)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.banorteRed, lineWidth: 2)
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Estilos de TextField

struct BanorteTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.banorteBodyMedium())
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.banorteGray.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func banorteTextFieldStyle() -> some View {
        self.modifier(BanorteTextFieldStyle())
    }
}

// MARK: - Estilos de Tarjeta

struct BanorteCardStyle: ViewModifier {
    var showShadow: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(16)
            .shadow(
                color: showShadow ? Color.black.opacity(0.08) : .clear,
                radius: showShadow ? 12 : 0,
                x: 0,
                y: showShadow ? 4 : 0
            )
    }
}

extension View {
    func banorteCard(showShadow: Bool = true) -> some View {
        self.modifier(BanorteCardStyle(showShadow: showShadow))
    }
}

// MARK: - Gradientes

extension LinearGradient {
    static let banorteGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.banorteRed,
            Color.banorteRed.opacity(0.8)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
