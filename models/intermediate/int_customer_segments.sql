with customers as (
    select * from {{ ref('stg_customers') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

loans as (
    select * from {{ ref('stg_loans') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

-- Agregación de cuentas por cliente
customer_accounts as (
    select
        customer_id,
        count(distinct account_id) as num_accounts,
        count(distinct product_id) as num_products,
        sum(case when current_balance > 0 then current_balance else 0 end) as total_deposits,
        sum(case when current_balance < 0 then abs(current_balance) else 0 end) as total_credit_used
    from accounts
    group by customer_id
),

-- Agregación de préstamos por cliente
customer_loans as (
    select
        customer_id,
        count(distinct loan_id) as num_loans,
        sum(loan_amount) as total_loan_amount,
        sum(remaining_balance) as total_loan_outstanding
    from loans
    where status = 'active'
    group by customer_id
),

-- Actividad transaccional (últimos 12 meses simulado)
customer_activity as (
    select
        a.customer_id,
        count(distinct t.transaction_id) as num_transactions,
        sum(case when t.transaction_type = 'credit' then t.amount else 0 end) as total_inflows,
        sum(case when t.transaction_type = 'debit' then abs(t.amount) else 0 end) as total_outflows
    from accounts a
    left join transactions t on a.account_id = t.account_id
    where t.status = 'completed'
    group by a.customer_id
),

final as (
    select
        c.customer_id,
        c.customer_segment,
        coalesce(ca.num_accounts, 0) as num_accounts,
        coalesce(ca.num_products, 0) as num_products,
        coalesce(ca.total_deposits, 0) as total_deposits,
        coalesce(ca.total_credit_used, 0) as total_credit_used,
        coalesce(cl.num_loans, 0) as num_loans,
        coalesce(cl.total_loan_amount, 0) as total_loan_amount,
        coalesce(cl.total_loan_outstanding, 0) as total_loan_outstanding,
        coalesce(act.num_transactions, 0) as num_transactions,
        coalesce(act.total_inflows, 0) as total_inflows,
        coalesce(act.total_outflows, 0) as total_outflows,
        coalesce(ca.total_deposits, 0) - coalesce(cl.total_loan_outstanding, 0) as net_position,
        -- Clasificación de valor del cliente
        case
            when coalesce(ca.total_deposits, 0) >= 50000
                 or coalesce(cl.total_loan_amount, 0) >= 100000 then 'High'
            when coalesce(ca.total_deposits, 0) >= 10000
                 or coalesce(cl.total_loan_amount, 0) >= 20000 then 'Medium'
            else 'Low'
        end as segment_value
    from customers c
    left join customer_accounts ca on c.customer_id = ca.customer_id
    left join customer_loans cl on c.customer_id = cl.customer_id
    left join customer_activity act on c.customer_id = act.customer_id
)

select * from final
