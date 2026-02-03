with source as (
    select * from {{ source('raw_data', 'raw_transactions') }}
),

renamed as (
    select
        id as transaction_id,
        account_id,
        transaction_date,
        transaction_type,
        category,
        amount,
        description,
        channel,
        status
    from source
)

select * from renamed
