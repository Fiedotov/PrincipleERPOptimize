EXPLAIN
SELECT
    min(l.id) AS id,
    l.user_id,
    l.account_id,
    a.user_id AS manager_id,
    sum(l.unit_amount) AS quantity,
    sum(
        (
            l.unit_amount * (t.list_price) :: double precision
        )
    ) AS amount_invoice
FROM
    (
        SELECT
            id,
            user_id,
            account_id,
            unit_amount,
            to_invoice,
            invoice_id
        FROM
            account_analytic_line
        WHERE
            (to_invoice IS NOT NULL)
            AND (invoice_id IS NULL)
    ) l
    LEFT JOIN (
        SELECT
            id
        FROM
            hr_timesheet_invoice_factor
    ) f ON l.to_invoice = f.id
    LEFT JOIN (
        SELECT
            id,
            user_id
        FROM
            account_analytic_account
    ) a ON l.account_id = a.id
    LEFT JOIN (
        SELECT
            id
        FROM
            product_product
    ) p ON l.to_invoice = p.id
    LEFT JOIN (
        SELECT
            id,
            list_price
        FROM
            product_template
    ) t ON l.to_invoice = t.id
GROUP BY
    l.user_id,
    l.account_id,
    a.user_id