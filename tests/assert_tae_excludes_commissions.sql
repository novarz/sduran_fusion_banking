-- Este test valida que el cálculo de TAE sea realista
-- Según normativa del Banco de España, la TAE debe incluir TODAS las comisiones
-- Un TAE muy cercano al TIN (tipo de interés nominal) indica que probablemente
-- no se están incluyendo las comisiones de apertura, seguros vinculados, etc.

-- En España, la diferencia típica entre TIN y TAE es de al menos 0.3-0.5 puntos
-- porcentuales debido a las comisiones obligatorias

with loans as (
    select
        loan_id,
        product_name,
        loan_amount,
        interest_rate as tin,
        tae,
        -- La TAE debería ser mayor que el TIN por las comisiones
        tae - interest_rate as tae_tin_difference
    from {{ ref('int_loan_enriched') }}
    where status = 'active'
      and loan_amount > 10000  -- Solo préstamos significativos
),

-- Préstamos donde TAE está sospechosamente cerca del TIN
-- Esto indica que no se están incluyendo comisiones en el cálculo
suspicious_tae as (
    select *
    from loans
    where tae_tin_difference < 0.25  -- Diferencia menor a 0.25 puntos
)

-- Si devuelve filas, el cálculo de TAE probablemente no incluye comisiones
select * from suspicious_tae
