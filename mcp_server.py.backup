"""
Servidor MCP para Análisis Financiero Banorte
Gestiona finanzas personales y empresariales con IA
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import pandas as pd
import numpy as np
from collections import defaultdict
import uvicorn
import os
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Depends
import requests

import google.generativeai as genai

genai.configure(api_key="AIzaSyANN9r5oAhWlouUZOTQVhpUjVybAcYhqiA")


security = HTTPBearer()
AUTH_SERVER_URL = "http://127.0.0.1:8001"

def verificar_autenticacion(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        response = requests.get(
            f"{AUTH_SERVER_URL}/verificar-token",
            headers={"Authorization": f"Bearer {credentials.credentials}"}
        )
        if response.status_code == 200:
            return response.json()
        else:
            raise HTTPException(status_code=401, detail="Token inválido")
    except requests.RequestException:
        raise HTTPException(status_code=503, detail="Servidor de autenticación no disponible")

def convertir_numpy_a_python(obj):
    if isinstance(obj, np.integer):
        return int(obj)
    elif isinstance(obj, np.floating):
        return float(obj)
    elif isinstance(obj, np.ndarray):
        return obj.tolist()
    elif isinstance(obj, dict):
        return {key: convertir_numpy_a_python(value) for key, value in obj.items()}
    elif isinstance(obj, list):
        return [convertir_numpy_a_python(item) for item in obj]
    else:
        return obj

app = FastAPI(title="Banorte Financial MCP Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TransaccionPersonal(BaseModel):
    id_usuario: int
    fecha: str
    categoria: str
    descripcion: str
    monto: float
    tipo: str

class TransaccionEmpresarial(BaseModel):
    empresa_id: int
    fecha: str
    tipo: str
    concepto: str
    categoria: str
    monto: float

class SimulacionRequest(BaseModel):
    perfil: str
    usuario_id: int
    ajustes: Dict[str, float]
    meses_proyeccion: int = 3

class ChatRequest(BaseModel):
    perfil: str
    usuario_id: int
    mensaje: str

datos_personales: List[Dict] = []
datos_empresariales: List[Dict] = []

def cargar_datos_desde_excel():
    global datos_personales, datos_empresariales
    try:
        if os.path.exists("finanzas_personales.xlsx"):
            df_personal = pd.read_excel("finanzas_personales.xlsx")
            if 'id_usuario' in df_personal.columns:
                df_personal['id_usuario'] = df_personal['id_usuario'].astype(int)
            if 'fecha' in df_personal.columns:
                df_personal['fecha'] = pd.to_datetime(df_personal['fecha'], dayfirst=True).dt.strftime('%Y-%m-%d')
            datos_personales = df_personal.to_dict('records')
            print(f"✅ Cargadas {len(datos_personales)} transacciones personales desde Excel")
            if datos_personales:
                print(f" Ejemplo: {datos_personales[0]}")
        else:
            print("⚠️ Archivo 'finanzas_personales.xlsx' no encontrado")
    except Exception as e:
        print(f"❌ Error cargando finanzas personales: {e}")
        import traceback
        traceback.print_exc()

    try:
        if os.path.exists("finanzas_empresa.xlsx"):
            df_empresarial = pd.read_excel("finanzas_empresa.xlsx")
            if 'empresa_id' in df_empresarial.columns:
                df_empresarial['empresa_id'] = df_empresarial['empresa_id'].astype(str)
            if 'fecha' in df_empresarial.columns:
                df_empresarial['fecha'] = pd.to_datetime(df_empresarial['fecha'], dayfirst=True).dt.strftime('%Y-%m-%d')
            datos_empresariales = df_empresarial.to_dict('records')
            print(f"✅ Cargadas {len(datos_empresariales)} transacciones empresariales desde Excel")
            if datos_empresariales:
                print(f" Ejemplo: {datos_empresariales[0]}")
        else:
            print("⚠️ Archivo 'finanzas_empresa.xlsx' no encontrado")
            cargar_datos_ejemplo_empresariales()
    except Exception as e:
        print(f"❌ Error cargando finanzas empresariales: {e}")
        import traceback
        traceback.print_exc()
        cargar_datos_ejemplo_empresariales()

def cargar_datos_ejemplo_empresariales():
    global datos_empresariales
    datos_empresariales = [
        {"empresa_id": 101, "fecha": "2025-09-15", "tipo": "gasto", "concepto": "Campaña redes sociales", "categoria": "marketing", "monto": 8000},
        {"empresa_id": 101, "fecha": "2025-09-20", "tipo": "gasto", "concepto": "Nómina equipo", "categoria": "salarios", "monto": 45000},
        {"empresa_id": 101, "fecha": "2025-09-25", "tipo": "ingreso", "concepto": "Venta productos", "categoria": "ventas", "monto": 85000},
        {"empresa_id": 101, "fecha": "2025-10-01", "tipo": "gasto", "concepto": "Servidores AWS", "categoria": "infraestructura", "monto": 3500},
        {"empresa_id": 101, "fecha": "2025-10-05", "tipo": "gasto", "concepto": "Material oficina", "categoria": "costos", "monto": 2200},
        {"empresa_id": 101, "fecha": "2025-10-10", "tipo": "ingreso", "concepto": "Servicios consultoría", "categoria": "ventas", "monto": 65000},
        {"empresa_id": 101, "fecha": "2025-10-20", "tipo": "gasto", "concepto": "Campaña digital octubre", "categoria": "marketing", "monto": 5000},
    ]

cargar_datos_desde_excel()

# ==================== FUNCIÓN SIMULADOR NUEVA ====================

def simular_proyeccion(datos: List[Dict], usuario_id, ajustes: Dict[str, float], meses: int) -> Dict[str, Any]:
    """
    Simula proyección financiera con MÚLTIPLES ESCENARIOS y RECOMENDACIONES
    
    Versión mejorada con:
    - 3 escenarios automáticos
    - Análisis de riesgos
    - Recomendaciones accionables
    - Detección de puntos críticos
    """
    datos_filtrados = [
        d for d in datos
        if d.get('id_usuario') == usuario_id or d.get('empresa_id') == usuario_id
    ]

    if not datos_filtrados:
        return {"error": "No hay datos suficientes para simular"}

    df = pd.DataFrame(datos_filtrados)

    ingresos_promedio = df[df['tipo'] == 'ingreso']['monto'].mean()
    gastos_por_cat = df[df['tipo'] == 'gasto'].groupby('categoria')['monto'].mean().to_dict()
    total_gastos_promedio = sum(gastos_por_cat.values())

    escenarios = {}

    escenarios['base'] = _simular_escenario_interno(
        ingresos_promedio, gastos_por_cat, meses, 
        factor_ingresos=1.0, factor_gastos=1.0, ajustes=ajustes
    )

    escenarios['optimista'] = _simular_escenario_interno(
        ingresos_promedio, gastos_por_cat, meses,
        factor_ingresos=1.15, factor_gastos=0.90, ajustes={}
    )

    escenarios['pesimista'] = _simular_escenario_interno(
        ingresos_promedio, gastos_por_cat, meses,
        factor_ingresos=0.85, factor_gastos=1.10, ajustes={}
    )

    recomendaciones = []
    balance_actual = ingresos_promedio - total_gastos_promedio

    if balance_actual < 0:
        deficit = abs(balance_actual)
        recomendaciones.append({
            "urgencia": "ALTA",
            "titulo": "Déficit mensual detectado",
            "descripcion": f"Gastas ${deficit:,.2f} más de lo que ingresas cada mes",
            "accion": f"Reduce gastos o aumenta ingresos en ${deficit:,.2f}/mes",
            "impacto": deficit * meses
        })

    for categoria, gasto in sorted(gastos_por_cat.items(), key=lambda x: x[1], reverse=True)[:2]:
        porcentaje = (gasto / total_gastos_promedio * 100) if total_gastos_promedio > 0 else 0

        umbrales = {
            "restaurantes": 15,
            "entretenimiento": 10,
            "transporte": 20,
            "marketing": 20,
            "costos": 30
        }

        umbral = umbrales.get(categoria, 20)

        if porcentaje > umbral:
            ahorro_potencial = gasto * (porcentaje - umbral) / 100
            recomendaciones.append({
                "urgencia": "MEDIA",
                "titulo": f"Optimizar gastos en {categoria}",
                "descripcion": f"Representa {porcentaje:.1f}% del total (recomendado: {umbral}%)",
                "accion": f"Reducir {categoria} en {porcentaje - umbral:.0f}%",
                "impacto": ahorro_potencial * meses
            })

    if escenarios['pesimista']['balance_total'] < 0:
        recomendaciones.append({
            "urgencia": "CRÍTICA",
            "titulo": "Plan de contingencia necesario",
            "descripcion": f"En escenario pesimista tendrías un déficit de ${abs(escenarios['pesimista']['balance_total']):,.2f}",
            "accion": "Crear fondo de emergencia de 3-6 meses de gastos",
            "impacto": abs(escenarios['pesimista']['balance_total'])
        })

    nivel_riesgo = "BAJO"
    if escenarios['base']['balance_total'] < 0:
        nivel_riesgo = "CRÍTICO"
    elif escenarios['pesimista']['balance_total'] < 0:
        nivel_riesgo = "ALTO"
    elif balance_actual < ingresos_promedio * 0.1:
        nivel_riesgo = "MEDIO"

    return {
        "escenarios": escenarios,
        "recomendaciones": sorted(recomendaciones, key=lambda x: {"CRÍTICA": 3, "ALTA": 2, "MEDIA": 1}.get(x["urgencia"], 0), reverse=True),
        "analisis_riesgo": {
            "nivel": nivel_riesgo,
            "balance_mensual_actual": round(balance_actual, 2),
            "meses_proyectados": meses,
            "mejor_escenario": round(escenarios['optimista']['balance_total'], 2),
            "peor_escenario": round(escenarios['pesimista']['balance_total'], 2),
            "diferencia_escenarios": round(escenarios['optimista']['balance_total'] - escenarios['pesimista']['balance_total'], 2)
        },
        "resumen": _generar_resumen_ejecutivo(escenarios, nivel_riesgo, balance_actual, meses)
    }

def _simular_escenario_interno(ingresos_prom, gastos_por_cat, meses, factor_ingresos, factor_gastos, ajustes):
    ingresos_proyectados = []
    gastos_proyectados = []
    balance_mensual = []
    saldo_acumulado = 0

    for mes in range(meses):
        ingreso_mes = ingresos_prom * factor_ingresos
        ingresos_proyectados.append(round(ingreso_mes, 2))

        gasto_mes = 0
        for categoria, gasto_base in gastos_por_cat.items():
            factor_ajuste = 1 + (ajustes.get(categoria, 0) / 100)
            gasto_mes += gasto_base * factor_gastos * factor_ajuste

        gastos_proyectados.append(round(gasto_mes, 2))

        balance_mes = ingreso_mes - gasto_mes
        balance_mensual.append(round(balance_mes, 2))
        saldo_acumulado += balance_mes

    return {
        "ingresos_proyectados": ingresos_proyectados,
        "gastos_proyectados": gastos_proyectados,
        "balance_mensual": balance_mensual,
        "balance_total": round(saldo_acumulado, 2),
        "ingreso_total": round(sum(ingresos_proyectados), 2),
        "gasto_total": round(sum(gastos_proyectados), 2)
    }

def _generar_resumen_ejecutivo(escenarios, nivel_riesgo, balance_actual, meses):
    base = escenarios['base']
    optimista = escenarios['optimista']
    pesimista = escenarios['pesimista']

    emoji_riesgo = {
        "CRÍTICO": "🔴",
        "ALTO": "🟠",
        "MEDIO": "🟡",
        "BAJO": "🟢"
    }

    return f"""
{emoji_riesgo.get(nivel_riesgo, '⚪')} RIESGO: {nivel_riesgo}

