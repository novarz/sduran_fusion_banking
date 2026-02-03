with loans as (
    select * from {{ ref('stg_loans') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

-- Métricas por producto de préstamo
loan_metrics as (
    select
        l.product_id,
        p.product_name,
        p.category as loan_category,
        count(l.loan_id) as total_loans,
        sum(l.loan_amount) as total_amount_lent,
        sum(l.remaining_balance) as total_outstanding,
        sum(case when l.status = 'active' then 1 else 0 end) as active_loans,
        sum(case when l.status = 'completed' then 1 else 0 end) as completed_loans,
        sum(case when l.status = 'defaulted' then 1 else 0 end) as defaulted_loans,
        sum(case when l.status = 'defaulted' then l.remaining_balance else 0 end) as defaulted_amount,
        avg(l.interest_rate) as avg_interest_rate,
        avg(l.term_months) as avg_term_months,
        sum(l.monthly_payment * l.term_months) - sum(l.loan_amount) as estimated_total_interest
    from loans l
    join products p on l.product_id = p.product_id
    group by
        l.product_id,
        p.product_name,
        p.category
),

final as (
    select
        product_id,
        product_name,
        loan_category,
        total_loans,
        total_amount_lent,
        total_outstanding,
        active_loans,
        completed_loans,
        defaulted_loans,
        defaulted_amount,
        -- Tasa de morosidad (préstamos en default / total préstamos)
        case
            when total_loans > 0
            then round(cast(defaulted_loans as decimal) / total_loans * 100, 2)
            else 0
        end as default_rate,
        -- Ratio de morosidad por importe
        case
            when total_amount_lent > 0
            then round(cast(defaulted_amount as decimal) / total_amount_lent * 100, 2)
            else 0
        end as default_amount_rate,
        avg_interest_rate,
        avg_term_months,
        estimated_total_interest as interest_income
    from loan_metrics
)

select * from final
