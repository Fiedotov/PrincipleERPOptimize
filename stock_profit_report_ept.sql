SELECT
    ail.id,
    ai.date_invoice AS date,
    ai.create_uid AS related_user_id,
    ail.product_id,
    round(ail.quantity, 2) AS qty_sold,
    round(
        (
            ail.price_subtotal / CASE
                ail.quantity
                WHEN 0 THEN (1) :: numeric
                ELSE ail.quantity
            END
        ),
        2
    ) AS average_price,
    round(ail.price_subtotal, 2) AS price_subtotal,
    round(
        (
            (
                (ail.price_subtotal) :: double precision - (
                    (ail.quantity) :: double precision * CASE
                        WHEN (ail.standard_price IS NOT NULL) THEN ail.standard_price
                        ELSE (0.0) :: double precision
                    END
                )
            )
        ) :: numeric,
        2
    ) AS gross_profit,
    round(
        (
            (
                (ail.quantity) :: double precision * CASE
                    WHEN (ail.standard_price IS NOT NULL) THEN ail.standard_price
                    ELSE (0.0) :: double precision
                END
            )
        ) :: numeric,
        2
    ) AS cogs_subtotal,
    round(
        (
            CASE
                WHEN (ail.standard_price IS NOT NULL) THEN ail.standard_price
                ELSE (0.0) :: double precision
            END
        ) :: numeric,
        2
    ) AS average_cogs,
    CASE
        WHEN (ail.price_subtotal <> (0) :: numeric) THEN round(
            (
                (
                    (
                        (
                            (ail.price_subtotal) :: double precision - (
                                (ail.quantity) :: double precision * CASE
                                    WHEN (ail.standard_price IS NOT NULL) THEN ail.standard_price
                                    ELSE (0.0) :: double precision
                                END
                            )
                        ) / (ail.price_subtotal) :: double precision
                    ) * (100) :: double precision
                )
            ) :: numeric,
            2
        )
        ELSE (0) :: numeric
    END AS gross_profit_percentage,
    p.brand,
    p.category_id,
    ail.partner_id,
    ai.shop_id,
    ai.period_id
FROM
    (
        (
            account_invoice_line ail
            JOIN account_invoice ai ON ((ail.invoice_id = ai.id))
        )
        LEFT JOIN product_product p ON ((ail.product_id = p.id))
    )
WHERE
    ((ai.type) :: text = 'out_invoice' :: text)
GROUP BY
    ail.product_id,
    ai.date_invoice,
    p.brand,
    p.category_id,
    ail.partner_id,
    ai.shop_id,
    ail.id,
    ai.create_uid,
    ai.period_id