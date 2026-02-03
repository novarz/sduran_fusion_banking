with customers as (
    select * from {{ ref('stg_customers') }}
),

customer_segments as (
    select * from {{ ref('int_customer_segments') }}
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.first_name || ' ' || c.last_name as full_name,
        c.dni,
        c.email,
        c.phone,
        c.gender,
        c.birth_date,
        -- Calcular edad
        date_part('year', current_date) - date_part('year', c.birth_date) as age,
        c.city,
        c.state,
        c.country,
        c.customer_since,
        c.customer_segment,
        -- Métricas de segmentación
        cs.num_accounts,
        cs.num_products,
        cs.total_deposits,
        cs.total_credit_used,
        cs.num_loans,
        cs.total_loan_amount,
        cs.total_loan_outstanding,
        cs.num_transactions,
        cs.total_inflows,
        cs.total_outflows,
        cs.net_position,
        cs.segment_value as customer_value,
        -- Antigüedad como cliente
        date_part('year', current_date) - date_part('year', c.customer_since) as years_as_customer
    from customers c
    left join customer_segments cs on c.customer_id = cs.customer_id
)

select * from final
