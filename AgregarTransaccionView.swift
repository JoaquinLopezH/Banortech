//
// AgregarTransaccionView.swift
// BanorTech Finanzas
//
// Formulario para agregar nuevas transacciones
//

import SwiftUI
import Combine

struct AgregarTransaccionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransaccionesViewModel
    
    // Campos del formulario
    @State private var monto: String = ""
    @State private var categoria: String = "Comida"
    @State private var descripcion: String = ""
    @State private var tipoTransaccion: String = "gasto"
    @State private var fecha: Date = Date()
    @State private var isGuardando = false
    
    // CORREGIDO: Accediendo correctamente al tipo de cuenta
    private var esPersonal: Bool {
        AuthManager.shared.currentUser?.tipo_cuenta == "personal"
    }
    
    // Categorías según tipo de cuenta
    private var categorias: [String] {
        if esPersonal {
            return ["Comida", "Transporte", "Entretenimiento", "Salud", "Educación", "Servicios", "Salario", "Otros"]
        } else {
            return ["Ventas", "Servicios", "Inversión", "Gastos Operativos", "Nómina", "Marketing", "Otros"]
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header con ícono
                        VStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Nueva Transacción")
                                .font(.title2)
                                .bold()
                        }
                        .padding(.top, 20)
                        
                        // Formulario
                        VStack(spacing: 20) {
                            // Tipo de transacción (solo para personal)
                            if esPersonal {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Tipo")
                                        .font(.headline)
                                    
                                    Picker("Tipo", selection: $tipoTransaccion) {
                                        Text("Gasto").tag("gasto")
                                        Text("Ingreso").tag("ingreso")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                            }
                            
                            // Monto
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Monto")
                                    .font(.headline)
                                
                                HStack {
                                    Text("$")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0.00", text: $monto)
                                        .keyboardType(.decimalPad)
                                        .font(.title2)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            
                            // Categoría
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Categoría")
                                    .font(.headline)
                                
                                Picker("Categoría", selection: $categoria) {
                                    ForEach(categorias, id: \.self) { cat in
                                        Text(cat).tag(cat)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            
                            // Descripción
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descripción")
                                    .font(.headline)
                                
                                TextField("Ej: Compra en supermercado", text: $descripcion)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            
                            // Fecha
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fecha")
                                    .font(.headline)
                                
                                DatePicker("", selection: $fecha, displayedComponents: .date)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            
                            // Botón Guardar
                            Button(action: {
                                Task {
                                    await guardarTransaccion()
                                }
                            }) {
                                HStack {
                                    if isGuardando {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Guardar Transacción")
                                            .bold()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(botonActivo ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                            }
                            .disabled(!botonActivo || isGuardando)
                            .padding(.horizontal)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    var botonActivo: Bool {
        !monto.isEmpty && !descripcion.isEmpty && Double(monto) != nil
    }
    
    func guardarTransaccion() async {
        guard let montoDouble = Double(monto) else { return }
        
        isGuardando = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fechaString = formatter.string(from: fecha)
        
        var transaccion: [String: Any] = [
            "fecha": fechaString,
            "categoria": categoria,
            "monto": montoDouble
        ]
        
        if esPersonal {
            transaccion["tipo"] = tipoTransaccion
            transaccion["descripcion"] = descripcion
        } else {
            transaccion["tipo"] = tipoTransaccion
            transaccion["concepto"] = descripcion
        }
        
        let exito = await viewModel.agregarTransaccion(transaccion)
        
        isGuardando = false
        
        if exito {
            dismiss()
        }
    }
}

// MARK: - Vista de Filtros
struct FiltrosTransaccionesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TransaccionesViewModel
    
    @State private var categoriaSeleccionada: String = "Todas"
    @State private var tipoSeleccionado: String = "Todos"
    @State private var fechaInicio: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var fechaFin: Date = Date()
    @State private var usarFiltroFecha = false
    
    var esPersonal: Bool {
        AuthManager.shared.currentUser?.tipo_cuenta == "personal"
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section("Categoría") {
                    Picker("Categoría", selection: $categoriaSeleccionada) {
                        Text("Todas").tag("Todas")
                        ForEach(obtenerCategorias(), id: \.self) { categoria in
                            Text(categoria).tag(categoria)
                        }
                    }
                }
                
                if esPersonal {
                    Section("Tipo") {
                        Picker("Tipo", selection: $tipoSeleccionado) {
                            Text("Todos").tag("Todos")
                            Text("Ingresos").tag("ingreso")
                            Text("Gastos").tag("gasto")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section("Rango de Fechas") {
                    Toggle("Filtrar por fecha", isOn: $usarFiltroFecha)
                    
                    if usarFiltroFecha {
                        DatePicker("Desde", selection: $fechaInicio, displayedComponents: .date)
                        DatePicker("Hasta", selection: $fechaFin, displayedComponents: .date)
                    }
                }
                
                Section {
                    Button(action: aplicarFiltros) {
                        HStack {
                            Spacer()
                            Text("Aplicar Filtros")
                                .bold()
                            Spacer()
                        }
                    }
                    
                    Button(action: limpiarFiltros) {
                        HStack {
                            Spacer()
                            Text("Limpiar Filtros")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func obtenerCategorias() -> [String] {
        let categorias = Set(viewModel.transacciones.map { $0.categoria })
        return Array(categorias).sorted()
    }
    
    func aplicarFiltros() {
        // Aquí implementarías la lógica de filtrado
        dismiss()
    }
    
    func limpiarFiltros() {
        categoriaSeleccionada = "Todas"
        tipoSeleccionado = "Todos"
        usarFiltroFecha = false
        Task {
            await viewModel.cargarTransacciones()
        }
        dismiss()
    }
}
