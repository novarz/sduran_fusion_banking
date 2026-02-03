-- Este test verifica la coherencia entre el segmento del cliente y su edad
-- - Clientes 'Young' deben tener menos de 30 años
-- - Clientes 'Senior' deben tener más de 60 años

with customers as (
    select
        customer_id,
        first_name,
        last_name,
        age,
        customer_segment
    from {{ ref('dim_customers') }}
),

-- Clientes mal segmentados
invalid_segments as (
    select
        customer_id,
        first_name,
        last_name,
        age,
        customer_segment,
        case
            when customer_segment = 'Young' and age >= 30
                then 'Young pero edad >= 30'
            when customer_segment = 'Senior' and age < 60
                then 'Senior pero edad < 60'
        end as issue
    from customers
    where
        (customer_segment = 'Young' and age >= 30)
        or (customer_segment = 'Senior' and age < 60)
)

-- Si devuelve filas, hay inconsistencias en la segmentación
select * from invalid_segments
