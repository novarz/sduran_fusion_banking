// Configuración de ejemplo para los dashboards de demo
// Copiar este archivo como config.js y configurar con tus credenciales

const CONFIG = {
    // Configuración de dbt Cloud
    dbt_cloud: {
        host: 'cloud.getdbt.com',
        account_id: 'YOUR_ACCOUNT_ID',
        project_id: 'YOUR_PROJECT_ID',
        environment_id: 'YOUR_ENVIRONMENT_ID',
        service_token: 'YOUR_SERVICE_TOKEN'
    },

    // Configuración del Semantic Layer
    semantic_layer: {
        host: 'semantic-layer.cloud.getdbt.com',
        environment_id: 'YOUR_ENVIRONMENT_ID'
    },

    // Configuración del dashboard
    dashboard: {
        refresh_interval: 300000, // 5 minutos
        default_date_range: 'last_12_months',
        currency: 'EUR',
        locale: 'es-ES'
    },

    // Métricas principales para banca
    metrics: {
        customer_analytics: [
            'total_customers',
            'active_customers',
            'customer_lifetime_value',
            'average_balance_per_customer'
        ],
        loan_portfolio: [
            'total_loans_outstanding',
            'default_rate',
            'average_loan_amount',
            'interest_income'
        ],
        branch_performance: [
            'deposits_per_branch',
            'customers_per_branch',
            'transactions_per_branch'
        ]
    }
};

// No modificar - exportación para Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
