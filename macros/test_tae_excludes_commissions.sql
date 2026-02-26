{% test tae_excludes_commissions(model, column_name) %}
-- Valida que el cálculo de TAE sea realista según normativa del Banco de España.
-- La TAE debe incluir TODAS las comisiones (apertura, seguros vinculados, etc.)
-- Un TAE muy cercano al TIN indica que las comisiones no se están incluyendo.
-- Diferencia típica TIN-TAE >= 0.25 pp en préstamos con comisiones.

with loans as (
    select
        loan_id,
        product_name,
        loan_amount,
        interest_rate as tin,
        {{ column_name }} as tae,
        {{ column_name }} - interest_rate as tae_tin_difference
    from {{ model }}
    where status = 'active'
      and loan_amount > 10000
),

suspicious_tae as (
    select *
    from loans
    where tae_tin_difference < 0.25
)

select * from suspicious_tae

{% endtest %}
