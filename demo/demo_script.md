# Demo Script: De la alerta en el dashboard al fix en el código

**Duración estimada:** 10–15 minutos
**Audiencia:** Equipos técnicos y de negocio
**Objetivo:** Mostrar cómo dbt Fusion conecta el dato de negocio con la calidad del dato — desde el dashboard hasta el código fuente.

---

## Escenario

El equipo de Riesgos revisa el Informe de Cartera de Préstamos. Todo parece en orden, pero el **Health Tile de dbt** muestra una alerta activa. ¿Qué está fallando exactamente? ¿Qué modelos afecta? ¿Cómo se arregla?

---

## Paso 1 — El dashboard: todo parece normal

> *Abrir `demo/loan_portfolio_dashboard.html`*

Mostramos el dashboard de cartera de préstamos de Banco Fusión. El equipo de Riesgos lo usa para la revisión semanal de la cartera.

Puntos a destacar:
- KPIs en la cabecera: cartera total €4.82M, 28 préstamos activos, tasa de morosidad 8.57%
- Gráfico "Distribución por Nivel de Riesgo": 16 Bajo · 13 Medio · 3 Alto
- Los datos parecen coherentes

**Pero en la esquina superior derecha hay un tile diferente.** No es un KPI calculado por el frontend — es el **dbt Exposure Health Tile**, que muestra el estado de los tests de calidad del dato en tiempo real directamente desde dbt Cloud.

El tile muestra una **advertencia activa**.

---

## Paso 2 — El Health Tile: la alerta

> *Hacer clic en el Health Tile → abre dbt Cloud*

El Health Tile está conectado al exposure `loan_portfolio_report` en dbt Cloud. Al hacer clic vemos que hay **1 test en estado Warning**:

```
warn  no_default_classification_int_loan_enriched_risk_level__Sin_clasificar
```

Esto nos dice tres cosas de inmediato:
- **Test:** `no_default_classification` — detecta registros que caen en el `else` de un CASE
- **Modelo:** `int_loan_enriched`
- **Columna:** `risk_level`
- **Valor por defecto:** `'Sin clasificar'`

No es un error bloqueante, pero es una señal de que hay préstamos que el modelo no sabe clasificar.

---

## Paso 3 — El catálogo: entender el campo

> *Navegar a dbt Cloud → Explore → `fct_loans` → columna `risk_level`*

Abrimos el catálogo de datos. Buscamos el modelo `fct_loans`, que es el que alimenta el dashboard.

En la columna `risk_level` vemos la descripción:

> *"Clasificación de riesgo del préstamo según su estado. Valores esperados: Alto (defaulted), Medio (activo con baja amortización), Bajo (activo normal). **PROBLEMA CONOCIDO:** los préstamos con status 'completed' no están gestionados en el CASE y reciben el valor por defecto 'Sin clasificar'."*

El catálogo ya documenta el problema. Podemos ver también que el campo viene del modelo **`int_loan_enriched`** en la capa intermedia.

---

## Paso 4 — El linaje: trazando el origen

> *En dbt Cloud Explore → ver linaje de `fct_loans`*

El grafo de linaje muestra:

```
stg_loans ──┐
             ├──► int_loan_enriched ──► fct_loans ──► rpt_loan_risk_summary
stg_products─┘
```

El campo `risk_level` se calcula en `int_loan_enriched` y se propaga hacia arriba. El dashboard consume `fct_loans`. Si hay préstamos `completed` sin clasificar en el origen, llegan hasta el dashboard sin que nadie lo detecte... salvo el test.

---

## Paso 5 — El código: encontrar el bug

> *Abrir `models/intermediate/int_loan_enriched.sql`, líneas 51–57*

```sql
-- BUG: no gestiona el status 'completed' → cae al default 'Sin clasificar'
case
    when l.status = 'defaulted' then 'Alto'
    when l.status = 'active' and l.remaining_balance > l.loan_amount * 0.9
         and date_part('year', current_date) - date_part('year', l.start_date) > 1 then 'Medio'
    when l.status = 'active' then 'Bajo'
    else 'Sin clasificar'   -- ← aquí caen los préstamos 'completed'
end as risk_level
```

El CASE cubre `defaulted` y `active`, pero los préstamos con `status = 'completed'` caen en el `else`. Son **3 préstamos** que el modelo no clasifica.

---

## Paso 6 — El fix: añadir la rama que falta

> *Editar `int_loan_enriched.sql`*

Añadimos la rama `completed` antes del `else`:

```sql
case
    when l.status = 'defaulted' then 'Alto'
    when l.status = 'active' and l.remaining_balance > l.loan_amount * 0.9
         and date_part('year', current_date) - date_part('year', l.start_date) > 1 then 'Medio'
    when l.status = 'active' then 'Bajo'
    when l.status = 'completed' then 'Bajo'   -- ← fix: préstamos finalizados = riesgo bajo
    else 'Sin clasificar'
end as risk_level
```

---

## Paso 7 — Validar el fix

> *Ejecutar en terminal*

```bash
dbt build --select int_loan_enriched+
```

Resultado esperado:
- `int_loan_enriched` ✅ éxito
- `fct_loans` ✅ éxito
- `no_default_classification_int_loan_enriched_risk_level` ✅ **0 rows** — warning desaparece

El Health Tile vuelve a verde. El dashboard ahora refleja los 35 préstamos correctamente clasificados.

---

## Resumen del flujo

```
Dashboard (Health Tile ⚠)
    → dbt Cloud: test warning en int_loan_enriched.risk_level
        → Catálogo: descripción documenta el problema conocido
            → Linaje: origen trazado a int_loan_enriched
                → Código: CASE sin rama 'completed'
                    → Fix: añadir WHEN + rebuild
                        → Health Tile ✅
```

---

## Mensajes clave para la audiencia

- **Para negocio:** "El dashboard os muestra el dato. El Health Tile os avisa cuando ese dato tiene un problema de calidad — sin esperar a que alguien lo detecte manualmente."
- **Para técnicos:** "El catálogo documenta los campos calculados, sus reglas de negocio y los problemas conocidos. El linaje traza el origen en segundos. Los tests son la red de seguridad."
- **Para todos:** "dbt no es solo transformación de datos — es el contrato entre el dato y el negocio."
