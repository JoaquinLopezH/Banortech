//
// GeminiService.swift
// BanorTech Finanzas
//
// Servicio simulado de IA sin dependencia de Gemini API
// Con análisis avanzado del simulador financiero
//

import Foundation

// MARK: - Servicio Simulado de IA
class GeminiService {
    static let shared = GeminiService()
    
    private init() {}
    
    // MARK: - Generar Respuesta Simulada
    func generarRespuesta(prompt: String) async throws -> String {
        // Simular tiempo de respuesta realista
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 segundos
        
        return "Respuesta generada para el asistente financiero."
    }
    
    // MARK: - Asistente Financiero
    func preguntaAsistenteFinanciero(
        mensaje: String,
        metricas: Metricas?,
        contextoAdicional: String? = nil
    ) async throws -> String {
        
        // Simular tiempo de procesamiento
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        let mensajeLower = mensaje.lowercased()
        
        // 1. Preguntas sobre gastos totales
        if mensajeLower.contains("cuánto") && (mensajeLower.contains("gastado") || mensajeLower.contains("gasto")) {
            if let metricas = metricas {
                return """
                Sus gastos totales del periodo son de $\(formatearMoneda(metricas.gastos_totales)) MXN. \
                La categoría con mayor gasto es \(obtenerCategoríaMayor(metricas.gastos_por_categoria)) con \
                $\(formatearMoneda(metricas.gastos_por_categoria.values.max() ?? 0)) MXN.
                
                Le recomiendo revisar esta categoría para identificar oportunidades de ahorro.
                """
            } else {
                return "Para consultar sus gastos, es necesario que recargue los datos financieros desde la pantalla principal."
            }
        }
        
        // 2. Preguntas sobre ingresos
        if mensajeLower.contains("ingreso") {
            if let metricas = metricas {
                return """
                Sus ingresos totales del periodo son de $\(formatearMoneda(metricas.ingresos_totales)) MXN. \
                Con estos ingresos y sus gastos actuales de $\(formatearMoneda(metricas.gastos_totales)) MXN, \
                mantiene un balance de $\(formatearMoneda(metricas.balance)) MXN.
                
                Su tasa de ahorro actual es del \(String(format: "%.1f", metricas.ahorro_porcentaje))%.
                """
            } else {
                return "Para consultar sus ingresos, necesito que actualice los datos desde la pantalla de inicio."
            }
        }
        
        // 3. Preguntas sobre ahorro
        if mensajeLower.contains("ahorro") || mensajeLower.contains("ahorrar") {
            if let metricas = metricas {
                let tasaAhorro = metricas.ahorro_porcentaje
                
                if tasaAhorro >= 20 {
                    return """
                    Excelente gestión financiera. Su tasa de ahorro del \(String(format: "%.1f", tasaAhorro))% está por encima del promedio recomendado.
                    
                    Recomendaciones:
                    • Considere destinar parte de sus ahorros a inversiones de mediano plazo
                    • Mantenga un fondo de emergencia equivalente a 6 meses de gastos
                    • Evalúe opciones de ahorro programado con su asesor bancario
                    """
                } else if tasaAhorro >= 10 {
                    return """
                    Su tasa de ahorro del \(String(format: "%.1f", tasaAhorro))% es aceptable, pero puede mejorar.
                    
                    Sugerencias para incrementar su ahorro:
                    • Establezca una meta de ahorro del 20% de sus ingresos
                    • Revise gastos en \(obtenerCategoríaMayor(metricas.gastos_por_categoria)) para reducir un 10%
                    • Automatice sus ahorros mediante transferencias programadas
                    """
                } else {
                    return """
                    Su tasa de ahorro del \(String(format: "%.1f", tasaAhorro))% está por debajo del nivel recomendado.
                    
                    Acciones prioritarias:
                    • Analice sus gastos fijos y busque alternativas más económicas
                    • Reduzca gastos discrecionales en un 15-20%
                    • Establezca un presupuesto mensual estricto
                    • Considere fuentes adicionales de ingreso
                    """
                }
            } else {
                return "Para analizar su capacidad de ahorro, necesito acceso a sus métricas financieras. Por favor, recargue los datos."
            }
        }
        
        // 4. Preguntas sobre categorías de gasto
        if mensajeLower.contains("categoría") || mensajeLower.contains("donde gasto") || mensajeLower.contains("en qué gasto") {
            if let metricas = metricas {
                let top3 = metricas.gastos_por_categoria
                    .sorted(by: { $0.value > $1.value })
                    .prefix(3)
                
                var respuesta = "Sus principales categorías de gasto son:\n\n"
                for (index, item) in top3.enumerated() {
                    let porcentaje = (item.value / metricas.gastos_totales) * 100
                    respuesta += "\(index + 1). \(item.key): $\(formatearMoneda(item.value)) MXN (\(String(format: "%.1f", porcentaje))%)\n"
                }
                
                respuesta += "\nConsidere optimizar gastos en \(top3.first?.key ?? "la categoría principal") para mejorar su balance financiero."
                
                return respuesta
            } else {
                return "Necesito sus datos financieros para analizar la distribución de gastos por categoría."
            }
        }
        
        // 5. Preguntas sobre balance o situación financiera
        if mensajeLower.contains("balance") || mensajeLower.contains("situación") || mensajeLower.contains("cómo estoy") {
            if let metricas = metricas {
                let balance = metricas.balance
                
                if balance > 0 {
                    return """
                    Su situación financiera es positiva con un balance de $\(formatearMoneda(balance)) MXN.
                    
                    Análisis:
                    • Tendencia: \(metricas.tendencia)
                    • Tasa de ahorro: \(String(format: "%.1f", metricas.ahorro_porcentaje))%
                    • Ratio ingreso/gasto: \(String(format: "%.2f", metricas.ingresos_totales / max(metricas.gastos_totales, 1)))
                    
                    Continúe con sus hábitos financieros actuales y busque oportunidades de inversión.
                    """
                } else {
                    return """
                    Su balance actual es negativo: $\(formatearMoneda(abs(balance))) MXN.
                    
                    Medidas urgentes recomendadas:
                    • Reduzca gastos no esenciales inmediatamente
                    • Priorice el pago de deudas con mayor interés
                    • Evite nuevos gastos con tarjeta de crédito
                    • Considere renegociar términos de pagos pendientes
                    
                    Le sugiero agendar una cita con su asesor financiero.
                    """
                }
            } else {
                return "Para evaluar su situación financiera, necesito que cargue sus datos actualizados."
            }
        }
        
        // 6. Preguntas sobre consejos o recomendaciones
        if mensajeLower.contains("consejo") || mensajeLower.contains("recomendación") || mensajeLower.contains("qué hacer") {
            if let metricas = metricas {
                return """
                Basado en su perfil financiero, le recomiendo:
                
                1. **Optimización de gastos**: Reduzca gastos en \(obtenerCategoríaMayor(metricas.gastos_por_categoria)) en un 10-15%.
                
                2. **Ahorro programado**: Configure transferencias automáticas del \(metricas.ahorro_porcentaje < 15 ? "15" : "20")% de sus ingresos a una cuenta de ahorro.
                
                3. **Fondo de emergencia**: Mantenga reservas equivalentes a 6 meses de gastos ($\(formatearMoneda(metricas.gastos_totales * 6)) MXN).
                
                4. **Seguimiento mensual**: Revise sus métricas financieras cada mes para mantener el control.
                """
            } else {
                return """
                Para brindarle recomendaciones personalizadas, necesito analizar sus datos financieros.
                
                Recomendaciones generales:
                • Mantenga un presupuesto mensual detallado
                • Ahorre al menos el 20% de sus ingresos
                • Evite deudas de consumo con altos intereses
                • Revise y ajuste sus gastos regularmente
                """
            }
        }
        
        // 7. Preguntas sobre tendencias
        if mensajeLower.contains("tendencia") || mensajeLower.contains("mejorando") || mensajeLower.contains("empeorando") {
            if let metricas = metricas {
                let tendencia = metricas.tendencia.lowercased()
                
                if tendencia.contains("positiva") || tendencia.contains("ascendente") {
                    return """
                    Su tendencia financiera es positiva. Sus finanzas muestran una mejora consistente.
                    
                    Indicadores favorables:
                    • Balance en crecimiento
                    • Control de gastos efectivo
                    • Tasa de ahorro: \(String(format: "%.1f", metricas.ahorro_porcentaje))%
                    
                    Mantenga estos hábitos y considere incrementar sus ahorros gradualmente.
                    """
                } else {
                    return """
                    La tendencia actual requiere atención. Es momento de ajustar su estrategia financiera.
                    
                    Acciones correctivas:
                    • Identifique gastos superfluos a eliminar
                    • Establezca límites de gasto por categoría
                    • Busque formas de incrementar sus ingresos
                    • Monitoree sus finanzas semanalmente
                    """
                }
            } else {
                return "Para analizar tendencias, necesito datos históricos. Actualice la información desde la pantalla principal."
            }
        }
        
        // 8. Preguntas sobre presupuesto
        if mensajeLower.contains("presupuesto") {
            if let metricas = metricas {
                return """
                Presupuesto recomendado basado en sus ingresos de $\(formatearMoneda(metricas.ingresos_totales)) MXN:
                
                • Necesidades básicas: $\(formatearMoneda(metricas.ingresos_totales * 0.50)) MXN (50%)
                • Gastos personales: $\(formatearMoneda(metricas.ingresos_totales * 0.30)) MXN (30%)
                • Ahorro e inversión: $\(formatearMoneda(metricas.ingresos_totales * 0.20)) MXN (20%)
                
                Esta distribución 50/30/20 es una referencia estándar. Ajústela según sus necesidades específicas.
                """
            } else {
                return """
                Un presupuesto efectivo debe seguir la regla 50/30/20:
                
                • 50% para necesidades básicas (vivienda, alimentos, servicios)
                • 30% para gastos personales (entretenimiento, restaurantes)
                • 20% para ahorro e inversiones
                
                Cargue sus datos para recibir un presupuesto personalizado.
                """
            }
        }
        
        // 9. Preguntas sobre inversión
        if mensajeLower.contains("inversión") || mensajeLower.contains("invertir") {
            if let metricas = metricas {
                if metricas.balance > metricas.gastos_totales * 3 {
                    return """
                    Con su balance actual de $\(formatearMoneda(metricas.balance)) MXN, está en posición de considerar inversiones.
                    
                    Opciones sugeridas por perfil de riesgo:
                    
                    **Conservador**: CETES, Fondos de inversión de deuda
                    **Moderado**: Fondos mixtos, ETFs diversificados
                    **Agresivo**: Acciones individuales, fondos de mercados emergentes
                    
                    Consulte con su asesor de inversiones de Banorte para una estrategia personalizada.
                    """
                } else {
                    return """
                    Antes de invertir, es importante que consolide su fondo de emergencia.
                    
                    Pasos recomendados:
                    1. Acumule 6 meses de gastos ($\(formatearMoneda(metricas.gastos_totales * 6)) MXN)
                    2. Elimine deudas de alto interés
                    3. Una vez logrado, destine el 10-15% de ingresos a inversión
                    
                    Su prioridad actual debe ser la estabilidad financiera.
                    """
                }
            } else {
                return "Para evaluar opciones de inversión, necesito conocer su situación financiera actual. Por favor, actualice sus datos."
            }
        }
        
        // 10. Preguntas sobre deudas
        if mensajeLower.contains("deuda") || mensajeLower.contains("crédito") || mensajeLower.contains("préstamo") {
            return """
            Estrategia para manejo óptimo de deudas:
            
            **Método Avalancha** (más eficiente):
            1. Pague el mínimo en todas las deudas
            2. Destine todo excedente a la deuda con mayor tasa de interés
            3. Una vez liquidada, ataque la siguiente más cara
            
            **Método Bola de Nieve** (motivacional):
            1. Liquide primero la deuda más pequeña
            2. Después, ataque la siguiente más pequeña con el dinero liberado
            
            Evite adquirir nuevas deudas mientras está en proceso de liquidación.
            """
        }
        
        // 11. Respuesta por defecto para otras preguntas
        return """
        Entiendo su consulta financiera. Como su asistente de Banorte, puedo ayudarle con:
        
        • Análisis de gastos e ingresos
        • Recomendaciones de ahorro
        • Distribución de presupuesto
        • Estrategias de inversión
        • Manejo de deudas
        
        Por favor, sea más específico con su pregunta o seleccione una de las sugerencias para obtener información detallada.
        """
    }
    
