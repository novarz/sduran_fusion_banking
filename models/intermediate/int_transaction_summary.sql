with transactions as (
    select * from {{ ref('stg_transactions') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

-- Resumen por cuenta y categoría
account_category_summary as (
    select
        t.account_id,
        t.category,
        count(t.transaction_id) as num_transactions,
        sum(case when t.transaction_type = 'credit' then t.amount else 0 end) as total_credits,
        sum(case when t.transaction_type = 'debit' then abs(t.amount) else 0 end) as total_debits,
        sum(case when t.status = 'reversed' then 1 else 0 end) as reversed_transactions,
        min(t.transaction_date) as first_transaction_date,
        max(t.transaction_date) as last_transaction_date
    from transactions t
    group by
        t.account_id,
        t.category
),

-- Añadir información de la cuenta
final as (
    select
        acs.account_id,
        a.customer_id,
        acs.category,
        acs.num_transactions,
        acs.total_credits,
        acs.total_debits,
        acs.total_credits - acs.total_debits as net_amount,
        acs.reversed_transactions,
        acs.first_transaction_date,
        acs.last_transaction_date
    from account_category_summary acs
    join accounts a on acs.account_id = a.account_id
)

select * from final
