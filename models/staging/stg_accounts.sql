with source as (
    select * from {{ source('raw_data', 'raw_accounts') }}
),

renamed as (
    select
        id as account_id,
        customer_id,
        product_id,
        branch_id,
        account_number,
        iban,
        opened_date,
        status,
        current_balance
    from source
)

select * from renamed