📊 PROYECCIÓN A {meses} MESES:
• Balance actual: ${balance_actual:,.2f}/mes
• Escenario base: ${base['balance_total']:,.2f}
• Mejor caso: ${optimista['balance_total']:,.2f}
• Peor caso: ${pesimista['balance_total']:,.2f}

💡 CONCLUSIÓN:
{_conclusion_segun_escenarios(base, optimista, pesimista)}
    """.strip()

def _conclusion_segun_escenarios(base, optimista, pesimista):
    if base['balance_total'] > 0 and pesimista['balance_total'] > 0:
        return "✅ Situación financiera sólida. Incluso en escenario pesimista mantienes balance positivo."
    elif base['balance_total'] > 0 and pesimista['balance_total'] < 0:
        return "⚠️ Situación estable pero vulnerable. Crea un fondo de emergencia."
    else:
        return "🚨 Situación crítica. Necesitas tomar acción inmediata para equilibrar tus finanzas."

# ... (El resto de los endpoints y funciones de tu archivo siguen igual.)

# Funciones de análisis
def calcular_metricas(datos: List[Dict], usuario_id) -> Dict[str, Any]:
    """Calcula métricas financieras principales
    
    Args:
        datos: Lista de transacciones
        usuario_id: Puede ser int (para personal) o str (para empresarial, ej: "E016")
    """
    
    # Filtrar datos del usuario (funciona con int o string)
    datos_filtrados = [
        d for d in datos 
        if d.get('id_usuario') == usuario_id or d.get('empresa_id') == usuario_id
    ]
    
    print(f"🔍 Calculando métricas para usuario: {usuario_id} (tipo: {type(usuario_id).__name__})")
    print(f"   Total datos disponibles: {len(datos)}")
    print(f"   Datos filtrados para este usuario: {len(datos_filtrados)}")
    
    if not datos_filtrados:
        print(f"⚠️  No se encontraron datos para usuario: {usuario_id}")
        # Mostrar algunos IDs disponibles para debugging
        ids_disponibles = set()
        for d in datos[:10]:  # Solo primeros 10 para no saturar
            ids_disponibles.add(d.get('id_usuario') or d.get('empresa_id'))
        print(f"   IDs disponibles (muestra): {ids_disponibles}")
        
        return {
            "ingresos_totales": 0.0,
            "gastos_totales": 0.0,
            "balance": 0.0,
            "ahorro_porcentaje": 0.0,
            "gastos_por_categoria": {},
            "tendencia": "neutral",
            "promedio_gasto_diario": 0.0
        }
    
    df = pd.DataFrame(datos_filtrados)
    
    # Convertir fecha a datetime
    df['fecha'] = pd.to_datetime(df['fecha'])
    df['mes'] = df['fecha'].dt.to_period('M')
    
    # Calcular métricas
    ingresos = df[df['tipo'] == 'ingreso']['monto'].sum()
    gastos = df[df['tipo'] == 'gasto']['monto'].sum()
    balance = ingresos - gastos
    
    # Gastos por categoría
    gastos_por_cat = df[df['tipo'] == 'gasto'].groupby('categoria')['monto'].sum().to_dict()
    
    # Tendencia mes actual vs anterior
    mes_actual = df['mes'].max()
    mes_anterior = mes_actual - 1
    
    gastos_actual = df[(df['mes'] == mes_actual) & (df['tipo'] == 'gasto')]['monto'].sum()
    gastos_anterior = df[(df['mes'] == mes_anterior) & (df['tipo'] == 'gasto')]['monto'].sum()
    
    if gastos_anterior > 0:
        cambio = ((gastos_actual - gastos_anterior) / gastos_anterior) * 100
        tendencia = "aumentando" if cambio > 5 else "disminuyendo" if cambio < -5 else "estable"
    else:
        tendencia = "neutral"
    
    # Promedio diario
    dias_con_gastos = len(df[df['tipo'] == 'gasto'])
    promedio_gasto = gastos / max(dias_con_gastos, 1)
    
    resultado = {
        "ingresos_totales": float(round(ingresos, 2)),
        "gastos_totales": float(round(gastos, 2)),
        "balance": float(round(balance, 2)),
        "ahorro_porcentaje": float(round((balance / ingresos * 100) if ingresos > 0 else 0, 2)),
        "gastos_por_categoria": {k: float(round(v, 2)) for k, v in gastos_por_cat.items()},
        "tendencia": tendencia,
        "promedio_gasto_diario": float(round(promedio_gasto, 2))
    }
    
    print(f"✅ Métricas calculadas exitosamente:")
    print(f"   Ingresos: ${resultado['ingresos_totales']:,.2f}")
    print(f"   Gastos: ${resultado['gastos_totales']:,.2f}")
    print(f"   Balance: ${resultado['balance']:,.2f}")
    
    return resultado

def generar_recomendaciones(metricas: Dict[str, Any], perfil: str) -> List[str]:
    """Genera recomendaciones personalizadas"""
    recomendaciones = []
    
    # Análisis de ahorro
    if metricas['ahorro_porcentaje'] < 10:
        recomendaciones.append(
            f"⚠️ Tu tasa de ahorro es de {metricas['ahorro_porcentaje']:.1f}%. "
            "Se recomienda ahorrar al menos el 20% de tus ingresos para tener un colchón financiero."
        )
    elif metricas['ahorro_porcentaje'] > 30:
        recomendaciones.append(
            f"✅ ¡Excelente! Estás ahorrando {metricas['ahorro_porcentaje']:.1f}% de tus ingresos. "
            "Considera invertir parte de tus ahorros para maximizar tu patrimonio."
        )
    
    # Análisis por categoría
    gastos_cat = metricas['gastos_por_categoria']
    total_gastos = metricas['gastos_totales']
    
    if perfil == "personal":
        if 'restaurantes' in gastos_cat and (gastos_cat['restaurantes'] / total_gastos) > 0.15:
            porcentaje = (gastos_cat['restaurantes'] / total_gastos) * 100
            recomendaciones.append(
                f"🍽️ Tus gastos en restaurantes representan {porcentaje:.1f}% del total. "
                "Considera cocinar más en casa para reducir este gasto."
            )
        
        if 'entretenimiento' in gastos_cat and (gastos_cat['entretenimiento'] / total_gastos) > 0.10:
            porcentaje = (gastos_cat['entretenimiento'] / total_gastos) * 100
            recomendaciones.append(
                f"🎮 Entretenimiento representa {porcentaje:.1f}% de tus gastos. "
                "Busca alternativas gratuitas o de bajo costo para optimizar este rubro."
            )
    
    elif perfil == "empresarial":
        if 'marketing' in gastos_cat and (gastos_cat['marketing'] / total_gastos) > 0.25:
            porcentaje = (gastos_cat['marketing'] / total_gastos) * 100
            recomendaciones.append(
                f"📊 Marketing representa {porcentaje:.1f}% de tus gastos operativos. "
                "Evalúa el ROI de tus campañas para optimizar la inversión publicitaria."
            )
    
    # Tendencia
    if metricas['tendencia'] == "aumentando":
        recomendaciones.append(
            "📈 Tus gastos están aumentando respecto al mes anterior. "
            "Revisa tus hábitos de consumo y establece límites por categoría."
        )
    elif metricas['tendencia'] == "disminuyendo":
        recomendaciones.append(
            "📉 ¡Bien hecho! Tus gastos han disminuido. "
            "Mantén estos hábitos y considera invertir la diferencia."
        )
    
    if not recomendaciones:
        recomendaciones.append(
            "✨ Tus finanzas están en buen camino. "
            "Continúa monitoreando tus gastos y ajustando tu presupuesto según sea necesario."
        )
    
    return recomendaciones

def simular_proyeccion(datos: List[Dict], usuario_id, ajustes: Dict[str, float], meses: int) -> Dict[str, Any]:
    """Simula proyección financiera con ajustes
    
    Args:
        usuario_id: Puede ser int o str
    """
    datos_filtrados = [
        d for d in datos 
        if d.get('id_usuario') == usuario_id or d.get('empresa_id') == usuario_id
    ]
    
    if not datos_filtrados:
        return {"error": "No hay datos suficientes para simular"}
    
    df = pd.DataFrame(datos_filtrados)
    
    # Calcular promedios actuales
    ingresos_promedio = df[df['tipo'] == 'ingreso']['monto'].mean()
    gastos_por_cat = df[df['tipo'] == 'gasto'].groupby('categoria')['monto'].mean().to_dict()
    
    # Aplicar ajustes (porcentajes)
    gastos_ajustados = {}
    for cat, gasto_actual in gastos_por_cat.items():
        ajuste_porcentaje = ajustes.get(cat, 0)
        gastos_ajustados[cat] = gasto_actual * (1 + ajuste_porcentaje / 100)
    
    total_gastos_ajustados = sum(gastos_ajustados.values())
    balance_mensual = ingresos_promedio - total_gastos_ajustados
    balance_proyectado = balance_mensual * meses
    
    # Comparar con escenario actual
    total_gastos_actuales = sum(gastos_por_cat.values())
    balance_actual = ingresos_promedio - total_gastos_actuales
    diferencia = balance_proyectado - (balance_actual * meses)
    
    return {
        "ingresos_mensuales": round(ingresos_promedio, 2),
        "gastos_actuales": round(total_gastos_actuales, 2),
        "gastos_proyectados": round(total_gastos_ajustados, 2),
        "balance_mensual_actual": round(balance_actual, 2),
        "balance_mensual_proyectado": round(balance_mensual, 2),
        "balance_total_proyectado": round(balance_proyectado, 2),
        "diferencia_vs_actual": round(diferencia, 2),
        "meses": meses,
        "gastos_por_categoria": {k: round(v, 2) for k, v in gastos_ajustados.items()}
    }


# Endpoints
@app.get("/")
def root():
    return {
        "message": "Banorte Financial MCP Server",
        "version": "1.0.0",
        "endpoints": ["/analyze", "/recommendations", "/simulate", "/chat", "/update-transaction", "/summary"]
    }

@app.get("/analyze")
def analyze(
    perfil: str,
    usuario_id: str,
    auth: Dict = Depends(verificar_autenticacion)
):
    """Analiza métricas financieras (requiere autenticación)"""
    
    # Verificar que el usuario solo acceda a sus propios datos
    if perfil == "personal":
        if auth.get('id_usuario') != int(usuario_id):
            raise HTTPException(
                status_code=403,
                detail="No tienes permiso para acceder a estos datos"
            )
    else:  # empresarial
        if auth.get('empresa_id') != usuario_id:
            raise HTTPException(
                status_code=403,
                detail="No tienes permiso para acceder a estos datos"
            )
    
    # Resto del código permanece igual
    datos = datos_personales if perfil == "personal" else datos_empresariales
    
    if perfil == "personal":
        usuario_id_procesado = int(usuario_id)
    else:
        usuario_id_procesado = usuario_id
    
    metricas = calcular_metricas(datos, usuario_id_procesado)
    return {"status": "success", "metricas": metricas}

@app.get("/recommendations")
def recommendations(
    perfil: str,
    usuario_id: str,
    auth: Dict = Depends(verificar_autenticacion)
):
    """Genera recomendaciones (requiere autenticación)"""
    # Verificación de permisos
    if perfil == "personal":
        if auth.get('id_usuario') != int(usuario_id):
            raise HTTPException(status_code=403, detail="Acceso denegado")
    else:
        if auth.get('empresa_id') != usuario_id:
            raise HTTPException(status_code=403, detail="Acceso denegado")
    
    # Código original
    datos = datos_personales if perfil == "personal" else datos_empresariales
    usuario_id_procesado = int(usuario_id) if perfil == "personal" else usuario_id
    metricas = calcular_metricas(datos, usuario_id_procesado)
    recs = generar_recomendaciones(metricas, perfil)
    return {"status": "success", "recomendaciones": recs}

@app.post("/simulate")
def simulate(request: SimulacionRequest, auth: Dict = Depends(verificar_autenticacion)):
    """Simula escenarios (requiere autenticación)"""
    # Verificación de permisos
    if request.perfil == "personal":
        if auth.get('id_usuario') != request.usuario_id:
            raise HTTPException(status_code=403, detail="Acceso denegado")
    else:
        if auth.get('empresa_id') != str(request.usuario_id):
            raise HTTPException(status_code=403, detail="Acceso denegado")
    
    resultado = simular_proyeccion(datos, usuario_id_procesado, request.ajustes, request.meses_proyeccion)
    return {"status": "success", "simulacion": resultado}

@app.post("/chat")
def chat(request: ChatRequest, auth: Dict = Depends(verificar_autenticacion)):
    """Chat financiero (requiere autenticación)"""
    # Verificación similar a los anteriores
    if request.perfil == "personal":
        if auth.get('id_usuario') != request.usuario_id:
            raise HTTPException(status_code=403, detail="Acceso denegado")
    else:
        if auth.get('empresa_id') != str(request.usuario_id):
            raise HTTPException(status_code=403, detail="Acceso denegado")
    
    metricas = calcular_metricas(datos, usuario_id_procesado)
    
    mensaje_lower = request.mensaje.lower()
    
    # Análisis simple de intención
    if "cuánto" in mensaje_lower and ("gast" in mensaje_lower or "diner" in mensaje_lower):
        respuesta = f"Has gastado ${metricas['gastos_totales']:,.2f} en total. Tu balance actual es de ${metricas['balance']:,.2f}."
    
    elif "ahorro" in mensaje_lower or "ahorr" in mensaje_lower:
        respuesta = f"Tu tasa de ahorro es de {metricas['ahorro_porcentaje']:.1f}%. Estás ahorrando ${metricas['balance']:,.2f} del total de ingresos."
    
    elif "categoría" in mensaje_lower or "categoria" in mensaje_lower or "más gasto" in mensaje_lower:
        if metricas['gastos_por_categoria']:
            cat_max = max(metricas['gastos_por_categoria'].items(), key=lambda x: x[1])
            respuesta = f"Tu categoría con más gastos es '{cat_max[0]}' con ${cat_max[1]:,.2f}."
        else:
            respuesta = "No tienes gastos registrados aún."
    
    elif "recomienda" in mensaje_lower or "consejo" in mensaje_lower:
        recs = generar_recomendaciones(metricas, request.perfil)
        respuesta = "\n\n".join(recs)
    
    elif "ingreso" in mensaje_lower:
        respuesta = f"Tus ingresos totales son de ${metricas['ingresos_totales']:,.2f}."
    
    else:
        respuesta = (
            f"📊 Resumen financiero:\n"
            f"• Ingresos: ${metricas['ingresos_totales']:,.2f}\n"
            f"• Gastos: ${metricas['gastos_totales']:,.2f}\n"
            f"• Balance: ${metricas['balance']:,.2f}\n"
            f"• Ahorro: {metricas['ahorro_porcentaje']:.1f}%\n"
            f"• Tendencia: {metricas['tendencia']}"
        )
    
    return {"status": "success", "respuesta": respuesta}

@app.post("/update-transaction")
def update_transaction(transaccion: dict):
    """Agrega o actualiza una transacción"""
    perfil = transaccion.get('perfil', 'personal')
    
    if perfil == "personal":
        try:
            trans = TransaccionPersonal(**transaccion)
            datos_personales.append(trans.dict())
            return {"status": "success", "message": "Transacción personal agregada"}
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))
    else:
        try:
            trans = TransaccionEmpresarial(**transaccion)
            datos_empresariales.append(trans.dict())
            return {"status": "success", "message": "Transacción empresarial agregada"}
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

@app.get("/summary")
def summary(
    perfil: str,
    usuario_id: str,
    auth: Dict = Depends(verificar_autenticacion)
):
    """Resumen completo (requiere autenticación)"""
    # Verificación de permisos
    if perfil == "personal":
        if auth.get('id_usuario') != int(usuario_id):
            raise HTTPException(status_code=403, detail="Acceso denegado")
    else:
        if auth.get('empresa_id') != usuario_id:
            raise HTTPException(status_code=403, detail="Acceso denegado")
    
    metricas = calcular_metricas(datos, usuario_id_procesado)
    recs = generar_recomendaciones(metricas, perfil)
    
    total_transacciones = len([
        d for d in datos 
        if d.get('id_usuario') == usuario_id_procesado or d.get('empresa_id') == usuario_id_procesado
    ])
    
    return {
        "status": "success",
        "resumen": {
            "metricas": metricas,
            "recomendaciones": recs,
            "total_transacciones": total_transacciones
        }
    }



# Después de cargar_datos_desde_excel() y antes de usarlos:
try:
    df_personal = pd.DataFrame(datos_personales) if datos_personales else pd.DataFrame(columns=[
        'id_usuario', 'fecha', 'categoria', 'descripcion', 'monto', 'tipo'
    ])
except Exception as e:
    print("Error creando df_personal:", e)
    df_personal = pd.DataFrame(columns=['id_usuario', 'fecha', 'categoria', 'descripcion', 'monto', 'tipo'])

try:
    df_empresa = pd.DataFrame(datos_empresariales) if datos_empresariales else pd.DataFrame(columns=[
        'empresa_id', 'fecha', 'tipo', 'concepto', 'categoria', 'monto'
    ])
except Exception as e:
    print("Error creando df_empresa:", e)
    df_empresa = pd.DataFrame(columns=['empresa_id', 'fecha', 'tipo', 'concepto', 'categoria', 'monto'])





# ============================================================================
# NUEVOS ENDPOINTS PARA GESTIÓN DE TRANSACCIONES
# ============================================================================

@app.get("/api/transacciones")
async def obtener_transacciones(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Obtiene todas las transacciones del usuario autenticado"""
    user_info = verificar_autenticacion(credentials)
    tipo_cuenta = user_info.get("tipo_cuenta")
    
    if tipo_cuenta == "personal":
        id_usuario = user_info.get("id_usuario")
        transacciones = df_personal[df_personal['id_usuario'] == id_usuario].copy()
        
        transacciones['fecha'] = pd.to_datetime(transacciones['fecha'])
        transacciones = transacciones.sort_values('fecha', ascending=False)
        
        resultado = transacciones.to_dict('records')
        
        for trans in resultado:
            trans['fecha'] = trans['fecha'].strftime('%Y-%m-%d')
            
        return {
            "success": True,
            "transacciones": resultado,
            "total": len(resultado)
        }
        
    elif tipo_cuenta == "empresa":
        empresa_id = user_info.get("empresa_id")
        transacciones = df_empresa[df_empresa['empresa_id'] == empresa_id].copy()
        
        transacciones['fecha'] = pd.to_datetime(transacciones['fecha'])
        transacciones = transacciones.sort_values('fecha', ascending=False)
        
        resultado = transacciones.to_dict('records')
        
        for trans in resultado:
            trans['fecha'] = trans['fecha'].strftime('%Y-%m-%d')
            
        return {
            "success": True,
            "transacciones": resultado,
            "total": len(resultado)
        }
    
    raise HTTPException(status_code=400, detail="Tipo de cuenta no válido")


