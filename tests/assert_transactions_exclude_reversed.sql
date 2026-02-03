-- Este test verifica que las transacciones revertidas (fraude, errores)
-- estén correctamente marcadas para excluirse de las métricas de rentabilidad

with transaction_metrics as (
    select
        transaction_id,
        amount,
        status,
        is_excluded_from_metrics,
        category
    from {{ ref('fct_transactions') }}
),

-- Transacciones revertidas que NO están marcadas para excluir
-- Esto causaría errores en los cálculos de ingresos/gastos
incorrectly_included as (
    select *
    from transaction_metrics
    where status = 'reversed'
      and is_excluded_from_metrics = false
)

-- Si devuelve filas, hay transacciones revertidas incluidas incorrectamente
select * from incorrectly_included
