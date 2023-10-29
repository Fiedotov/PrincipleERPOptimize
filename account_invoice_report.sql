EXPLAIN
SELECT
    sub.id,
    sub.date,
    sub.year,
    sub.month,
    sub.day,
    sub.product_id,
    sub.partner_id,
    sub.payment_term,
    sub.period_id,
    sub.uom_name,
    sub.currency_id,
    sub.journal_id,
    sub.fiscal_position,
    sub.user_id,
    sub.company_id,
    sub.nbr,
    sub.type,
    sub.state,
    sub.categ_id,
    sub.date_due,
    sub.account_id,
    sub.account_line_id,
    sub.partner_bank_id,
    sub.product_qty,
    (sub.price_total / cr.rate) AS price_total,
    (sub.price_average / cr.rate) AS price_average,
    cr.rate AS currency_rate,
    (sub.residual / cr.rate) AS residual,
    sub.commercial_partner_id,
    sub.section_id,
    sub.product_type,
    sub.shop_id
FROM
    (
        (
            SELECT
                min(ail.id) AS id,
                ai.date_invoice AS date,
                extract(
                    year
                    from
                        ai.date_invoice
                ) AS year,
                extract(
                    month
                    from
                        ai.date_invoice
                ) AS month,
                ai.date_invoice :: date AS day,
                ail.product_id,
                ai.partner_id,
                ai.payment_term,
                ai.period_id,
                COALESCE(
                    (
                        SELECT
                            name
                        FROM
                            product_uom
                        WHERE
                            uom_type = 'reference'
                            AND active
                            AND category_id = u.category_id
                        LIMIT
                            1
                    ), u.name
                ) AS uom_name,
                ai.currency_id,
                ai.journal_id,
                ai.fiscal_position,
                ai.user_id,
                ai.company_id,
                count(ail.id) AS nbr,
                ai.type,
                ai.state,
                pt.categ_id,
                ai.date_due,
                ai.account_id,
                ail.account_id AS account_line_id,
                ai.partner_bank_id,
                sum(
                    CASE
                        WHEN ai.type in ('out_refund', 'in_invoice') THEN - ail.quantity / u.factor
                        ELSE ail.quantity / u.factor
                    END
                ) AS product_qty,
                sum(
                    CASE
                        WHEN ai.type in ('out_refund', 'in_invoice') THEN - ail.price_subtotal
                        ELSE ail.price_subtotal
                    END
                ) AS price_total,
                sum(
                    CASE
                        WHEN ai.type in ('out_refund', 'in_invoice') THEN - ail.price_subtotal
                        ELSE ail.price_subtotal
                    END
                ) / NULLIF(sum(ail.quantity / u.factor), 0) AS price_average,
                ai.residual / NULLIF(
                    (
                        SELECT
                            count(1)
                        FROM
                            account_invoice_line l
                        WHERE
                            l.invoice_id = ai.id
                    ),
                    0
                ) AS residual,
                ai.commercial_partner_id,
                ai.section_id,
                pt.type AS product_type,
                ai.shop_id
            FROM
                (
                    SELECT
                        id,
                        uos_id,
                        product_id,
                        invoice_id,
                        account_id,
                        quantity,
                        price_subtotal
                    FROM
                        account_invoice_line
                ) ail
                JOIN (
                    SELECT
                        id,
                        date_invoice,
                        partner_id,
                        payment_term,
                        period_id,
                        currency_id,
                        journal_id,
                        fiscal_position,
                        user_id,
                        company_id,
                        type,
                        state,
                        date_due,
                        account_id,
                        partner_bank_id,
                        residual,
                        amount_total,
                        commercial_partner_id,
                        section_id,
                        shop_id
                    FROM
                        account_invoice
                ) ai ON ai.id = ail.invoice_id
                LEFT JOIN (
                    SELECT
                        id,
                        product_tmpl_id
                    FROM
                        product_product
                ) pr ON pr.id = ail.product_id
                LEFT JOIN (
                    SELECT
                        id,
                        type,
                        categ_id
                    FROM
                        product_template
                ) pt ON pt.id = pr.product_tmpl_id
                LEFT JOIN (
                    SELECT
                        id,
                        factor,
                        uom_type,
                        category_id,
                        name
                    FROM
                        product_uom
                ) u ON u.id = ail.uos_id
            GROUP BY
                ail.product_id,
                ai.date_invoice,
                ai.id,
                ai.partner_id,
                ai.payment_term,
                ai.period_id,
                u.name,
                ai.currency_id,
                ai.journal_id,
                ai.fiscal_position,
                ai.user_id,
                ai.company_id,
                ai.type,
                ai.state,
                pt.categ_id,
                ai.date_due,
                ai.account_id,
                ail.account_id,
                ai.partner_bank_id,
                ai.residual,
                ai.amount_total,
                u.uom_type,
                u.category_id,
                ai.commercial_partner_id,
                ai.section_id,
                pt.type,
                ai.shop_id
        ) sub
        JOIN (
            SELECT
                id,
                currency_id,
                rate
            FROM
                res_currency_rate
        ) cr ON ((cr.currency_id = sub.currency_id))
    )
WHERE
    (
        cr.id IN (
            SELECT
                cr2.id
            FROM
                res_currency_rate cr2
            WHERE
                (
                    (cr2.currency_id = sub.currency_id)
                    AND (
                        (
                            (sub.date IS NOT NULL)
                            AND (cr2.name <= sub.date)
                        )
                        OR (
                            (sub.date IS NULL)
                            AND (cr2.name <= now())
                        )
                    )
                )
            ORDER BY
                cr2.name DESC
            LIMIT
                1
        )
    )