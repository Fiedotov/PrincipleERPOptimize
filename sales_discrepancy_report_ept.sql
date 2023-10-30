SELECT
    DISTINCT ON ((min(sol.id))) min(sol.id) AS id,
    ai.id AS invoice_id,
    sp.id AS picking_id,
    so.id AS sale_id,
    pp.id AS product_id,
    so.partner_id,
    so.shop_id,
    so.user_id,
    sum((aml.debit - aml.credit)) AS delivery_amount,
    to_char(sp.date_done, 'YYYY-MM-DD' :: text) AS delivery_day,
    to_char(sp.date_done, 'MM' :: text) AS delivery_month,
    to_char(sp.date_done, 'YYYY' :: text) AS delivery_year,
    sum(ail.price_subtotal) AS invoice_amount,
    to_char(
        (ai.date_invoice) :: timestamp with time zone,
        'YYYY-MM-DD' :: text
    ) AS invoice_day,
    to_char(
        (ai.date_invoice) :: timestamp with time zone,
        'MM' :: text
    ) AS invoice_month,
    to_char(
        (ai.date_invoice) :: timestamp with time zone,
        'YYYY' :: text
    ) AS invoice_year
FROM
    (
        (
            (
                (
                    (
                        (
                            (
                                (
                                    (
                                        (
                                            sale_order_line sol
                                            LEFT JOIN sale_order so ON (
                                                (
                                                    so.id = sol.order_id
                                                )
                                            )
                                        )
                                        LEFT JOIN product_product pp ON (
                                            (
                                                pp.id = sol.product_id
                                            )
                                        )
                                    )
                                    LEFT JOIN stock_move sm ON (
                                        (
                                            (
                                                sm.sale_line_id = sol.id
                                            )
                                            AND (
                                                (sm.state) :: text <> 'cancel' :: text
                                            )
                                        )
                                    )
                                )
                                LEFT JOIN stock_picking sp ON ((sp.id = sm.picking_id))
                            )
                            LEFT JOIN account_move_line aml ON (
                                (
                                    (
                                        (aml.ref) :: text = (sp.name) :: text
                                    )
                                    AND (aml.product_id = sm.product_id)
                                    AND (aml.quantity = sm.product_qty)
                                    AND (
                                        aml.account_id = ANY(
                                            ARRAY [273,
        275,
        276,
        277,
        278,
        280,
        531,
        533,
        536,
        539,
        541,
        544,
        547,
        550,
        553,
        556,
        559,
        562,
        565,
        568,
        571,
        574,
        577,
        580,
        583,
        586,
        589,
        592,
        595,
        597,
        600,
        603,
        606,
        609,
        612]
                                        )
                                    )
                                )
                            )
                        )
                        LEFT JOIN account_move am ON (
                            (
                                am.id = aml.move_id
                            )
                        )
                    )
                    LEFT JOIN sale_order_invoice_rel soir ON (
                        (
                            soir.order_id = so.id
                        )
                    )
                )
                LEFT JOIN account_invoice ai ON (
                    (
                        (
                            ai.id = soir.invoice_id
                        )
                        AND (
                            (ai.state) :: text <> 'cancel' :: text
                        )
                        AND (
                            (ai.type) :: text = 'out_invoice' :: text
                        )
                    )
                )
            )
            LEFT JOIN sale_order_line_invoice_rel solir ON (
                (solir.order_line_id = sol.id)
            )
        )
        LEFT JOIN account_invoice_line ail ON (
            (
                (ail.id = solir.invoice_id)
                AND (ail.invoice_id = ai.id)
            )
        )
    )
WHERE
    (
        ((sp.state) :: text = 'done' :: text)
        AND (
            date_part('month' :: text, ai.date_invoice) <> date_part('month' :: text, sp.date_done)
        )
    )
GROUP BY
    ai.id,
    sp.id,
    so.id,
    pp.id,
    so.partner_id,
    so.shop_id,
    so.user_id,
    sp.date_done,
    ai.date_invoice
ORDER BY
    (min(sol.id)),
    ai.id DESC,
    sp.id DESC