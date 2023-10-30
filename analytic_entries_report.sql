SELECT
        min(a.id) AS id,
        count(DISTINCT a.id) AS nbr,
        a.date,
        to_char((a.date)::timestamp with time zone,
        'YYYY'::text) AS year,
        to_char((a.date)::timestamp with time zone,
        'MM'::text) AS month,
        to_char((a.date)::timestamp with time zone,
        'YYYY-MM-DD'::text) AS day,
        a.user_id,
        a.name,
        analytic.partner_id,
        a.company_id,
        a.currency_id,
        a.account_id,
        a.general_account_id,
        a.journal_id,
        a.move_id,
        a.product_id,
        a.product_uom_id,
        sum(a.amount) AS amount,
        sum(a.unit_amount) AS unit_amount 
    FROM
        (SELECT
            id,
            account_analytic_line.date,
            account_analytic_line.user_id,
            account_analytic_line.name,
            amount,
            unit_amount,
            account_analytic_line.company_id,
            account_analytic_line.currency_id,
            account_analytic_line.account_id,
            account_analytic_line.general_account_id,
            account_analytic_line.journal_id,
            account_analytic_line.move_id,
            account_analytic_line.product_id,
            account_analytic_line.product_uom_id 
        FROM
            account_analytic_line) a,
        (SELECT
            id,
            account_analytic_account.partner_id 
        FROM
            account_analytic_account) analytic 
    WHERE
        (
            analytic.id = a.account_id
        ) 
    GROUP BY
        a.date,
        a.user_id,
        a.name,
        analytic.partner_id,
        a.company_id,
        a.currency_id,
        a.account_id,
        a.general_account_id,
        a.journal_id,
        a.move_id,
        a.product_id,
        a.product_uom_id