    // MARK: - Simulador Financiero MEJORADO
    func analizarSimulacion(
        ingresosActuales: Double,
        gastosActuales: Double,
        ajustesPropuestos: [String: Double],
        mesesProyeccion: Int,
        gastosPorCategoria: [String: Double]
    ) async throws -> String {
        
        // Simular procesamiento (más tiempo para análisis complejo)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Calcular métricas
        var nuevosGastos = gastosActuales
        var detallesAjustes: [(categoria: String, porcentaje: Double, cambio: Double)] = []
        
        for (categoria, porcentaje) in ajustesPropuestos {
            if let gastoCategoria = gastosPorCategoria[categoria] {
                let cambio = gastoCategoria * (porcentaje / 100)
                nuevosGastos += cambio
                detallesAjustes.append((categoria, porcentaje, cambio))
            }
        }
        
        let balanceActual = ingresosActuales - gastosActuales
        let balanceNuevo = ingresosActuales - nuevosGastos
        let diferencia = balanceNuevo - balanceActual
        let proyeccionTotal = balanceNuevo * Double(mesesProyeccion)
        let porcentajeCambio = balanceActual != 0 ? (diferencia / abs(balanceActual)) * 100 : 0
        
        // Determinar tipo de escenario
        let tipoEscenario = determinarTipoEscenario(
            diferencia: diferencia,
            porcentajeCambio: porcentajeCambio,
            balanceNuevo: balanceNuevo,
            ingresos: ingresosActuales
        )
        
        // Generar análisis según escenario y período
        return generarAnalisisDetallado(
            tipoEscenario: tipoEscenario,
            ingresos: ingresosActuales,
            gastosActuales: gastosActuales,
            gastosNuevos: nuevosGastos,
            balanceActual: balanceActual,
            balanceNuevo: balanceNuevo,
            diferencia: diferencia,
            porcentajeCambio: porcentajeCambio,
            proyeccionTotal: proyeccionTotal,
            meses: mesesProyeccion,
            ajustes: detallesAjustes
        )
    }
    
    // MARK: - Determinar Tipo de Escenario
    private func determinarTipoEscenario(
        diferencia: Double,
        porcentajeCambio: Double,
        balanceNuevo: Double,
        ingresos: Double
    ) -> TipoEscenario {
        
        let tasaAhorroNueva = (balanceNuevo / ingresos) * 100
        
        // Escenarios positivos
        if diferencia > 0 {
            if porcentajeCambio >= 15 {
                return .muyPositivo // Mejora significativa
            } else if porcentajeCambio >= 5 {
                return .positivo // Mejora moderada
            } else {
                return .levementePositivo // Mejora leve
            }
        }
        // Escenarios negativos
        else if diferencia < 0 {
            if abs(porcentajeCambio) >= 15 || balanceNuevo < 0 {
                return .critico // Situación crítica
            } else if abs(porcentajeCambio) >= 5 {
                return .negativo // Empeora moderadamente
            } else {
                return .levementeNegativo // Empeora levemente
            }
        }
        // Sin cambios significativos
        else {
            return .neutral
        }
    }
    
    // MARK: - Generar Análisis Detallado
    private func generarAnalisisDetallado(
        tipoEscenario: TipoEscenario,
        ingresos: Double,
        gastosActuales: Double,
        gastosNuevos: Double,
        balanceActual: Double,
        balanceNuevo: Double,
        diferencia: Double,
        porcentajeCambio: Double,
        proyeccionTotal: Double,
        meses: Int,
        ajustes: [(categoria: String, porcentaje: Double, cambio: Double)]
    ) -> String {
        
        var analisis = """
        **ANÁLISIS FINANCIERO - PROYECCIÓN A \(meses) MESES**
        
        **📊 SITUACIÓN ACTUAL:**
        • Ingresos mensuales: $\(formatearMoneda(ingresos)) MXN
        • Gastos actuales: $\(formatearMoneda(gastosActuales)) MXN
        • Balance mensual: $\(formatearMoneda(balanceActual)) MXN
        • Tasa de ahorro: \(String(format: "%.1f", (balanceActual/ingresos)*100))%
        
        **🎯 AJUSTES PROPUESTOS:**
        """
        
        // Detallar ajustes
        for ajuste in ajustes.sorted(by: { abs($0.cambio) > abs($1.cambio) }) {
            let signo = ajuste.porcentaje >= 0 ? "+" : ""
            analisis += "\n• \(ajuste.categoria): \(signo)\(String(format: "%.0f", ajuste.porcentaje))% ($\(signo)\(formatearMoneda(ajuste.cambio)) MXN)"
        }
        
        analisis += """
        
        
        **📈 RESULTADOS PROYECTADOS:**
        • Nuevos gastos mensuales: $\(formatearMoneda(gastosNuevos)) MXN
        • Nuevo balance mensual: $\(formatearMoneda(balanceNuevo)) MXN
        • Nueva tasa de ahorro: \(String(format: "%.1f", (balanceNuevo/ingresos)*100))%
        • Impacto mensual: $\(formatearMoneda(abs(diferencia))) MXN (\(diferencia >= 0 ? "mejora" : "reducción"))
        • Cambio vs actual: \(String(format: "%.1f", porcentajeCambio))%
        
        """
        
        // Añadir análisis específico según escenario y período
        analisis += generarEvaluacionPorEscenario(
            tipoEscenario: tipoEscenario,
            meses: meses,
            proyeccionTotal: proyeccionTotal,
            diferencia: diferencia,
            balanceNuevo: balanceNuevo,
            ingresos: ingresos,
            ajustes: ajustes
        )
        
        return analisis
    }
    
    // MARK: - Evaluación por Escenario y Período
    private func generarEvaluacionPorEscenario(
        tipoEscenario: TipoEscenario,
        meses: Int,
        proyeccionTotal: Double,
        diferencia: Double,
        balanceNuevo: Double,
        ingresos: Double,
        ajustes: [(categoria: String, porcentaje: Double, cambio: Double)]
    ) -> String {
        
        switch tipoEscenario {
        case .muyPositivo:
            return generarAnalisisMuyPositivo(meses: meses, proyeccionTotal: proyeccionTotal, diferencia: diferencia, balanceNuevo: balanceNuevo, ingresos: ingresos)
            
        case .positivo:
            return generarAnalisisPositivo(meses: meses, proyeccionTotal: proyeccionTotal, diferencia: diferencia, balanceNuevo: balanceNuevo, ingresos: ingresos)
            
        case .levementePositivo:
            return generarAnalisisLevementePositivo(meses: meses, proyeccionTotal: proyeccionTotal, diferencia: diferencia)
            
        case .neutral:
            return generarAnalisisNeutral(meses: meses, ajustes: ajustes)
            
        case .levementeNegativo:
            return generarAnalisisLevementeNegativo(meses: meses, diferencia: diferencia, balanceNuevo: balanceNuevo, ingresos: ingresos)
            
        case .negativo:
            return generarAnalisisNegativo(meses: meses, proyeccionTotal: proyeccionTotal, diferencia: diferencia, balanceNuevo: balanceNuevo)
            
        case .critico:
            return generarAnalisisCritico(meses: meses, balanceNuevo: balanceNuevo, ajustes: ajustes)
        }
    }
    
