with branches as (
    select * from {{ ref('stg_branches') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

loans as (
    select * from {{ ref('stg_loans') }}
),

-- Métricas de cuentas por sucursal
branch_accounts as (
    select
        branch_id,
        count(distinct account_id) as num_accounts,
        count(distinct customer_id) as num_customers,
        sum(case when current_balance > 0 then current_balance else 0 end) as total_deposits,
        sum(case when current_balance < 0 then abs(current_balance) else 0 end) as total_credit_used
    from accounts
    where status = 'active'
    group by branch_id
),

-- Métricas de préstamos por sucursal
branch_loans as (
    select
        branch_id,
        count(distinct loan_id) as num_loans,
        sum(loan_amount) as total_amount_lent,
        sum(remaining_balance) as total_loans_outstanding,
        sum(case when status = 'defaulted' then remaining_balance else 0 end) as defaulted_amount
    from loans
    group by branch_id
),

final as (
    select
        b.branch_id,
        b.branch_name,
        b.branch_code,
        b.city,
        b.state,
        b.country,
        b.region,
        b.address,
        b.opened_date,
        b.branch_type,
        b.num_employees,
        -- Métricas de cuentas
        coalesce(ba.num_accounts, 0) as num_accounts,
        coalesce(ba.num_customers, 0) as total_customers,
        coalesce(ba.total_deposits, 0) as total_deposits,
        coalesce(ba.total_credit_used, 0) as total_credit_used,
        -- Métricas de préstamos
        coalesce(bl.num_loans, 0) as num_loans,
        coalesce(bl.total_amount_lent, 0) as total_amount_lent,
        coalesce(bl.total_loans_outstanding, 0) as total_loans_outstanding,
        coalesce(bl.defaulted_amount, 0) as defaulted_amount,
        -- KPIs calculados
        case
            when b.num_employees > 0
            then round(coalesce(ba.total_deposits, 0) / b.num_employees, 2)
            else 0
        end as deposits_per_employee,
        case
            when b.num_employees > 0
            then round(cast(coalesce(ba.num_customers, 0) as decimal) / b.num_employees, 2)
            else 0
        end as customers_per_employee
    from branches b
    left join branch_accounts ba on b.branch_id = ba.branch_id
    left join branch_loans bl on b.branch_id = bl.branch_id
)

select * from final
