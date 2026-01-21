{% macro generate_surrogate_key(columns) %}
    md5(
        {% for col in columns %}
            coalesce(cast({{ col }} as varchar), '')
            {% if not loop.last %} || '|' || {% endif %}
        {% endfor %}
    )
{% endmacro %}
