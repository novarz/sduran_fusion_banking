with accounts as (
    select * from {{ ref('stg_accounts') }}
),

branches as (
    select * from {{ ref('stg_branches') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

-- Generar serie de meses a partir de las transacciones
monthly_transactions as (
    select
        a.account_id,
        a.branch_id,
        p.product_type,
        date_trunc('month', t.transaction_date) as month_date,
        sum(t.amount) as monthly_movement
    from transactions t
    join accounts a on t.account_id = a.account_id
    join products p on a.product_id = p.product_id
    where t.status = 'completed'
    group by
        a.account_id,
        a.branch_id,
        p.product_type,
        date_trunc('month', t.transaction_date)
),

-- Agregación por sucursal, tipo de producto y mes
final as (
    select
        month_date,
        branch_id,
        product_type,
        count(distinct account_id) as num_accounts,
        sum(monthly_movement) as total_monthly_movement,
        sum(case when monthly_movement > 0 then monthly_movement else 0 end) as total_credits,
        sum(case when monthly_movement < 0 then abs(monthly_movement) else 0 end) as total_debits
    from monthly_transactions
    group by
        month_date,
        branch_id,
        product_type
)

select * from final
