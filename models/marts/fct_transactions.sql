with transactions as (
    select * from {{ ref('stg_transactions') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

branches as (
    select * from {{ ref('stg_branches') }}
),

final as (
    select
        t.transaction_id,
        t.account_id,
        a.customer_id,
        a.product_id,
        a.branch_id,
        t.transaction_date,
        date_trunc('month', t.transaction_date) as transaction_month,
        date_trunc('year', t.transaction_date) as transaction_year,
        t.transaction_type,
        t.category,
        t.amount,
        t.description,
        t.channel,
        t.status,
        -- Información del producto
        p.product_name,
        p.product_type,
        -- Información de la sucursal
        b.branch_name,
        b.region,
        -- Comisiones estimadas (ejemplo simplificado)
        -- En España, las comisiones bancarias están reguladas
        case
            when t.channel = 'ATM' and t.transaction_type = 'debit' then 0.50  -- Comisión cajero
            when t.channel = 'POS' and abs(t.amount) > 100 then 0.00  -- Sin comisión > 100€
            when t.channel = 'Transfer' and abs(t.amount) > 50000 then 15.00  -- Transferencia grande
            else 0.00
        end as commission_amount,
        -- Flag para transacciones excluidas de métricas
        case
            when t.status = 'reversed' then true
            else false
        end as is_excluded_from_metrics
    from transactions t
    join accounts a on t.account_id = a.account_id
    join products p on a.product_id = p.product_id
    join branches b on a.branch_id = b.branch_id
)

select * from final
