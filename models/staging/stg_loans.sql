with source as (
    select * from {{ source('raw_data', 'raw_loans') }}
),

renamed as (
    select
        id as loan_id,
        customer_id,
        product_id,
        branch_id,
        loan_amount,
        interest_rate,
        term_months,
        monthly_payment,
        start_date,
        end_date,
        status,
        remaining_balance
    from source
)

select * from renamed
