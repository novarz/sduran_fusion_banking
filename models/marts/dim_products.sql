with products as (
    select * from {{ ref('stg_products') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

loans as (
    select * from {{ ref('stg_loans') }}
),

-- Métricas de cuentas por producto
product_accounts as (
    select
        product_id,
        count(distinct account_id) as num_accounts,
        count(distinct customer_id) as num_customers,
        sum(case when current_balance > 0 then current_balance else 0 end) as total_deposits,
        sum(case when current_balance < 0 then abs(current_balance) else 0 end) as total_credit_used
    from accounts
    where status = 'active'
    group by product_id
),

-- Métricas de préstamos por producto
product_loans as (
    select
        product_id,
        count(distinct loan_id) as num_loans,
        sum(loan_amount) as total_amount_lent,
        sum(remaining_balance) as total_outstanding,
        sum(case when status = 'defaulted' then 1 else 0 end) as defaulted_loans
    from loans
    group by product_id
),

final as (
    select
        p.product_id,
        p.product_name,
        p.product_type,
        p.category,
        p.interest_rate,
        p.annual_fee,
        p.min_balance,
        p.is_active,
        p.launch_date,
        -- Métricas de cuentas
        coalesce(pa.num_accounts, 0) as num_accounts,
        coalesce(pa.num_customers, 0) as num_customers,
        coalesce(pa.total_deposits, 0) as total_deposits,
        coalesce(pa.total_credit_used, 0) as total_credit_used,
        -- Métricas de préstamos
        coalesce(pl.num_loans, 0) as num_loans,
        coalesce(pl.total_amount_lent, 0) as total_amount_lent,
        coalesce(pl.total_outstanding, 0) as total_outstanding,
        coalesce(pl.defaulted_loans, 0) as defaulted_loans
    from products p
    left join product_accounts pa on p.product_id = pa.product_id
    left join product_loans pl on p.product_id = pl.product_id
)

select * from final
