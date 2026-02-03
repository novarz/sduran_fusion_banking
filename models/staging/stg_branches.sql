with source as (
    select * from {{ source('raw_data', 'raw_branches') }}
),

renamed as (
    select
        id as branch_id,
        branch_name,
        branch_code,
        city,
        state,
        country,
        region,
        address,
        opened_date,
        branch_type,
        num_employees
    from source
)

select * from renamed
