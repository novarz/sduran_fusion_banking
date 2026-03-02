{% test no_default_classification(model, column_name, default_value='Sin clasificar') %}
-- Detecta registros que caen en el valor por defecto de un CASE statement.
-- Indica que hay categorías no gestionadas en la lógica de clasificación.
-- El fix es añadir la rama WHEN que falta en el CASE.

select
    *
from {{ model }}
where {{ column_name }} = '{{ default_value }}'

{% endtest %}
