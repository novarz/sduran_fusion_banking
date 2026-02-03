with source as (
    select * from {{ source('raw_data', 'raw_products') }}
),

renamed as (
    select
        id as product_id,
        product_name,
        product_type,
        category,
        interest_rate,
        annual_fee,
        min_balance,
        is_active,
        launch_date
    from source
)

select * from renamed