    // MARK: - Análisis Muy Positivo (Mejora >15%)
    private func generarAnalisisMuyPositivo(meses: Int, proyeccionTotal: Double, diferencia: Double, balanceNuevo: Double, ingresos: Double) -> String {
        
        let tasaAhorro = (balanceNuevo / ingresos) * 100
        
        switch meses {
        case 3:
            return """
            **💰 PROYECCIÓN 3 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: EXCELENTE**
            
            Sus ajustes generan una mejora significativa de $\(formatearMoneda(diferencia)) MXN mensuales. En solo 3 meses, acumulará $\(formatearMoneda(proyeccionTotal)) MXN adicionales.
            
            **🎯 ¿POR QUÉ ES EXCELENTE?**
            Con una tasa de ahorro del \(String(format: "%.1f", tasaAhorro))%, está en el camino correcto para:
            • Construir un fondo de emergencia sólido en corto plazo
            • Cumplir metas financieras trimestrales
            • Tener liquidez para oportunidades de inversión
            
            **📋 PLAN DE ACCIÓN TRIMESTRAL:**
            
            **Mes 1 (Implementación):**
            • Ajuste sus presupuestos según los cambios propuestos
            • Configure alertas para no exceder los nuevos límites
            • Identifique gastos innecesarios adicionales
            
            **Mes 2 (Consolidación):**
            • Monitoree semanalmente su cumplimiento
            • Ajuste fino de categorías según comportamiento real
            • Destine el 50% del ahorro extra a un fondo de emergencia
            
            **Mes 3 (Optimización):**
            • Evalúe resultados vs proyecciones
            • Considere aumentar ahorros en un 5% adicional
            • Explore opciones de inversión para el excedente
            
            **💡 RECOMENDACIÓN ESPECIAL:**
            Al finalizar el trimestre, habrá ahorrado lo suficiente para:
            • Crear un fondo de contingencia de 1 mes de gastos
            • Invertir en CETES o fondos de bajo riesgo
            • Planificar una meta financiera mayor
            """
            
        case 6:
            return """
            **💰 PROYECCIÓN 6 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: EXCELENTE**
            
            Esta estrategia transformará su situación financiera. En medio año acumulará $\(formatearMoneda(proyeccionTotal)) MXN, mejorando su balance mensual en $\(formatearMoneda(diferencia)) MXN.
            
            **🎯 ¿POR QUÉ ES TRANSFORMADOR?**
            Un semestre con esta disciplina le permitirá:
            • Alcanzar una tasa de ahorro del \(String(format: "%.1f", tasaAhorro))%
            • Construir estabilidad financiera robusta
            • Tener opciones para inversiones de mediano plazo
            
            **📋 PLAN DE ACCIÓN SEMESTRAL:**
            
            **Fase 1: Meses 1-2 (Adaptación):**
            • Implemente los cambios gradualmente
            • Ajuste hábitos de consumo sin afectar calidad de vida
            • Automatice transferencias de ahorro
            • Meta: Cumplir 80% de los ajustes propuestos
            
            **Fase 2: Meses 3-4 (Aceleración):**
            • Optimice categorías basándose en aprendizajes
            • Busque ahorros adicionales del 5-10%
            • Construya un fondo de emergencia de 2-3 meses de gastos
            • Meta: Cumplir 95% de los ajustes propuestos
            
            **Fase 3: Meses 5-6 (Maximización):**
            • Consolide nuevos hábitos financieros
            • Destine excedentes a inversión o pago de deudas
            • Evalúe nuevas oportunidades de ahorro
            • Meta: Superar las proyecciones en 5-10%
            
            **💡 OPORTUNIDADES A 6 MESES:**
            Con $\(formatearMoneda(proyeccionTotal)) MXN acumulados:
            • Fondo de emergencia completo (3-6 meses de gastos)
            • Capital para inversión inicial en instrumentos conservadores
            • Pago anticipado de deudas de alto interés
            • Colchón financiero para oportunidades
            
            **🔍 IMPACTO A LARGO PLAZO:**
            Manteniendo esta estrategia, en 1 año habrá ahorrado $\(formatearMoneda(proyeccionTotal * 2)) MXN, posicionándose para metas financieras mayores como enganche de vivienda, vehículo o inversiones sustanciales.
            """
            
        case 12:
            return """
            **💰 PROYECCIÓN 12 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: SOBRESALIENTE**
            
            Implementar estos ajustes durante un año completo generará un ahorro extraordinario de $\(formatearMoneda(proyeccionTotal)) MXN. Esta cifra representa una mejora mensual sostenida de $\(formatearMoneda(diferencia)) MXN.
            
            **🎯 ¿POR QUÉ ES SOBRESALIENTE?**
            Un año de disciplina financiera con \(String(format: "%.1f", tasaAhorro))% de tasa de ahorro le permite:
            • Cambiar radicalmente su situación patrimonial
            • Alcanzar independencia financiera gradual
            • Tener capital para inversiones significativas
            • Construir riqueza sostenible
            
            **📋 PLAN DE ACCIÓN ANUAL:**
            
            **Q1 (Meses 1-3): Fundamentos**
            Objetivo: Establecer base sólida
            • Implementar ajustes y crear nuevos hábitos
            • Configurar sistema de seguimiento automatizado
            • Destinar 100% del ahorro a fondo de emergencia
            • Meta parcial: $\(formatearMoneda(proyeccionTotal/4)) MXN
            
            **Q2 (Meses 4-6): Consolidación**
            Objetivo: Optimizar y acelerar
            • Completar fondo de emergencia de 6 meses
            • Identificar ahorros adicionales del 10%
            • Iniciar pago acelerado de deudas caras
            • Meta parcial: $\(formatearMoneda(proyeccionTotal/2)) MXN acumulados
            
            **Q3 (Meses 7-9): Expansión**
            Objetivo: Diversificar y crecer
            • Iniciar estrategia de inversión conservadora
            • Diversificar ahorros (30% líquido, 70% inversión)
            • Evaluar oportunidades de ingreso adicional
            • Meta parcial: $\(formatearMoneda(proyeccionTotal * 0.75)) MXN acumulados
            
            **Q4 (Meses 10-12): Maximización**
            Objetivo: Optimizar rendimientos
            • Reinvertir rendimientos de inversiones
            • Evaluar metas financieras de mediano plazo
            • Planificar estrategia para el siguiente año
            • Meta final: $\(formatearMoneda(proyeccionTotal)) MXN + rendimientos
            
            **💡 IMPACTO TRANSFORMADOR:**
            
            Con $\(formatearMoneda(proyeccionTotal)) MXN al finalizar el año:
            
            **Opción 1: Patrimonio**
            • Enganche para vivienda o vehículo
            • Inversión en bien raíz
            • Capital para negocio propio
            
            **Opción 2: Inversión**
            • Portafolio diversificado de $\(formatearMoneda(proyeccionTotal * 0.7)) MXN
            • Reserva líquida de $\(formatearMoneda(proyeccionTotal * 0.3)) MXN
            • Rendimiento anual proyectado: 5-8%
            
            **Opción 3: Libertad Financiera**
            • Liquidación total de deudas
            • 12 meses de gastos en reserva
            • Inicio de independencia financiera
            
            **🔍 PROYECCIÓN A FUTURO:**
            Si mantiene esta disciplina por 2 años:
            • Ahorro total: $\(formatearMoneda(proyeccionTotal * 2)) MXN
            • Con inversión al 6% anual: $\(formatearMoneda(proyeccionTotal * 2.12)) MXN
            • Patrimonio construido que genera seguridad y opciones
            
            **⚡ FACTOR MULTIPLICADOR:**
            El verdadero poder de este plan está en el efecto compuesto. Cada mes que mantiene estos hábitos, no solo ahorra más, sino que genera oportunidades que antes no existían. En 5 años, podría tener un patrimonio de $\(formatearMoneda(proyeccionTotal * 5.5)) MXN o más.
            """
            
        default:
            return ""
        }
    }
    
    // MARK: - Análisis Positivo (Mejora 5-15%)
    private func generarAnalisisPositivo(meses: Int, proyeccionTotal: Double, diferencia: Double, balanceNuevo: Double, ingresos: Double) -> String {
        
        let tasaAhorro = (balanceNuevo / ingresos) * 100
        
        switch meses {
        case 3:
            return """
            **💰 PROYECCIÓN 3 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: MUY BUENA**
            
            Los ajustes propuestos mejorarán su balance mensual en $\(formatearMoneda(diferencia)) MXN. En un trimestre, acumulará $\(formatearMoneda(proyeccionTotal)) MXN adicionales.
            
            **🎯 ¿POR QUÉ ES VIABLE?**
            Con una tasa de ahorro del \(String(format: "%.1f", tasaAhorro))%, estos cambios son:
            • Sostenibles sin sacrificar calidad de vida
            • Suficientes para construir un colchón financiero
            • Base para mejorar gradualmente
            
            **📋 IMPLEMENTACIÓN TRIMESTRAL:**
            
            **Primer Mes:**
            • Implemente el 70% de los ajustes propuestos
            • Monitoree su adaptación a los nuevos límites
            • Identifique gastos hormiga adicionales
            • Ahorro esperado: $\(formatearMoneda(diferencia * 0.7)) MXN
            
            **Segundo Mes:**
            • Incremente al 90% de implementación
            • Automatice ahorros mediante transferencias
            • Evalúe qué ajustes son más fáciles de mantener
            • Ahorro esperado: $\(formatearMoneda(diferencia * 0.9)) MXN
            
            **Tercer Mes:**
            • Alcance el 100% de los ajustes
            • Busque optimizaciones adicionales del 3-5%
            • Defina destino del ahorro acumulado
            • Ahorro esperado: $\(formatearMoneda(diferencia)) MXN
            
            **💡 RECOMENDACIONES:**
            • Destine el ahorro a crear un fondo de emergencia inicial
            • Considere liquidar deudas pequeñas con el excedente
            • Evalúe al final del trimestre si puede incrementar los ajustes un 5%
            """
            
        case 6:
            return """
            **💰 PROYECCIÓN 6 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: MUY BUENA**
            
            Esta estrategia generará $\(formatearMoneda(proyeccionTotal)) MXN en seis meses, con una mejora constante de $\(formatearMoneda(diferencia)) MXN mensuales.
            
            **🎯 ¿POR QUÉ ES RECOMENDABLE?**
            Un semestre con \(String(format: "%.1f", tasaAhorro))% de ahorro le permite:
            • Formar hábitos financieros sostenibles
            • Construir un fondo de emergencia de 1-2 meses de gastos
            • Tener flexibilidad para imprevistos
            
            **📋 PLAN SEMESTRAL:**
            
            **Meses 1-2 (Ajuste):**
            • Reducción gradual de gastos del 70% al 90%
            • Identificación de resistencias y soluciones
            • Creación de hábitos alternativos
            • Acumulado esperado: $\(formatearMoneda(proyeccionTotal * 0.3)) MXN
            
            **Meses 3-4 (Consolidación):**
            • Mantenimiento del 90-100% de ajustes
            • Automatización de ahorros
            • Exploración de ahorros adicionales
            • Acumulado esperado: $\(formatearMoneda(proyeccionTotal * 0.65)) MXN
            
            **Meses 5-6 (Optimización):**
            • Cumplimiento al 100%
            • Búsqueda de eficiencias adicionales
            • Definición de estrategia siguiente
            • Acumulado final: $\(formatearMoneda(proyeccionTotal)) MXN
            
            **💡 AL FINALIZAR 6 MESES:**
            Con $\(formatearMoneda(proyeccionTotal)) MXN podrá:
            • Cubrir 1-2 meses de gastos en emergencias
            • Liquidar deudas pequeñas o tarjetas
            • Iniciar inversión conservadora
            • Planificar una meta financiera específica
            
            **🔍 FACTORES CRÍTICOS:**
            • Mantenga consistencia mes a mes
            • No compense reducciones con aumentos en otras categorías
            • Revise y ajuste cada 2 meses
            • Celebre logros parciales para mantener motivación
            """
            
        case 12:
            return """
            **💰 PROYECCIÓN 12 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: MUY BUENA**
            
            Un año de disciplina con estos ajustes generará $\(formatearMoneda(proyeccionTotal)) MXN, mejorando su situación financiera significativamente.
            
            **🎯 ¿POR QUÉ ES ESTRATÉGICO?**
            Doce meses con \(String(format: "%.1f", tasaAhorro))% de ahorro le posicionan para:
            • Alcanzar estabilidad financiera real
            • Eliminar preocupaciones por gastos inesperados
            • Iniciar construcción de patrimonio
            
            **📋 ROADMAP ANUAL:**
            
            **Trimestre 1 (Fundación):**
            • Implementación gradual de ajustes
            • Adaptación de estilo de vida
            • Inicio de fondo de emergencia
            • Meta: $\(formatearMoneda(proyeccionTotal * 0.23)) MXN
            
            **Trimestre 2 (Aceleración):**
            • Cumplimiento consistente al 90%+
            • Optimización de categorías
            • Completar 2-3 meses de fondo de emergencia
            • Meta: $\(formatearMoneda(proyeccionTotal * 0.48)) MXN acumulados
            
            **Trimestre 3 (Expansión):**
            • Explorar ahorros adicionales del 5%
            • Considerar inversiones conservadoras
            • Liquidar deudas pequeñas
            • Meta: $\(formatearMoneda(proyeccionTotal * 0.74)) MXN acumulados
            
            **Trimestre 4 (Consolidación):**
            • Maximizar eficiencias
            • Reinvertir parte del ahorro
            • Planificar año siguiente
            • Meta final: $\(formatearMoneda(proyeccionTotal)) MXN
            
            **💡 IMPACTO ANUAL:**
            
            **Seguridad Financiera:**
            • Fondo de emergencia de 3-4 meses
            • Sin preocupación por gastos imprevistos
            • Margen para oportunidades
            
            **Opciones Disponibles:**
            • Enganche parcial para auto o vivienda
            • Capital inicial para inversión
            • Liquidación de deudas de consumo
            • Fondo para educación o capacitación
            
            **Crecimiento Futuro:**
            Si continúa 2 años más:
            • Ahorro total: $\(formatearMoneda(proyeccionTotal * 2)) MXN
            • Posibilidad de inversiones mayores
            • Independencia financiera emergente
            
            **⚠️ FACTORES DE ÉXITO:**
            • Consistencia > Perfección
            • Ajustes mensuales según realidad
            • Celebración de hitos cada trimestre
            • Flexibilidad ante imprevistos
            • Revisión trimestral de estrategia
            """
            
        default:
            return ""
        }
    }
    
