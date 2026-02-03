# Banco Fusión - Proyecto dbt de Banca Retail

Proyecto de demostración de dbt para un banco minorista ficticio en España. Incluye modelos de datos, tests, exposures y dashboards de ejemplo.

## 🏦 Descripción

Este proyecto simula el data warehouse de un banco retail con:
- **100 clientes** distribuidos por toda España
- **25 sucursales** bancarias
- **30 productos** bancarios (cuentas, tarjetas, préstamos, inversiones)
- **110 cuentas** activas
- **268 transacciones** de ejemplo
- **35 préstamos** (hipotecas, personales, auto, estudios)

## 📁 Estructura del Proyecto

```
sduran_fusion_banking/
├── models/
│   ├── staging/          # Capa de staging - limpieza de datos
│   │   ├── stg_customers.sql
│   │   ├── stg_accounts.sql
│   │   ├── stg_transactions.sql
│   │   ├── stg_loans.sql
│   │   ├── stg_branches.sql
│   │   └── stg_products.sql
│   ├── intermediate/     # Capa intermedia - lógica de negocio
│   │   ├── int_customer_segments.sql
│   │   ├── int_monthly_balances.sql
│   │   ├── int_transaction_summary.sql
│   │   └── int_loan_performance.sql
│   └── marts/            # Capa de marts - modelos finales
│       ├── dim_customers.sql
│       ├── dim_products.sql
│       ├── dim_branches.sql
│       ├── fct_transactions.sql
│       └── fct_loans.sql
├── seeds/                # Datos de ejemplo
│   ├── raw_customers.csv
│   ├── raw_accounts.csv
│   ├── raw_transactions.csv
│   ├── raw_loans.csv
│   ├── raw_branches.csv
│   └── raw_products.csv
├── tests/                # Tests de calidad de datos
│   ├── assert_positive_account_balance.sql
│   ├── assert_tae_excludes_commissions.sql
│   ├── assert_transactions_exclude_reversed.sql
│   ├── assert_loan_default_rate_threshold.sql
│   └── assert_valid_customer_segment.sql
├── demo/                 # Dashboards de demostración
│   ├── customer_analytics_dashboard.html
│   ├── loan_portfolio_dashboard.html
│   └── config.example.js
└── dbt_project.yml
```

## 🎯 Casos de Uso de Demo

### 1. Segmentación de Clientes
- Análisis de valor de cliente (CLV)
- Distribución geográfica
- Métricas por segmento (Premium, Standard, Young, Senior)

### 2. Cartera de Préstamos
- Análisis de morosidad por producto
- Cumplimiento normativo (Banco de España)
- Gestión de riesgo crediticio

### 3. Rendimiento de Sucursales
- KPIs por oficina
- Depósitos por empleado
- Captación de clientes

## ⚠️ Test de Demo: Warning de TAE

El proyecto incluye un test (`assert_tae_excludes_commissions.sql`) que genera un **warning** intencionalmente. Este test detecta que el cálculo de TAE no incluye las comisiones de apertura, lo cual incumple la normativa del Banco de España.

### Para solucionar el warning:

1. Modificar `models/marts/fct_loans.sql`
2. Actualizar el cálculo de TAE para incluir comisiones:

```sql
-- Antes (incorrecto)
round(
    (power(1 + (l.interest_rate / 100 / 12), 12) - 1) * 100,
    2
) as tae,

-- Después (correcto - incluye comisión de apertura del 1%)
round(
    (power(1 + ((l.interest_rate + 1.0) / 100 / 12), 12) - 1) * 100,
    2
) as tae,
```

## 🚀 Inicio Rápido

```bash
# Instalar dependencias
dbt deps

# Cargar los seeds
dbt seed

# Ejecutar los modelos
dbt run

# Ejecutar los tests
dbt test

# Generar documentación
dbt docs generate
dbt docs serve
```

## 📊 Exposures

El proyecto define tres exposures en `models/marts/_marts_models.yml`:

| Dashboard | Descripción | Modelos |
|-----------|-------------|---------|
| customer_analytics_dashboard | Análisis de clientes y segmentación | dim_customers, fct_transactions |
| loan_portfolio_report | Cartera de préstamos y morosidad | fct_loans, dim_customers, dim_products |
| branch_performance_report | Rendimiento de sucursales | dim_branches, fct_transactions |

## 🇪🇸 Localización España

- Nombres y apellidos españoles
- DNI/NIE válidos (formato)
- Ciudades y comunidades autónomas reales
- Productos bancarios típicos del mercado español
- Normativa del Banco de España (umbrales de morosidad, TAE)
- IVA y comisiones según regulación española

## 🛠️ Requisitos

- dbt Core 1.5+ o dbt Cloud
- Adaptador de base de datos compatible (Snowflake, BigQuery, Redshift, Postgres, etc.)

## 📝 Licencia

Proyecto de demostración - Uso interno.

---

Desarrollado con ❤️ usando [dbt](https://www.getdbt.com/)
