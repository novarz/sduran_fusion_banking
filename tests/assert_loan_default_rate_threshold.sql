-- Este test verifica que la tasa de morosidad esté dentro de umbrales aceptables
-- Según estándares del Banco de España, una tasa superior al 5% requiere atención

with loan_performance as (
    select * from {{ ref('int_loan_performance') }}
),

-- Productos de préstamo con alta morosidad
high_default_products as (
    select
        product_id,
        product_name,
        loan_category,
        total_loans,
        defaulted_loans,
        default_rate,
        defaulted_amount
    from loan_performance
    where default_rate > 5.0  -- Umbral del 5%
      and total_loans >= 5    -- Mínimo de préstamos para ser significativo
)

-- Si devuelve filas, hay productos con morosidad preocupante
select * from high_default_products