    // MARK: - Análisis Levemente Positivo (Mejora 1-5%)
    private func generarAnalisisLevementePositivo(meses: Int, proyeccionTotal: Double, diferencia: Double) -> String {
        
        switch meses {
        case 3:
            return """
            **💰 PROYECCIÓN 3 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: ACEPTABLE**
            
            Los ajustes generan una mejora modesta de $\(formatearMoneda(diferencia)) MXN mensuales. En 3 meses, acumulará $\(formatearMoneda(proyeccionTotal)) MXN adicionales.
            
            **🎯 ¿POR QUÉ SOLO ES ACEPTABLE?**
            Aunque positivo, el impacto es limitado porque:
            • Los ajustes son demasiado conservadores
            • El ahorro adicional es mínimo
            • El margen de mejora es amplio
            
            **💡 RECOMENDACIONES PARA POTENCIAR:**
            
            Para triplicar el impacto en 3 meses:
            • Identifique 2-3 categorías adicionales para reducir 10-15%
            • Elimine suscripciones o servicios no esenciales
            • Reduzca gastos hormiga (café, snacks, apps)
            • Busque alternativas más económicas en servicios fijos
            
            **📋 PLAN MEJORADO:**
            Si incrementa los ajustes en un 10% adicional:
            • Ahorro mensual: $\(formatearMoneda(diferencia * 3)) MXN
            • Proyección 3 meses: $\(formatearMoneda(proyeccionTotal * 3)) MXN
            • Impacto más significativo en su situación
            
            **⚠️ ADVERTENCIA:**
            Con ajustes tan moderados, tomará más tiempo alcanzar metas financieras importantes. Considere ser más agresivo si su situación lo permite.
            """
            
        case 6:
            return """
            **💰 PROYECCIÓN 6 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: ACEPTABLE PERO MEJORABLE**
            
            En medio año acumulará $\(formatearMoneda(proyeccionTotal)) MXN con estos ajustes, mejorando $\(formatearMoneda(diferencia)) MXN mensuales.
            
            **🎯 ANÁLISIS DEL IMPACTO:**
            Los ajustes actuales son un inicio, pero:
            • El ahorro es insuficiente para metas ambiciosas
            • Construir un fondo de emergencia tomará mucho tiempo
            • El potencial de optimización es considerable
            
            **💡 ESTRATEGIA DE MEJORA:**
            
            **Opción A: Incrementar Ajustes**
            • Adicione 10-15% de reducción en 2 categorías más
            • Nuevo ahorro mensual: $\(formatearMoneda(diferencia * 2.5)) MXN
            • Proyección 6 meses: $\(formatearMoneda(proyeccionTotal * 2.5)) MXN
            
            **Opción B: Aumentar Ingresos**
            • Busque fuente de ingreso adicional
            • Freelance, ventas, servicios
            • Combine con ahorros actuales
            
            **📋 PLAN DUAL 6 MESES:**
            
            **Meses 1-2: Baseline**
            • Implemente ajustes actuales
            • Identifique áreas de mejora adicionales
            • Acumulado: $\(formatearMoneda(proyeccionTotal * 0.33)) MXN
            
            **Meses 3-4: Intensificación**
            • Incremente ajustes en 10%
            • Elimine gastos superfluos identificados
            • Acumulado: $\(formatearMoneda(proyeccionTotal * 0.66)) MXN
            
            **Meses 5-6: Maximización**
            • Optimice todas las categorías
            • Explore ingreso adicional
            • Acumulado objetivo: $\(formatearMoneda(proyeccionTotal * 1.5)) MXN
            
            **⚠️ LLAMADO A LA ACCIÓN:**
            Está en buen camino, pero puede hacer más. Un esfuerzo adicional del 10% puede duplicar sus resultados en el mismo período.
            """
            
        case 12:
            return """
            **💰 PROYECCIÓN 12 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **✅ EVALUACIÓN: INICIO SÓLIDO CON MARGEN DE MEJORA**
            
            Un año con estos ajustes generará $\(formatearMoneda(proyeccionTotal)) MXN. Es un buen comienzo, pero existe potencial significativo de optimización.
            
            **🎯 PERSPECTIVA ANUAL:**
            
            **Lo Positivo:**
            • Establece disciplina financiera
            • Crea hábito de ahorro constante
            • Base para mejoras futuras
            
            **El Desafío:**
            • Insuficiente para metas grandes (enganche, inversión)
            • Fondo de emergencia tomará 2+ años
            • Velocidad de mejora financiera es lenta
            
            **💡 PLAN DE ACELERACIÓN:**
            
            **Trimestre 1: Establecimiento (Como está)**
            • Implemente ajustes actuales
            • Construya confianza y hábitos
            • Acumulado: $\(formatearMoneda(proyeccionTotal * 0.25)) MXN
            
            **Trimestre 2: Identificación**
            • Analice gastos profundamente
            • Encuentre 3-5 áreas adicionales de reducción
            • Objetivo: Incrementar ahorro 15%
            • Acumulado: $\(formatearMoneda(proyeccionTotal * 0.52)) MXN
            
            **Trimestre 3: Expansión**
            • Implemente ajustes adicionales
            • Explore fuentes de ingreso extra
            • Objetivo: Incrementar ahorro 25%
            • Acumulado: $\(formatearMoneda(proyeccionTotal * 0.82)) MXN
            
            **Trimestre 4: Maximización**
            • Optimice todas las categorías
            • Consolide ingresos adicionales
            • Objetivo: Duplicar ahorro mensual
            • Acumulado: $\(formatearMoneda(proyeccionTotal * 1.3)) MXN+
            
            **🚀 POTENCIAL SIN EXPLOTAR:**
            
            Con un esfuerzo adicional moderado:
            • Ahorro real posible: $\(formatearMoneda(proyeccionTotal * 2)) MXN
            • Tiempo para fondo de emergencia: 6-9 meses vs 18-24
            • Capital para inversión en Q3 vs Q4 del año 2
            
            **📊 COMPARACIÓN:**
            
            **Escenario Actual:**
            • Año 1: $\(formatearMoneda(proyeccionTotal)) MXN
            • Año 2: $\(formatearMoneda(proyeccionTotal * 2)) MXN
            • Total 2 años: $\(formatearMoneda(proyeccionTotal * 3)) MXN
            
            **Escenario Optimizado (+20% ajustes):**
            • Año 1: $\(formatearMoneda(proyeccionTotal * 1.5)) MXN
            • Año 2: $\(formatearMoneda(proyeccionTotal * 2)) MXN
            • Total 2 años: $\(formatearMoneda(proyeccionTotal * 3.5)) MXN
            
            **💬 MENSAJE FINAL:**
            Está tomando las decisiones correctas, pero tiene margen para ser más ambicioso. Un 20% de esfuerzo adicional puede generar 50% más de resultados. ¿Está listo para el siguiente nivel?
            """
            
        default:
            return ""
        }
    }
    
    // MARK: - Análisis Neutral (Sin cambios significativos)
    private func generarAnalisisNeutral(meses: Int, ajustes: [(categoria: String, porcentaje: Double, cambio: Double)]) -> String {
        
        let tienenAjustes = !ajustes.isEmpty
        
        if tienenAjustes {
            return """
            **⚖️ EVALUACIÓN: NEUTRAL**
            
            Los ajustes propuestos se compensan entre sí, resultando en un impacto neto mínimo en su balance mensual.
            
            **🎯 ¿QUÉ ESTÁ PASANDO?**
            • Incrementos en algunas categorías anulan reducciones en otras
            • El balance final es prácticamente idéntico al actual
            • No hay mejora ni deterioro significativo
            
            **💡 RECOMENDACIÓN:**
            
            Para que la simulación sea útil, considere uno de estos enfoques:
            
            **Opción A: Enfoque en Ahorro**
            • Reduzca gastos en 2-3 categorías sin aumentar otras
            • Meta: Mejorar balance mensual 10-15%
            
            **Opción B: Rebalanceo Estratégico**
            • Si debe aumentar gastos esenciales, compense reduciendo no esenciales
            • Mantenga o mejore el balance total
            
            **Opción C: Status Quo Consciente**
            • Si su situación actual es óptima, mantenerla es válido
            • Enfoque en mantener disciplina existente
            
            **📋 PRÓXIMOS PASOS:**
            • Revise sus prioridades financieras
            • Ajuste los sliders con un objetivo claro
            • Vuelva a simular con una estrategia definida
            """
        } else {
            return """
            **⚖️ EVALUACIÓN: SIN CAMBIOS**
            
            No se han realizado ajustes significativos en las categorías de gasto.
            
            **💡 PARA OBTENER INSIGHTS ÚTILES:**
            
            1. **Mueva los sliders** de al menos 2-3 categorías
            2. **Defina un objetivo**: ¿Ahorrar más? ¿Rebalancear gastos?
            3. **Sea realista** pero ambicioso en los ajustes
            4. **Vuelva a simular** para ver el impacto proyectado
            
            El simulador está listo para ayudarle una vez que defina sus ajustes.
            """
        }
    }
    
