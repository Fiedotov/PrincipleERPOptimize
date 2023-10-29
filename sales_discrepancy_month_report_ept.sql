SELECT
    max(sales.id) AS id,
    sales.sale_id,
    sales.product_id,
    sales.partner_id,
    sales.shop_id,
    sales.user_id,
    (
        max(sales.delivery_month) - max(sales.invoice_month)
    ) AS discrepancy,
    sum(sales.delivery_amount_01) AS delivery_amount_01,
    sum(sales.delivery_amount_02) AS delivery_amount_02,
    sum(sales.delivery_amount_03) AS delivery_amount_03,
    sum(sales.delivery_amount_04) AS delivery_amount_04,
    sum(sales.delivery_amount_05) AS delivery_amount_05,
    sum(sales.delivery_amount_06) AS delivery_amount_06,
    sum(sales.delivery_amount_07) AS delivery_amount_07,
    sum(sales.delivery_amount_08) AS delivery_amount_08,
    sum(sales.delivery_amount_09) AS delivery_amount_09,
    sum(sales.delivery_amount_10) AS delivery_amount_10,
    sum(sales.delivery_amount_11) AS delivery_amount_11,
    sum(sales.delivery_amount_12) AS delivery_amount_12,
    sum(sales.invoice_amount_01) AS invoice_amount_01,
    sum(sales.invoice_amount_02) AS invoice_amount_02,
    sum(sales.invoice_amount_03) AS invoice_amount_03,
    sum(sales.invoice_amount_04) AS invoice_amount_04,
    sum(sales.invoice_amount_05) AS invoice_amount_05,
    sum(sales.invoice_amount_06) AS invoice_amount_06,
    sum(sales.invoice_amount_07) AS invoice_amount_07,
    sum(sales.invoice_amount_08) AS invoice_amount_08,
    sum(sales.invoice_amount_09) AS invoice_amount_09,
    sum(sales.invoice_amount_10) AS invoice_amount_10,
    sum(sales.invoice_amount_11) AS invoice_amount_11,
    sum(sales.invoice_amount_12) AS invoice_amount_12
FROM
    (
        (
            SELECT
                (- min(sol.id)) AS id,
                so.id AS sale_id,
                pp.id AS product_id,
                so.partner_id,
                so.shop_id,
                so.user_id,
                0 AS delivery_month,
                0 AS delivery_amount_01,
                0 AS delivery_amount_02,
                0 AS delivery_amount_03,
                0 AS delivery_amount_04,
                0 AS delivery_amount_05,
                0 AS delivery_amount_06,
                0 AS delivery_amount_07,
                0 AS delivery_amount_08,
                0 AS delivery_amount_09,
                0 AS delivery_amount_10,
                0 AS delivery_amount_11,
                0 AS delivery_amount_12,
                avg(date_part('month' :: text, ai.date_invoice)) AS invoice_month,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (1) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_01,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (2) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_02,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (3) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_03,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (4) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_04,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (5) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_05,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (6) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_06,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (7) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_07,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (8) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_08,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (9) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_09,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (10) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_10,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (11) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_11,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, ai.date_invoice) = (12) :: double precision
                        ) THEN ail.price_subtotal
                        ELSE (0) :: numeric
                    END
                ) AS invoice_amount_12
            FROM
                (
                    (
                        (
                            (
                                (
                                    (
                                        sale_order_line sol
                                        LEFT JOIN sale_order so ON ((so.id = sol.order_id))
                                    )
                                    LEFT JOIN product_product pp ON ((pp.id = sol.product_id))
                                )
                                LEFT JOIN sale_order_invoice_rel soir ON ((soir.order_id = so.id))
                            )
                            LEFT JOIN account_invoice ai ON (
                                (
                                    (ai.id = soir.invoice_id)
                                    AND ((ai.state) :: text <> 'cancel' :: text)
                                    AND ((ai.type) :: text = 'out_invoice' :: text)
                                )
                            )
                        )
                        LEFT JOIN sale_order_line_invoice_rel solir ON ((solir.order_line_id = sol.id))
                    )
                    LEFT JOIN account_invoice_line ail ON (
                        (
                            (ail.id = solir.invoice_id)
                            AND (ail.invoice_id = ai.id)
                        )
                    )
                )
            WHERE
                (ail.id IS NOT NULL)
            GROUP BY
                so.id,
                pp.id,
                so.partner_id,
                so.shop_id,
                so.user_id
            ORDER BY
                (- min(sol.id))
        )
        UNION
        ALL (
            SELECT
                min(sol.id) AS id,
                so.id AS sale_id,
                pp.id AS product_id,
                so.partner_id,
                so.shop_id,
                so.user_id,
                avg(date_part('month' :: text, sp.date_done)) AS delivery_month,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (1) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_01,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (2) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_02,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (3) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_03,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (4) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_04,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (5) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_05,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (6) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_06,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (7) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_07,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (8) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_08,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (9) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_09,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (10) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_10,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (11) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_11,
                sum(
                    CASE
                        WHEN (
                            date_part('month' :: text, sp.date_done) = (12) :: double precision
                        ) THEN (aml.debit - aml.credit)
                        ELSE (0) :: numeric
                    END
                ) AS delivery_amount_12,
                0 AS invoice_month,
                0 AS invoice_amount_01,
                0 AS invoice_amount_02,
                0 AS invoice_amount_03,
                0 AS invoice_amount_04,
                0 AS invoice_amount_05,
                0 AS invoice_amount_06,
                0 AS invoice_amount_07,
                0 AS invoice_amount_08,
                0 AS invoice_amount_09,
                0 AS invoice_amount_10,
                0 AS invoice_amount_11,
                0 AS invoice_amount_12
            FROM
                (
                    (
                        (
                            (
                                (
                                    (
                                        sale_order_line sol
                                        LEFT JOIN sale_order so ON ((so.id = sol.order_id))
                                    )
                                    LEFT JOIN product_product pp ON ((pp.id = sol.product_id))
                                )
                                LEFT JOIN stock_move sm ON (
                                    (
                                        (sm.sale_line_id = sol.id)
                                        AND ((sm.state) :: text <> 'cancel' :: text)
                                    )
                                )
                            )
                            LEFT JOIN stock_picking sp ON ((sp.id = sm.picking_id))
                        )
                        LEFT JOIN account_move_line aml ON (
                            (
                                ((aml.ref) :: text = (sp.name) :: text)
                                AND (
                                    (aml.name) :: text = substr((sm.name) :: text, 1, 64)
                                )
                                AND (aml.product_id = sm.product_id)
                                AND (aml.quantity = sm.product_qty)
                                AND (
                                    aml.account_id = ANY (
                                        ARRAY [273, 275, 276, 277, 278, 280, 531, 533, 536, 539, 541, 544, 547, 550, 553, 556, 559, 562, 565, 568, 571, 574, 577, 580, 583, 586, 589, 592, 595, 597, 600, 603, 606, 609, 612]
                                    )
                                )
                            )
                        )
                    )
                    LEFT JOIN account_move am ON ((am.id = aml.move_id))
                )
            WHERE
                ((sp.state) :: text = 'done' :: text)
            GROUP BY
                so.id,
                pp.id,
                so.partner_id,
                so.shop_id,
                so.user_id
            ORDER BY
                (min(sol.id))
        )
    ) sales
GROUP BY
    sales.sale_id,
    sales.product_id,
    sales.partner_id,
    sales.shop_id,
    sales.user_id