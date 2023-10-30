SELECT
    min(m.id) AS id,
    m.date,
    to_char(m.date, 'YYYY' :: text) AS year,
    to_char(m.date, 'MM' :: text) AS month,
    m.partner_id,
    m.location_id,
    m.product_id,
    pt.categ_id AS product_categ_id,
    l.usage AS location_type,
    l.scrap_location,
    m.company_id,
    m.state,
    m.prodlot_id,
    COALESCE(
        sum(
            (
                (
                    ((- pt.standard_price) * m.product_qty) * pu.factor
                ) / pu2.factor
            )
        ),
        0.0
    ) AS value,
    COALESCE(
        sum((((- m.product_qty) * pu.factor) / pu2.factor)),
        0.0
    ) AS product_qty
FROM
    (
        (
            (
                (
                    (
                        (
                            (
                                stock_move m
                                LEFT JOIN stock_picking p ON (
                                    (
                                        m.picking_id = p.id
                                    )
                                )
                            )
                            LEFT JOIN product_product pp ON (
                                (
                                    m.product_id = pp.id
                                )
                            )
                        )
                        LEFT JOIN product_template pt ON (
                            (
                                pp.product_tmpl_id = pt.id
                            )
                        )
                    )
                    LEFT JOIN product_uom pu ON ((pt.uom_id = pu.id))
                )
                LEFT JOIN product_uom pu2 ON ((m.product_uom = pu2.id))
            )
            LEFT JOIN product_uom u ON ((m.product_uom = u.id))
        )
        LEFT JOIN stock_location l ON ((m.location_id = l.id))
    )
WHERE
    ((m.state) :: text <> 'cancel' :: text)
GROUP BY
    m.id,
    m.product_id,
    m.product_uom,
    pt.categ_id,
    m.partner_id,
    m.location_id,
    m.location_dest_id,
    m.prodlot_id,
    m.date,
    m.state,
    l.usage,
    l.scrap_location,
    m.company_id,
    pt.uom_id,
    (to_char(m.date, 'YYYY' :: text)),
    (to_char(m.date, 'MM' :: text))
UNION
ALL
SELECT
    (- m.id) AS id,
    m.date,
    to_char(m.date, 'YYYY' :: text) AS year,
    to_char(m.date, 'MM' :: text) AS month,
    m.partner_id,
    m.location_dest_id AS location_id,
    m.product_id,
    pt.categ_id AS product_categ_id,
    l.usage AS location_type,
    l.scrap_location,
    m.company_id,
    m.state,
    m.prodlot_id,
    COALESCE(
        sum(
            (
                ((pt.standard_price * m.product_qty) * pu.factor) / pu2.factor
            )
        ),
        0.0
    ) AS value,
    COALESCE(
        sum(((m.product_qty * pu.factor) / pu2.factor)),
        0.0
    ) AS product_qty
FROM
    (
        (
            (
                (
                    (
                        (
                            (
                                stock_move m
                                LEFT JOIN stock_picking p ON ((m.picking_id = p.id))
                            )
                            LEFT JOIN product_product pp ON ((m.product_id = pp.id))
                        )
                        LEFT JOIN product_template pt ON ((pp.product_tmpl_id = pt.id))
                    )
                    LEFT JOIN product_uom pu ON ((pt.uom_id = pu.id))
                )
                LEFT JOIN product_uom pu2 ON ((m.product_uom = pu2.id))
            )
            LEFT JOIN product_uom u ON ((m.product_uom = u.id))
        )
        LEFT JOIN stock_location l ON ((m.location_dest_id = l.id))
    )
WHERE
    ((m.state) :: text <> 'cancel' :: text)
GROUP BY
    m.id,
    m.product_id,
    m.product_uom,
    pt.categ_id,
    m.partner_id,
    m.location_id,
    m.location_dest_id,
    m.prodlot_id,
    m.date,
    m.state,
    l.usage,
    l.scrap_location,
    m.company_id,
    pt.uom_id,
    (to_char(m.date, 'YYYY' :: text)),
    (to_char(m.date, 'MM' :: text))