with loan_enriched as (
    select * from {{ ref('int_loan_enriched') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

branches as (
    select * from {{ ref('stg_branches') }}
),

final as (
    select
        le.loan_id,
        le.customer_id,
        le.product_id,
        le.branch_id,
        le.loan_amount,
        le.interest_rate,
        le.term_months,
        le.monthly_payment,
        le.start_date,
        le.end_date,
        le.status,
        le.remaining_balance,
        c.first_name || ' ' || c.last_name as customer_name,
        c.customer_segment,
        le.product_name,
        le.loan_category,
        b.branch_name,
        b.region,

        le.total_to_pay,
        le.total_interest_paid,
        le.tae,
        le.amortization_percentage,
        le.estimated_months_remaining,
        le.risk_level,
        -- Flag de concentración alta: true si la región supera el 20% del portfolio total
        sum(le.loan_amount) over (partition by b.region)
            / nullif(sum(le.loan_amount) over (), 0) > 0.20
            as is_high_concentration
    from loan_enriched le
    join customers c on le.customer_id = c.customer_id
    join branches b on le.branch_id = b.branch_id
)

select * from final
