with loans as (
    select * from {{ ref('stg_loans') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

final as (
    select
        l.loan_id,
        l.customer_id,
        l.product_id,
        l.branch_id,
        l.loan_amount,
        l.interest_rate,
        l.term_months,
        l.monthly_payment,
        l.start_date,
        l.end_date,
        l.status,
        l.remaining_balance,
        -- Información del producto
        p.product_name,
        p.category as loan_category,
        p.annual_fee,
        -- Cálculos financieros
        l.monthly_payment * l.term_months as total_to_pay,
        (l.monthly_payment * l.term_months) - l.loan_amount as total_interest_paid,
        -- TAE (Tasa Anual Equivalente) - cálculo simplificado
        -- La TAE real incluiría comisiones de apertura, seguros, etc.
        -- Este es un cálculo aproximado para demo
        round(
            (power(1 + (l.interest_rate / 100 / 12), 12) - 1) * 100,
            2
        ) as tae,
        -- Ratio de amortización
        case
            when l.loan_amount > 0
            then round((1 - (l.remaining_balance / l.loan_amount)) * 100, 2)
            else 0
        end as amortization_percentage,
        -- Meses restantes estimados
        case
            when l.monthly_payment > 0
            then ceil(l.remaining_balance / l.monthly_payment)
            else 0
        end as estimated_months_remaining,
        -- Clasificación de riesgo según estado del préstamo
        case
            when l.status = 'defaulted' then 'Alto'
            when l.status = 'active' and l.remaining_balance > l.loan_amount * 0.9
                 and date_part('year', current_date) - date_part('year', l.start_date) > 1 then 'Medio'
            when l.status = 'active' then 'Bajo'
            when l.status = 'completed' then 'Bajo'
            else 'Sin clasificar'
        end as risk_level
    from loans l
    join products p on l.product_id = p.product_id
)

select * from final