    // MARK: - Análisis Levemente Negativo (Empeora 1-5%)
    private func generarAnalisisLevementeNegativo(meses: Int, diferencia: Double, balanceNuevo: Double, ingresos: Double) -> String {
        
        let tasaAhorro = (balanceNuevo / ingresos) * 100
        
        switch meses {
        case 3:
            return """
            **⚠️ PROYECCIÓN 3 MESES: $\(formatearMoneda(balanceNuevo * Double(meses))) MXN**
            
            **❌ EVALUACIÓN: LIGERAMENTE NEGATIVA**
            
            Los ajustes propuestos reducen su balance mensual en $\(formatearMoneda(abs(diferencia))) MXN. En 3 meses, esto representa $\(formatearMoneda(abs(diferencia) * 3)) MXN menos en ahorro.
            
            **🎯 ¿POR QUÉ NO ES RECOMENDABLE?**
            • Disminuye su capacidad de ahorro del mes
            • Reduce su colchón financiero
            • Va en dirección contraria a objetivos financieros sanos
            
            **💡 ANÁLISIS DE LA SITUACIÓN:**
            
            Tasa de ahorro proyectada: \(String(format: "%.1f", tasaAhorro))%
            
            Si bien la reducción es pequeña, en un trimestre:
            • Perderá $\(formatearMoneda(abs(diferencia) * 3)) MXN de ahorro potencial
            • Su fondo de emergencia crecerá más lento
            • Tardará más en alcanzar metas financieras
            
            **📋 OPCIONES DE CORRECCIÓN:**
            
            **Opción 1: Revisar Prioridades**
            ¿Son realmente necesarios los incrementos propuestos?
            • Identifique cuáles aumentos son esenciales
            • Elimine los que sean "deseos" vs "necesidades"
            
            **Opción 2: Compensación**
            Si algunos aumentos son inevitables:
            • Reduzca otras categorías en igual o mayor proporción
            • Busque 2-3 gastos adicionales para eliminar
            • Objetivo: Al menos mantener balance actual
            
            **Opción 3: Aceptación Temporal**
            Si los aumentos son temporales (3 meses):
            • Considere si puede sostenerlo con sus reservas
            • Planifique cómo recuperar en meses siguientes
            • No exceda este período sin ajustar
            
            **⚠️ ADVERTENCIA:**
            Aunque la reducción parece pequeña, los malos hábitos financieros comienzan con "pequeños" incrementos que luego se vuelven permanentes.
            """
            
        case 6:
            return """
            **⚠️ PROYECCIÓN 6 MESES: $\(formatearMoneda(balanceNuevo * Double(meses))) MXN**
            
            **❌ EVALUACIÓN: REQUIERE ATENCIÓN**
            
            Esta estrategia reducirá su balance mensual en $\(formatearMoneda(abs(diferencia))) MXN. En medio año, habrá ahorrado $\(formatearMoneda(abs(diferencia) * 6)) MXN menos.
            
            **🎯 IMPACTO SEMESTRAL:**
            
            Con una tasa de ahorro del \(String(format: "%.1f", tasaAhorro))%:
            • Su capacidad de construir reservas disminuye
            • Metas financieras se retrasarán 2-3 meses
            • Mayor vulnerabilidad ante imprevistos
            
            **💡 ¿QUÉ ESTÁ COMPROMETIENDO?**
            
            En 6 meses, los $\(formatearMoneda(abs(diferencia) * 6)) MXN que dejará de ahorrar representan:
            • Medio mes de gastos en su fondo de emergencia
            • Oportunidad de liquidar una deuda pequeña
            • Capital inicial para inversión conservadora
            
            **📋 PLAN DE CORRECCIÓN:**
            
            **Fase 1 (Meses 1-2): Análisis**
            • Implemente solo los incrementos más críticos
            • Monitoree el impacto real en su flujo
            • Identifique 3 categorías para compensar
            • Objetivo: Reducir impacto negativo al 50%
            
            **Fase 2 (Meses 3-4): Rebalanceo**
            • Elimine incrementos no esenciales
            • Implemente reducciones compensatorias
            • Busque alternativas más económicas
            • Objetivo: Retornar a balance neutral
            
            **Fase 3 (Meses 5-6): Optimización**
            • Vuelva a proyectar positivamente
            • Recupere ahorro perdido
            • Establezca nueva línea base sostenible
            • Objetivo: Compensar pérdidas anteriores
            
            **🔍 ALTERNATIVAS ESTRATÉGICAS:**
            
            **Si los aumentos son inevitables:**
            • Busque fuente de ingreso adicional temporal
            • Venda artículos que no usa
            • Tome trabajos freelance o extra
            • Objetivo: $\(formatearMoneda(abs(diferencia))) MXN/mes adicionales
            
            **Si son discrecionales:**
            • Reevalúe la necesidad real
            • Busque versiones más económicas
            • Considere alternativas gratuitas
            • Postponga 3-6 meses hasta estabilizar
            
            **⚠️ SEÑAL DE ALERTA:**
            Seis meses con ahorro reducido pueden convertirse en un nuevo "normal". Es más fácil corregir ahora que después de formar el hábito.
            """
            
        case 12:
            return """
            **⚠️ PROYECCIÓN 12 MESES: $\(formatearMoneda(balanceNuevo * Double(meses))) MXN**
            
            **❌ EVALUACIÓN: PROBLEMÁTICA A LARGO PLAZO**
            
            Mantener estos ajustes durante un año reducirá su ahorro anual en $\(formatearMoneda(abs(diferencia) * 12)) MXN, con un impacto mensual de $\(formatearMoneda(abs(diferencia))) MXN.
            
            **🎯 IMPACTO ANUAL SIGNIFICATIVO:**
            
            Tasa de ahorro proyectada: \(String(format: "%.1f", tasaAhorro))%
            
            Los $\(formatearMoneda(abs(diferencia) * 12)) MXN que dejará de ahorrar en un año representan:
            • 1-2 meses completos de gastos de emergencia
            • Imposibilidad de cumplir metas financieras medianas
            • Retraso de 12-18 meses en objetivos patrimoniales
            • Pérdida de oportunidades de inversión
            
            **💡 CONSECUENCIAS A LARGO PLAZO:**
            
            **Año 1:** -$\(formatearMoneda(abs(diferencia) * 12)) MXN
            **Año 2 (si continúa):** -$\(formatearMoneda(abs(diferencia) * 24)) MXN acumulados
            **Costo de oportunidad:** -$\(formatearMoneda(abs(diferencia) * 24 * 1.06)) MXN (con interés 6%)
            
            **📋 PLAN DE RESCATE ANUAL:**
            
            **Q1: Evaluación Crítica**
            • Analice cada incremento propuesto
            • Clasifique en: Esencial, Importante, Deseable
            • Elimine todos los "Deseables"
            • Reduzca 50% de los "Importantes"
            • Objetivo: Reducir impacto negativo a -$\(formatearMoneda(abs(diferencia) * 0.3)) MXN/mes
            
            **Q2: Compensación**
            • Identifique 5 categorías para optimizar
            • Busque ahorros del 10-15% en cada una
            • Elimine suscripciones no usadas
            • Objetivo: Balance neutral ($/0 diferencia)
            
            **Q3: Reversión**
            • Implemente reducciones agresivas
            • Busque ingreso adicional
            • Cancele aumentos no esenciales
            • Objetivo: Balance positivo de +$\(formatearMoneda(abs(diferencia) * 0.5)) MXN/mes
            
            **Q4: Recuperación**
            • Maximice ahorros
            • Recupere terreno perdido
            • Establezca base sostenible
            • Objetivo: Compensar 50% de pérdidas del año
            
            **🚨 ESCENARIOS CRÍTICOS:**
            
            **Si continúa sin cambios:**
            • Patrimonio en 3 años: -$\(formatearMoneda(abs(diferencia) * 36)) MXN
            • Fondo de emergencia: Insuficiente o inexistente
            • Vulnerabilidad financiera: Alta
            • Estrés financiero: Crónico
            
            **Si corrige en Q2:**
            • Pérdida limitada: -$\(formatearMoneda(abs(diferencia) * 3)) MXN
            • Recuperación posible en Q3-Q4
            • Situación manejable
            
            **💡 ALTERNATIVAS ESTRATÉGICAS:**
            
            **Opción A: Ingreso Adicional**
            • Busque fuente de ingresos extra por $\(formatearMoneda(abs(diferencia) * 1.5)) MXN/mes
            • Cubra incrementos sin afectar ahorro
            • Puede ser temporal (6-12 meses)
            
            **Opción B: Replanteamiento Total**
            • Cuestione cada gasto propuesto
            • Busque alternativas creativas
            • Rediseñe estilo de vida para mantener ahorro
            
            **Opción C: Híbrida**
            • Acepte solo incrementos esenciales
            • Compense con reducciones equivalentes
            • Genere ingreso adicional para diferencia
            
            **⚡ LLAMADO URGENTE A LA ACCIÓN:**
            
            Un año de declive financiero es difícil de recuperar. Los hábitos que forme en los próximos 3 meses definirán su situación en los próximos 3 años.
            
            **La pregunta no es "¿puedo hacer estos incrementos?"**
            **sino "¿cuál es el costo real de no ahorrar este dinero?"**
            
            Considere seriamente replantear esta estrategia antes de implementarla.
            """
            
        default:
            return ""
        }
    }
    
