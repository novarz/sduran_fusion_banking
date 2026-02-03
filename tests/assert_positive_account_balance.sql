-- Este test verifica que las cuentas de ahorro y depósito tengan saldo positivo
-- Las tarjetas de crédito pueden tener saldo negativo (deuda)

with accounts_with_products as (
    select
        a.account_id,
        a.current_balance,
        p.product_type,
        p.product_name
    from {{ ref('stg_accounts') }} a
    join {{ ref('stg_products') }} p on a.product_id = p.product_id
    where a.status = 'active'
),

-- Cuentas de ahorro/depósito con saldo negativo (no debería ocurrir)
invalid_balances as (
    select
        account_id,
        current_balance,
        product_type,
        product_name
    from accounts_with_products
    where product_type = 'Account'
      and current_balance < 0
)

-- Si devuelve filas, hay cuentas de ahorro con saldo negativo
select * from invalid_balances
