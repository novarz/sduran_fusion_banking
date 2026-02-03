with source as (
    select * from {{ source('raw_data', 'raw_customers') }}
),

renamed as (
    select
        id as customer_id,
        first_name,
        last_name,
        dni,
        email,
        phone,
        gender,
        birth_date,
        city,
        state,
        country,
        customer_since,
        customer_segment
    from source
)

select * from renamed