    // MARK: - Análisis Negativo (Empeora 5-15%)
    private func generarAnalisisNegativo(meses: Int, proyeccionTotal: Double, diferencia: Double, balanceNuevo: Double) -> String {
        
        switch meses {
        case 3:
            return """
            **🚨 PROYECCIÓN 3 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **❌ EVALUACIÓN: NO RECOMENDABLE**
            
            Los ajustes propuestos reducen significativamente su balance mensual en $\(formatearMoneda(abs(diferencia))) MXN. En solo 3 meses, perderá $\(formatearMoneda(abs(diferencia) * 3)) MXN de capacidad de ahorro.
            
            **🎯 ¿POR QUÉ ES PROBLEMÁTICO?**
            • La reducción del ahorro es considerable (5-15%)
            • Compromete su estabilidad financiera a corto plazo
            • Puede iniciar una espiral de gasto insostenible
            • Elimina colchón para imprevistos
            
            **💡 IMPACTO TRIMESTRAL:**
            
            Lo que perderá en 3 meses:
            • $\(formatearMoneda(abs(diferencia) * 3)) MXN que podría ahorrar
            • Capacidad de responder a emergencias pequeñas
            • Progreso hacia metas financieras
            • Tranquilidad mental sobre dinero
            
            **📋 ACCIONES CORRECTIVAS URGENTES:**
            
            **INMEDIATO (Antes de implementar):**
            1. Revise CADA incremento propuesto
            2. Elimine todos los gastos "deseables"
            3. Reduzca a la mitad los "importantes"
            4. Mantenga solo los "esenciales críticos"
            
            **ALTERNATIVAS:**
            • ¿Puede postponer estos incrementos 3-6 meses?
            • ¿Existen versiones más económicas de lo que necesita?
            • ¿Puede generar ingreso adicional para cubrirlos?
            • ¿Son temporales o permanentes?
            
            **⚠️ ADVERTENCIA SERIA:**
            NO implemente estos cambios sin:
            • Tener un fondo de emergencia de al menos 2 meses
            • Un plan concreto para compensar la pérdida
            • Certeza de que los incrementos son inevitables
            
            **Recomendación:** Rediseñe completamente esta simulación.
            """
            
        case 6:
            return """
            **🚨 PROYECCIÓN 6 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **❌ EVALUACIÓN: RIESGOSA**
            
            Esta estrategia reducirá su ahorro semestral en $\(formatearMoneda(abs(diferencia) * 6)) MXN, con un impacto mensual de $\(formatearMoneda(abs(diferencia))) MXN.
            
            **🎯 IMPACTO CRÍTICO A 6 MESES:**
            
            **Lo que está en juego:**
            • $\(formatearMoneda(abs(diferencia) * 6)) MXN menos de reservas
            • Imposibilidad de construir fondo de emergencia
            • Mayor vulnerabilidad financiera
            • Dependencia del crédito ante imprevistos
            • Estrés financiero incrementado
            
            **💡 ANÁLISIS DE RIESGO:**
            
            Balance proyectado: $\(formatearMoneda(balanceNuevo)) MXN/mes
            
            Esto significa que:
            • Cualquier gasto inesperado >$\(formatearMoneda(balanceNuevo)) MXN será crisis
            • Una emergencia médica o auto se vuelve catastrófica
            • Deberá recurrir a crédito (generando más gastos)
            • Su score crediticio puede verse afectado
            
            **📋 PLAN DE RESCATE SEMESTRAL:**
            
            **Mes 1-2: Alto Total**
            • NO implemente los cambios como están
            • Analice profundamente cada incremento
            • Busque alternativas a TODOS los aumentos
            • Meta: Eliminar 70% de los incrementos
            
            **Mes 3-4: Evaluación de Esenciales**
            Si algunos incrementos son inevitables:
            • Implemente solo el 30% más crítico
            • Compense con reducciones agresivas en otras áreas
            • Busque ingreso adicional de $\(formatearMoneda(abs(diferencia) * 0.7)) MXN/mes
            • Meta: Impacto neto máximo -$\(formatearMoneda(abs(diferencia) * 0.3)) MXN/mes
            
            **Mes 5-6: Estabilización**
            • Revierta todos los cambios no esenciales
            • Retome crecimiento de ahorro
            • Compense pérdidas parcialmente
            • Meta: Volver a ahorro positivo
            
            **🔍 PREGUNTAS CRÍTICAS:**
            
            Antes de continuar, responda honestamente:
            
            1. **¿Son todos estos incrementos realmente necesarios?**
               - ¿O algunos son "deseos" disfrazados?
            
            2. **¿Puede cubrir una emergencia de $\(formatearMoneda(abs(diferencia) * 6)) MXN?**
               - Si no, estos cambios son muy riesgosos
            
            3. **¿Tiene plan B si la situación empeora?**
               - ¿Familia, crédito, reservas?
            
            4. **¿Puede generar ingreso adicional?**
               - Necesita $\(formatearMoneda(abs(diferencia))) MXN/mes extra
            
            **⚠️ SEÑALES DE ALERTA:**
            • Si su respuesta a #1 incluye "merezco" o "necesito darme gustos"
            • Si no tiene respuesta para #2
            • Si su plan B es "usar tarjeta de crédito"
            • Si no ha explorado seriamente #4
            
            **ENTONCES NO DEBE IMPLEMENTAR ESTOS CAMBIOS.**
            
            **💬 RECOMENDACIÓN FINAL:**
            Rediseñe completamente esta estrategia. Los números indican que está tomando decisiones financieras que podrían lamentar en 6-12 meses.
            """
            
        case 12:
            return """
            **🚨 PROYECCIÓN 12 MESES: $\(formatearMoneda(proyeccionTotal)) MXN**
            
            **❌ EVALUACIÓN: ALTAMENTE RIESGOSA**
            
            Implementar estos ajustes durante un año completo reducirá su capacidad de ahorro en $\(formatearMoneda(abs(diferencia) * 12)) MXN, con un impacto mensual sostenido de $\(formatearMoneda(abs(diferencia))) MXN.
            
            **🎯 CONSECUENCIAS ANUALES GRAVES:**
            
            **Pérdida Directa:**
            • $\(formatearMoneda(abs(diferencia) * 12)) MXN que no ahorrará
            • Equivalente a \(Int(abs(diferencia) / balanceNuevo * 12)) meses de gastos
            • Fondo de emergencia: Inexistente o insuficiente
            
            **Costo de Oportunidad:**
            • Inversión perdida: $\(formatearMoneda(abs(diferencia) * 12 * 1.06)) MXN (con 6% retorno)
            • Deudas que no pagará: $\(formatearMoneda(abs(diferencia) * 12)) MXN
            • Metas que no alcanzará: Enganche, auto, educación
            
            **Riesgo Financiero:**
            • Vulnerabilidad ante emergencias: MUY ALTA
            • Dependencia de crédito: CRÍTICA
            • Estrés financiero: CRÓNICO
            • Movilidad social: ESTANCADA
            
            **💡 ESCENARIOS FUTUROS:**
            
            **Si continúa este camino:**
            
            **Año 1:**
            • Ahorro perdido: -$\(formatearMoneda(abs(diferencia) * 12)) MXN
            • Emergencias cubiertas con: Crédito/deuda
            • Situación: Deterioro gradual
            
            **Año 2:**
            • Ahorro perdido acumulado: -$\(formatearMoneda(abs(diferencia) * 24)) MXN
            • Deudas acumuladas por emergencias: -$\(formatearMoneda(abs(diferencia) * 6)) MXN
            • Intereses pagados: -$\(formatearMoneda(abs(diferencia) * 1.5)) MXN
            • Situación: Espiral descendente
            
            **Año 3:**
            • Total perdido: -$\(formatearMoneda(abs(diferencia) * 36 + abs(diferencia) * 10)) MXN
            • Score crediticio: Afectado
            • Opciones financieras: Muy limitadas
            • Situación: Crisis financiera potencial
            
            **📋 PLAN DE INTERVENCIÓN ANUAL:**
            
            **OPCIÓN A: ABORTAR CAMBIOS**
            **La más sensata - Recomendada**
            
            • NO implemente estos ajustes
            • Rediseñe completamente su estrategia
            • Enfóquese en mantener o incrementar ahorro
            • Busque alternativas para cualquier "necesidad" nueva
            
            **OPCIÓN B: MODIFICACIÓN RADICAL**
            **Solo si es absolutamente necesario**
            
            Q1: Análisis de Supervivencia
            • Implemente SOLO incrementos de vida o muerte
            • Debe tener justificación médica/legal/familiar
            • Compense con reducciones del doble en otras áreas
            • Meta: Impacto máximo -$\(formatearMoneda(abs(diferencia) * 0.2)) MXN/mes
            
            Q2: Generación de Ingresos
            • DEBE encontrar ingreso adicional de $\(formatearMoneda(abs(diferencia))) MXN/mes
            • No es opcional - es requisito
            • Freelance, segundo trabajo, venta de servicios
            • Meta: Compensar 100% del impacto negativo
            
            Q3: Estabilización
            • Revierta TODOS los cambios no vitales
            • Implemente ahorros agresivos
            • Construya reserva mínima de 3 meses
            • Meta: Volver a balance positivo
            
            Q4: Recuperación
            • Ahorro intensivo para compensar pérdidas
            • Eliminar cualquier deuda generada
            • Establecer base sostenible
            • Meta: Estar en mejor posición que inicio del año
            
            **OPCIÓN C: TRANSFORMACIÓN TOTAL**
            **Alternativa radical pero efectiva**
            
            Si los incrementos son por "lifestyle":
            • Cuestione fundamentalmente sus valores
            • ¿Qué es más importante: compras ahora o seguridad después?
            • Considere cambios estructurales (vivienda, transporte)
            • Busque reducir gastos fijos en 20-30%
            
            **🔍 PREGUNTAS EXISTENCIALES:**
            
            1. **¿Dentro de 5 años, agradecerá estos incrementos?**
               - O lamentará no haber ahorrado ese dinero?
            
            2. **¿Qué haría si perdiera su ingreso mañana?**
               - Sin ahorros, ¿cuánto tiempo sobreviviría?
            
            3. **¿Está eligiendo placer inmediato sobre seguridad?**
               - Sea brutalmente honesto con usted mismo
            
            4. **¿Qué sacrificará del futuro por el presente?**
               - Porque ALGO tendrá que sacrificar
            
            **⚡ VERDADES DIFÍCILES:**
            
            • Los gastos discrecionales son fáciles de incrementar pero difíciles de reducir
            • La "lifestyle inflation" es una trampa financiera real
            • La mayoría de quienes no ahorran "planeaban hacerlo después"
            • "Después" nunca llega si no haces cambios NOW
            • Tu yo del futuro te está rogando que no hagas esto
            
            **💬 MENSAJE FINAL:**
            
            Esta simulación muestra un camino financiero preocupante. Los números no mienten - esta estrategia lo aleja de la seguridad financiera y lo acerca a la dependencia y estrés perpetuos.
            
            **No es tarde para cambiar el rumbo.**
            **Pero es tarde para ignorar las señales.**
            
            Rediseñe esta simulación con un enfoque en REDUCIR gastos, no aumentarlos. Su futuro financiero depende de las decisiones que tome hoy.
            
            **¿Elegirá la seguridad o el gasto?**
            **La respuesta define su futuro.**
            """
            
        default:
            return ""
        }
    }
    
