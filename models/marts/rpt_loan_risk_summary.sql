with loans as (
    select * from {{ ref('fct_loans') }}
),

final as (
    select
        product_name,
        loan_category,
        region,
        count(*) as total_loans,
        sum(loan_amount) as total_loan_amount,
        round(avg(tae), 2) as avg_tae,
        round(avg(interest_rate), 2) as avg_interest_rate,
        round(avg(tae) - avg(interest_rate), 2) as tae_tin_spread,
        count(case when risk_level = 'Alto' then 1 end) as high_risk_loans,
        count(case when status = 'defaulted' then 1 end) as defaulted_loans,
        round(
            count(case when status = 'defaulted' then 1 end)::numeric
            / nullif(count(*), 0) * 100,
            2
        ) as default_rate
    from loans
    group by product_name, loan_category, region
)

select * from final
