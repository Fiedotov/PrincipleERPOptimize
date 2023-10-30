SELECT
    max(cost.id) AS id,
    cost.product_id,
    sum(cost.purchase_qty) AS purchase_qty,
    sum(cost.purchase_amount) AS purchase_amount,
    sum(cost.sale_qty) AS sale_qty,
    sum(cost.cost_of_goods) AS cost_of_goods
FROM
    (
        SELECT
            (- min(sm.product_id)) AS id,
            sm.product_id,
            sum(
                CASE
                    WHEN (sm.location_id = 8) THEN sm.product_qty
                    ELSE (- sm.product_qty)
                END
            ) AS purchase_qty,
            sum(
                (
                    CASE
                        WHEN (sm.location_id = 8) THEN sm.product_qty
                        ELSE (- sm.product_qty)
                    END * pol.price_unit
                )
            ) AS purchase_amount,
            0 AS sale_qty,
            0 AS cost_of_goods
        FROM
            (
                stock_move sm
                LEFT JOIN purchase_order_line pol ON ((pol.id = sm.purchase_line_id))
            )
        WHERE
            (
                (
                    (sm.location_id = 8)
                    OR (sm.location_dest_id = 8)
                )
                AND ((sm.state) :: text = 'done' :: text)
            )
        GROUP BY
            sm.product_id
        UNION
        ALL
        SELECT
            min(sm.product_id) AS id,
            sm.product_id,
            0 AS purchase_qty,
            0 AS purchase_amount,
            sum(
                CASE
                    WHEN (sm.location_dest_id = 9) THEN sm.product_qty
                    ELSE (- sm.product_qty)
                END
            ) AS sale_qty,
            sum((aml.debit - aml.credit)) AS cost_of_goods
        FROM
            (
                (
                    stock_move sm
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
        WHERE
            (
                (
                    (sm.location_id = 9)
                    OR (sm.location_dest_id = 9)
                )
                AND ((sm.state) :: text = 'done' :: text)
            )
        GROUP BY
            sm.product_id
    ) cost
GROUP BY
    cost.product_id