    // MARK: - Análisis Crítico (Balance negativo o >15% empeoramiento)
    private func generarAnalisisCritico(meses: Int, balanceNuevo: Double, ajustes: [(categoria: String, porcentaje: Double, cambio: Double)]) -> String {
        
        let esBalanceNegativo = balanceNuevo < 0
        
        switch meses {
        case 3:
            return """
            **🚨 PROYECCIÓN 3 MESES: SITUACIÓN CRÍTICA**
            
            **❌ EVALUACIÓN: INSOSTENIBLE**
            
            \(esBalanceNegativo ?
            "Los ajustes propuestos generan un BALANCE MENSUAL NEGATIVO de $\(formatearMoneda(abs(balanceNuevo))) MXN. Esto significa que gastará más de lo que gana CADA MES." :
            "Los ajustes propuestos reducen drásticamente su capacidad de ahorro en más del 15%. Esta situación es financieramente insostenible.")
            
            **🎯 ALERTA ROJA:**
            
            \(esBalanceNegativo ?
            """
            • Gastará $\(formatearMoneda(abs(balanceNuevo) * 3)) MXN MÁS de lo que tiene en 3 meses
            • Necesitará crédito o deuda para cubrir la diferencia
            • Intereses de deuda: +$\(formatearMoneda(abs(balanceNuevo) * 3 * 0.03)) MXN (3%/mes promedio)
            • Espiral de deuda iniciando
            """ :
            """
            • Ahorro mensual prácticamente eliminado
            • Sin colchón para emergencias
            • Alta dependencia de que "nada salga mal"
            • Un imprevisto = crisis financiera
            """)
            
            **💡 POR QUÉ ESTO ES UNA CRISIS:**
            
            En solo 3 meses:
            • Destruye cualquier progreso financiero
            • Crea dependencia de crédito
            • Genera estrés financiero severo
            • Compromete su futuro económico
            
            **📋 ACCIÓN INMEDIATA REQUERIDA:**
            
            **🛑 NO IMPLEMENTE ESTOS CAMBIOS**
            
            **PASO 1: DETENER**
            • Congele TODOS los incrementos propuestos
            • No agregue ni un solo gasto adicional
            • Mantenga su situación actual
            
            **PASO 2: ANALIZAR**
            ¿Por qué propuso estos incrementos?
            • Identifique necesidad vs deseo
            • Busque alternativas gratuitas o de bajo costo
            • Evalúe si está viviendo por encima de sus medios
            
            **PASO 3: REDISEÑAR**
            • Vuelva a la simulación
            • Esta vez REDUZCA gastos en 3-5 categorías
            • Objetivo: Incrementar ahorro 10-15%
            • Cree una situación financiera SOSTENIBLE
            
            **⚠️ CONSECUENCIAS SI IGNORA ESTO:**
            • Deuda en 1-2 meses
            • Score crediticio dañado en 3-6 meses
            • Posible reporte en buró de crédito
            • Dificultad para créditos futuros
            • Estrés financiero crónico
            
            **💬 MENSAJE URGENTE:**
            Esta simulación es una ADVERTENCIA, no un plan. Los números están gritando "NO HAGAS ESTO". Por favor, escuche lo que las matemáticas le están diciendo.
            
            **Necesita ayuda profesional:**
            • Agende cita con asesor financiero de Banorte
            • Considere asesoría de presupuesto gratuita
            • Busque educación financiera
            
            Su futuro económico está en juego.
            """
            
        case 6:
            return """
            **🚨 PROYECCIÓN 6 MESES: CRISIS FINANCIERA**
            
            **❌ EVALUACIÓN: CATASTRÓFICA**
            
            \(esBalanceNegativo ?
            "Estos ajustes crean un DÉFICIT MENSUAL de $\(formatearMoneda(abs(balanceNuevo))) MXN. En 6 meses, habrá gastado $\(formatearMoneda(abs(balanceNuevo) * 6)) MXN MÁS de lo que tiene." :
            "La reducción del ahorro supera el 15%, comprometiendo gravemente su estabilidad financiera a mediano plazo.")
            
            **🎯 MAGNITUD DE LA CRISIS:**
            
            \(esBalanceNegativo ?
            """
            **Déficit semestral:** $\(formatearMoneda(abs(balanceNuevo) * 6)) MXN
            **Intereses de deuda (18% anual):** $\(formatearMoneda(abs(balanceNuevo) * 6 * 0.09)) MXN
            **Costo total real:** $\(formatearMoneda(abs(balanceNuevo) * 6 * 1.09)) MXN
            **Score crediticio:** En riesgo severo
            **Capacidad de endeudamiento futuro:** Muy comprometida
            """ :
            """
            **Ahorro eliminado:** $\(formatearMoneda(abs(balanceNuevo) * 6)) MXN
            **Fondo de emergencia:** Inexistente
            **Vulnerabilidad financiera:** MÁXIMA
            **Riesgo de crisis por imprevisto:** 90%+
            **Capacidad de recuperación:** Muy limitada
            """)
            
            **💡 ESCENARIO REALISTA EN 6 MESES:**
            
            **Mes 1-2:**
            • Comienza a usar tarjetas de crédito para cubrir gastos
            • Pequeños faltantes de $\(formatearMoneda(abs(balanceNuevo))) MXN/mes
            • Pensamiento: "Es temporal, lo recuperaré"
            
            **Mes 3-4:**
            • Deuda en tarjetas: $\(formatearMoneda(abs(balanceNuevo) * 3)) MXN
            • Pagos mínimos consumiendo mayor parte del ingreso
            • Estrés financiero aumentando
            • Pensamiento: "¿Cómo llegué aquí?"
            
            **Mes 5-6:**
            • Deuda total: $\(formatearMoneda(abs(balanceNuevo) * 5)) MXN+
            • Intereses mensuales: $\(formatearMoneda(abs(balanceNuevo) * 5 * 0.03)) MXN
            • Llamadas de cobranza iniciando
            • Score crediticio cayendo
            • Pensamiento: "Estoy atrapado"
            
            **📋 PLAN DE RESCATE FINANCIERO:**
            
            **PRIORIDAD MÁXIMA: NO IMPLEMENTAR**
            
            **Fase de Crisis (Ahora):**
            • Cancele inmediatamente estos planes
            • Congele todo gasto no esencial
            • Evalúe su situación con asesor financiero
            • Considere ayuda psicológica si hay gasto emocional
            
            **Fase de Estabilización (Mes 1-2):**
            • Audite TODOS sus gastos actuales
            • Identifique 5-10 gastos para eliminar
            • Reduzca gastos variables en 20-30%
            • Busque ingreso adicional urgentemente
            • Meta: Alcanzar balance de $/0 (no negativo)
            
            **Fase de Construcción (Mes 3-4):**
            • Implemente ahorros agresivos
            • Reduzca gastos en 30% vs situación actual
            • Maximice ingresos (segundo trabajo, ventas)
            • Cree fondo de emergencia de 1 mes
            • Meta: Balance positivo de +$\(formatearMoneda(abs(balanceNuevo) * 0.5)) MXN/mes
            
            **Fase de Recuperación (Mes 5-6):**
            • Ahorro intensivo
            • Fondo de emergencia: 2-3 meses
            • Reducir dependencia de crédito
            • Establecer base sostenible
            • Meta: Seguridad financiera básica restaurada
            
            **🔍 SEÑALES DE PROBLEMAS SUBYACENTES:**
            
            Si propuso estos incrementos, pregúntese:
            
            1. **¿Está en negación sobre su situación financiera?**
               - Muchos evitan ver los números reales
            
            2. **¿Usa el gasto como escape emocional?**
               - Compras impulsivas, retail therapy
            
            3. **¿Siente presión social para gastar más?**
               - Amigos, familia, redes sociales
            
            4. **¿Tiene creencias limitantes sobre el dinero?**
               - "No soy bueno con el dinero", "Nunca seré rico"
            
            **⚡ VERDADES BRUTALES:**
            
            • Su actual propuesta financiera es un camino directo a la bancarrota
            • Los números no negocian ni perdonan
            • Cada mes que pasa sin cambios hace más difícil la recuperación
            • Nadie va a rescatarlo - usted debe rescatarse
            • "No es cuánto ganas, es cuánto gastas"
            
            **💬 LLAMADO DE EMERGENCIA:**
            
            Esta simulación NO es un plan - es una ADVERTENCIA SERIA.
            
            **NECESITA:**
            • Asesoría financiera profesional INMEDIATA
            • Evaluar cambios estructurales (vivienda, auto, lifestyle)
            • Posible terapia si hay gasto emocional
            • Apoyo familiar o de confianza
            • Educación financiera intensiva
            
            **NO ESPERE:**
            • A que "mejore la situación"
            • A que "le aumenten el sueldo"
            • A "el próximo mes"
            • A tocar fondo
            
            **ACTÚE HOY:**
            1. Cancele estos planes inmediatamente
            2. Agende cita con asesor financiero
            3. Rediseñe simulación con REDUCCIONES
            4. Comprométase con el cambio
            
            Su futuro financiero -y su tranquilidad mental- dependen de las decisiones que tome EN ESTE MOMENTO.
            
            **¿Está listo para cambiar el rumbo?**
            """
            
        case 12:
            return """
            **🚨 PROYECCIÓN 12 MESES: DESASTRE FINANCIERO**
            
            **❌ EVALUACIÓN: CATASTRÓFICA E INSOSTENIBLE**
            
            \(esBalanceNegativo ?
            "Estos ajustes crean un DÉFICIT ANUAL de $\(formatearMoneda(abs(balanceNuevo) * 12)) MXN. Esta situación conducirá inevitablemente a bancarrota personal si se implementa." :
            "La eliminación práctica del ahorro durante un año completo representa un riesgo financiero inaceptable que puede tomar años recuperar.")
            
            **🎯 DIMENSIÓN DEL DESASTRE:**
            
            \(esBalanceNegativo ?
            """
            **Déficit anual bruto:** $\(formatearMoneda(abs(balanceNuevo) * 12)) MXN
            **Intereses y cargos (25% anual):** $\(formatearMoneda(abs(balanceNuevo) * 12 * 0.25)) MXN
            **Costo total primer año:** $\(formatearMoneda(abs(balanceNuevo) * 12 * 1.25)) MXN
            
            **Proyección año 2 (si continúa):**
            **Deuda acumulada:** $\(formatearMoneda(abs(balanceNuevo) * 24 * 1.25)) MXN
            **Intereses sobre intereses:** $\(formatearMoneda(abs(balanceNuevo) * 24 * 0.35)) MXN
            **Patrimonio neto:** NEGATIVO
            
            **Proyección año 3:**
            **Deuda total:** $\(formatearMoneda(abs(balanceNuevo) * 36 * 1.4)) MXN+
            **Situación:** Impagable con ingreso actual
            **Opciones:** Liquidación, reestructura, bancarrota
            """ :
            """
            **Ahorro anual eliminado:** $\(formatearMoneda(abs(balanceNuevo) * 12)) MXN
            **Costo de oportunidad (inversión 7%):** $\(formatearMoneda(abs(balanceNuevo) * 12 * 1.07)) MXN
            **Deudas no pagadas:** Acumulándose
            **Fondo de emergencia:** Cero
            **Patrimonio construido:** Cero
            **Vulnerabilidad total:** Máxima
            
            **Proyección año 2-3:**
            **Pérdida acumulada:** $\(formatearMoneda(abs(balanceNuevo) * 36)) MXN
            **Más intereses de deuda:** $\(formatearMoneda(abs(balanceNuevo) * 18)) MXN
            **Oportunidades perdidas:** Incalculables
            **Movilidad social:** Estancada o descendente
            """)
            
            **💡 LA ESPIRAL DESCENDENTE:**
            
            **Trimestre 1 (Meses 1-3): El Inicio**
            • Deuda en tarjetas: $\(formatearMoneda(abs(balanceNuevo) * 3)) MXN
            • Intereses empezando a acumularse
            • Primera sensación de "esto no estaba planeado"
            • Crédito aún disponible
            • Score sin daño visible aún
            
            **Trimestre 2 (Meses 4-6): La Realización**
            • Deuda acumulada: $\(formatearMoneda(abs(balanceNuevo) * 6)) MXN
            • Pagos mínimos de $\(formatearMoneda(abs(balanceNuevo) * 0.25)) MXN/mes
            • Límites de tarjetas alcanzándose
            • Primera llamada de recordatorio de pago
            • Estrés financiero considerable
            • Relaciones personales afectándose
            
            **Trimestre 3 (Meses 7-9): La Crisis**
            • Deuda total: $\(formatearMoneda(abs(balanceNuevo) * 9)) MXN
            • Pidiendo prestado a familia/amigos
            • Considerando préstamos de nómina
            • Vendiendo pertenencias
            • Depresión y ansiedad relacionadas con dinero
            • Problemas de sueño por preocupación financiera
            
            **Trimestre 4 (Meses 10-12): El Colapso**
            • Deuda final: $\(formatearMoneda(abs(balanceNuevo) * 12 * 1.25)) MXN
            • Score crediticio dañado severamente
            • Reporte en buró de crédito
            • Llamadas de cobranza diarias
            • Posibilidad de juicio mercantil
            • Relaciones familiares tensas o rotas
            • Salud mental y física afectadas
            
            **📋 INTERVENCIÓN DE RESCATE (SI AÚN ES POSIBLE):**
            
            **REALIDAD CHECK:**
            Si está considerando seriamente implementar estos cambios, es muy probable que:
            • Ya tenga problemas financieros subyacentes
            • Esté en negación sobre su situación real
            • Necesite ayuda profesional urgente
            • Deba hacer cambios estructurales mayores
            
            **PLAN DE RESCATE RADICAL:**
            
            **Fase 1: Intervención de Crisis (Semana 1-2)**
            • Congele TODO gasto no esencial AHORA
            • Cancele suscripciones, membresías, servicios
            • Agende cita con asesor financiero MAÑANA
            • Si hay gasto emocional, busque terapia
            • Confíe en alguien de confianza sobre su situación
            
            **Fase 2: Auditoría Total (Mes 1)**
            • Registre CADA peso que gasta durante 30 días
            • Identifique gastos hormiga (probablemente $\(formatearMoneda(abs(balanceNuevo) * 0.3)) MXN/mes)
            • Evalúe gastos fijos (renta, auto, seguros)
            • Pregunta crítica: "¿Estoy viviendo por encima de mis medios?"
            
            **Fase 3: Transformación (Meses 2-4)**
            • Reduzca gastos en 30-40% (no es negociable)
            • Considere cambios estructurales:
              * Mudarse a vivienda más económica
              * Vender auto costoso por uno accesible
              * Cancelar servicios premium
            • Busque aumentar ingresos 30-50%:
              * Segundo trabajo temporal
              * Freelance
              * Vender servicios/productos
            
            **Fase 4: Reconstrucción (Meses 5-8)**
            • Con gastos reducidos + ingresos aumentados
            • Debe generar surplus de $\(formatearMoneda(abs(balanceNuevo) * 2)) MXN/mes
            • Construir fondo de emergencia agresivamente
            • Pagar deudas existentes
            • Establecer presupuesto sostenible
            
            **Fase 5: Estabilización (Meses 9-12)**
            • Fondo de emergencia: 3 meses mínimo
            • Deudas caras eliminadas
            • Sistema de gastos sostenible establecido
            • Hábitos financieros transformados
            • Tasa de ahorro: 15-20% mínimo
            
            **🔍 PREGUNTAS EXISTENCIALES FINALES:**
            
            Estas son preguntas que DEBE responder honestamente:
            
            **1. ¿Por qué propuso estos incrementos?**
            • Presión social para "vivir bien"
            • Insatisfacción con vida actual
            • Escape emocional vía compras
            • Creencias limitantes sobre dinero
            • Negación de realidad financiera
            
            **2. ¿Qué está dispuesto a sacrificar?**
            • Porque ALGO se sacrificará, voluntaria o involuntariamente
            • ¿Seguridad futura por placer presente?
            • ¿Relaciones familiares por mantener imagen?
            • ¿Salud mental por estrés financiero?
            
            **3. ¿Qué legado financiero quiere dejar?**
            • ¿Deudas y problemas para sus hijos?
            • ¿Dependencia financiera en la vejez?
            • ¿O estabilidad y opciones?
            
            **4. ¿Cuál es su valor de la libertad?**
            • Libertad financiera vs esclavitud de deuda
            • Opciones vs desesperación
            • Tranquilidad vs ansiedad constante
            
            **⚡ VERDADES INELUDIBLES:**
            
            • **Matemáticas no mienten:** Esta propuesta es financieramente suicida
            • **Tiempo no perdona:** Cada día sin cambiar aumenta el daño
            • **Nadie lo salvará:** Usted es su único rescate posible
            • **Cambio es posible:** Pero requiere honestidad brutal y acción inmediata
            • **Futuro no está escrito:** Pero lo está escribiendo AHORA con cada decisión
            
            **💬 MENSAJE FINAL Y URGENTE:**
            
            Esta simulación es un ESPEJO mostrando un camino hacia el desastre financiero.
            
            **NO ES:**
            • Una exageración
            • Un escenario improbable
            • Algo que "no puede pasar"
            
            **ES:**
            • Matemática pura y simple
            • El futuro si implementa estos cambios
            • Una advertencia que DEBE escuchar
            
            **LO QUE NECESITA ENTENDER:**
            
            Millones de personas están en crisis financiera porque:
            1. Ignoraron advertencias como esta
            2. Pensaron "a mí no me pasará"
            3. Pusieron deseos sobre necesidades
            4. No actuaron cuando tenían oportunidad
            
            **NO SEA UNA ESTADÍSTICA MÁS.**
            
            **ACCIÓN INMEDIATA REQUERIDA:**
            
            1. **AHORA:** Cancele estos planes permanentemente
            2. **HOY:** Llame a asesor financiero de Banorte
            3. **ESTA SEMANA:** Cree nuevo plan basado en REDUCCIÓN de gastos
            4. **ESTE MES:** Implemente cambios estructurales mayores
            5. **ESTE AÑO:** Transforme completamente su relación con el dinero
            
            **Su vida financiera -y posiblemente su vida entera- está en un punto de inflexión.**
            
            **¿Elegirá el camino difícil ahora que lleva a libertad?**
            **¿O el camino fácil ahora que lleva a prisión financiera?**
            
            **La decisión es suya.**
            **Pero la consecuencia no es negociable.**
            
            **Actúe. Ahora.**
            """
            
        default:
            return ""
        }
    }
    