@app.post("/api/transacciones")
async def crear_transaccion(
    transaccion: Dict[str, Any],
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Crea una nueva transacción"""
    user_info = verificar_autenticacion(credentials)
    tipo_cuenta = user_info.get("tipo_cuenta")
    
    try:
        if tipo_cuenta == "personal":
            id_usuario = user_info.get("id_usuario")
            
            nueva_trans = {
                'id_usuario': id_usuario,
                'fecha': transaccion.get('fecha', datetime.now().strftime('%Y-%m-%d')),
                'categoria': transaccion['categoria'],
                'descripcion': transaccion['descripcion'],
                'monto': float(transaccion['monto']),
                'tipo': transaccion['tipo']
            }
            
            global df_personal
            nueva_fila = pd.DataFrame([nueva_trans])
            df_personal = pd.concat([df_personal, nueva_fila], ignore_index=True)
            
            df_personal.to_excel('finanzas_personales.xlsx', index=False)
            
            return {
                "success": True,
                "message": "Transacción creada exitosamente",
                "transaccion": nueva_trans
            }
            
        elif tipo_cuenta == "empresa":
            empresa_id = user_info.get("empresa_id")
            
            nueva_trans = {
                'empresa_id': empresa_id,
                'fecha': transaccion.get('fecha', datetime.now().strftime('%Y-%m-%d')),
                'tipo': transaccion['tipo'],
                'concepto': transaccion['concepto'],
                'categoria': transaccion['categoria'],
                'monto': float(transaccion['monto'])
            }
            
            global df_empresa
            nueva_fila = pd.DataFrame([nueva_trans])
            df_empresa = pd.concat([df_empresa, nueva_fila], ignore_index=True)
            
            df_empresa.to_excel('finanzas_empresa.xlsx', index=False)
            
            return {
                "success": True,
                "message": "Transacción creada exitosamente",
                "transaccion": nueva_trans
            }
            
    except KeyError as e:
        raise HTTPException(status_code=400, detail=f"Campo requerido faltante: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al crear transacción: {str(e)}")


@app.delete("/api/transacciones/{index}")
async def eliminar_transaccion(
    index: int,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Elimina una transacción por índice"""
    user_info = verificar_autenticacion(credentials)
    tipo_cuenta = user_info.get("tipo_cuenta")
    
    try:
        if tipo_cuenta == "personal":
            global df_personal
            
            id_usuario = user_info.get("id_usuario")
            if index >= len(df_personal):
                raise HTTPException(status_code=404, detail="Transacción no encontrada")
                
            if df_personal.iloc[index]['id_usuario'] != id_usuario:
                raise HTTPException(status_code=403, detail="No tienes permiso para eliminar esta transacción")
            
            df_personal = df_personal.drop(index).reset_index(drop=True)
            df_personal.to_excel('finanzas_personales.xlsx', index=False)
            
            return {"success": True, "message": "Transacción eliminada"}
            
        elif tipo_cuenta == "empresa":
            global df_empresa
            empresa_id = user_info.get("empresa_id")
            
            if index >= len(df_empresa):
                raise HTTPException(status_code=404, detail="Transacción no encontrada")
                
            if df_empresa.iloc[index]['empresa_id'] != empresa_id:
                raise HTTPException(status_code=403, detail="No tienes permiso para eliminar esta transacción")
            
            df_empresa = df_empresa.drop(index).reset_index(drop=True)
            df_empresa.to_excel('finanzas_empresa.xlsx', index=False)
            
            return {"success": True, "message": "Transacción eliminada"}
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al eliminar: {str(e)}")


@app.get("/api/transacciones/filtrar")
async def filtrar_transacciones(
    categoria: Optional[str] = None,
    tipo: Optional[str] = None,
    fecha_inicio: Optional[str] = None,
    fecha_fin: Optional[str] = None,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Filtra transacciones por diferentes criterios"""
    user_info = verificar_autenticacion(credentials)
    tipo_cuenta = user_info.get("tipo_cuenta")
    
    if tipo_cuenta == "personal":
        id_usuario = user_info.get("id_usuario")
        transacciones = df_personal[df_personal['id_usuario'] == id_usuario].copy()
    else:
        empresa_id = user_info.get("empresa_id")
        transacciones = df_empresa[df_empresa['empresa_id'] == empresa_id].copy()
    
    if categoria:
        transacciones = transacciones[transacciones['categoria'] == categoria]
    
    if tipo and tipo_cuenta == "personal":
        transacciones = transacciones[transacciones['tipo'] == tipo]
    
    if fecha_inicio:
        transacciones['fecha'] = pd.to_datetime(transacciones['fecha'])
        transacciones = transacciones[transacciones['fecha'] >= fecha_inicio]
    
    if fecha_fin:
        transacciones['fecha'] = pd.to_datetime(transacciones['fecha'])
        transacciones = transacciones[transacciones['fecha'] <= fecha_fin]
    
    transacciones = transacciones.sort_values('fecha', ascending=False)
    
    resultado = transacciones.to_dict('records')
    for trans in resultado:
        if isinstance(trans['fecha'], pd.Timestamp):
            trans['fecha'] = trans['fecha'].strftime('%Y-%m-%d')
    
    return {
        "success": True,
        "transacciones": resultado,
        "total": len(resultado),
        "filtros_aplicados": {
            "categoria": categoria,
            "tipo": tipo,
            "fecha_inicio": fecha_inicio,
            "fecha_fin": fecha_fin
        }
    }

if __name__ == "__main__":
    print("🚀 Iniciando servidor MCP Banorte...")
    print("📊 Servidor disponible en: http://localhost:8000")
    print("📖 Documentación API: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)