    // MARK: - Recomendaciones Personalizadas
    func generarRecomendaciones(metricas: Metricas) async throws -> [String] {
        // Simular procesamiento
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        var recomendaciones: [String] = []
        
        // Análisis de tasa de ahorro
        if metricas.ahorro_porcentaje < 10 {
            recomendaciones.append("Incremente su ahorro al 15% reduciendo gastos discrecionales en \(obtenerCategoríaMayor(metricas.gastos_por_categoria))")
        } else if metricas.ahorro_porcentaje < 20 {
            recomendaciones.append("Alcance la meta del 20% de ahorro para fortalecer su estabilidad financiera")
        } else {
            recomendaciones.append("Excelente tasa de ahorro del \(String(format: "%.1f", metricas.ahorro_porcentaje))%. Considere opciones de inversión")
        }
        
        // Análisis de categoría principal
        let categoríaPrincipal = obtenerCategoríaMayor(metricas.gastos_por_categoria)
        let gastoCategoria = metricas.gastos_por_categoria[categoríaPrincipal] ?? 0
        let porcentajeCategoria = (gastoCategoria / metricas.gastos_totales) * 100
        
        if porcentajeCategoria > 40 {
            recomendaciones.append("Optimice gastos en \(categoríaPrincipal) que representa el \(String(format: "%.0f", porcentajeCategoria))% de sus gastos")
        } else {
            recomendaciones.append("Mantenga el equilibrio en sus categorías de gasto, están bien distribuidas")
        }
        
        // Análisis de balance
        if metricas.balance < metricas.gastos_totales * 3 {
            let mesesFaltantes = 6 - Int(metricas.balance / metricas.gastos_totales)
            recomendaciones.append("Fortalezca su fondo de emergencia, le faltan \(mesesFaltantes) meses de gastos para mayor seguridad")
        } else {
            recomendaciones.append("Su fondo de emergencia está sólido. Explore opciones de inversión con su asesor bancario")
        }
        
        return recomendaciones
    }
    
    // MARK: - Funciones Auxiliares
    private func formatearMoneda(_ valor: Double) -> String {
        return String(format: "%.2f", valor)
    }
    
    private func obtenerCategoríaMayor(_ categorias: [String: Double]) -> String {
        return categorias.max(by: { $0.value < $1.value })?.key ?? "gastos generales"
    }
}

// MARK: - Tipos de Escenario
enum TipoEscenario {
    case muyPositivo        // Mejora >15%
    case positivo           // Mejora 5-15%
    case levementePositivo  // Mejora 1-5%
    case neutral            // Cambio <1%
    case levementeNegativo  // Empeora 1-5%
    case negativo           // Empeora 5-15%
    case critico            // Empeora >15% o balance negativo
}

// MARK: - Errores
enum GeminiError: LocalizedError {
    case servicioNoDisponible
    case datosIncompletos
    
    var errorDescription: String? {
        switch self {
        case .servicioNoDisponible:
            return "El servicio de asistente está temporalmente no disponible"
        case .datosIncompletos:
            return "No se pudieron obtener los datos necesarios para el análisis"
        }
    }
}

// MARK: - Extension para NetworkManager (Compatibilidad)
extension NetworkManager {
    func enviarMensajeChatConGemini(
        perfil: String,
        usuarioId: String,
        mensaje: String,
        metricas: Metricas?
    ) async throws -> String {
        return try await GeminiService.shared.preguntaAsistenteFinanciero(
            mensaje: mensaje,
            metricas: metricas,
            contextoAdicional: "Tipo de cuenta: \(perfil)"
        )
    }
    
    func generarRecomendacionesConGemini(metricas: Metricas) async throws -> [String] {
        return try await GeminiService.shared.generarRecomendaciones(metricas: metricas)
    }
    
    func analizarSimulacionConGemini(
        ingresosActuales: Double,
        gastosActuales: Double,
        ajustes: [String: Double],
        meses: Int,
        gastosPorCategoria: [String: Double]
    ) async throws -> String {
        return try await GeminiService.shared.analizarSimulacion(
            ingresosActuales: ingresosActuales,
            gastosActuales: gastosActuales,
            ajustesPropuestos: ajustes,
            mesesProyeccion: meses,
            gastosPorCategoria: gastosPorCategoria
        )
    }
}

// MARK: - Helper para testing
#if DEBUG
extension GeminiService {
    func testConnection() async {
        print("✅ Servicio de IA simulado funcionando correctamente")
        print("📝 Usando respuestas predeterminadas locales")
        print("🎯 Sistema de análisis de simulaciones avanzado activo")
    }
}
#endif
