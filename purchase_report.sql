SELECT
    min(l.id) AS id,
    s.date_order AS date,
    to_char(
        (s.date_order) :: timestamp with time zone,
        'YYYY' :: text
    ) AS name,
    to_char(
        (s.date_order) :: timestamp with time zone,
        'MM' :: text
    ) AS month,
    to_char(
        (s.date_order) :: timestamp with time zone,
        'YYYY-MM-DD' :: text
    ) AS day,
    s.state,
    s.date_approve,
    s.minimum_planned_date AS expected_date,
    s.dest_address_id,
    s.pricelist_id,
    s.validator,
    s.warehouse_id,
    s.partner_id,
    s.create_uid AS user_id,
    s.company_id,
    l.product_id,
    t.categ_id AS category_id,
    t.uom_id AS product_uom,
    s.location_id,
    sum(((l.product_qty / u.factor) * u2.factor)) AS quantity,
    (
        date_part(
            'epoch' :: text,
            age(
                (s.date_approve) :: timestamp with time zone,
                (s.date_order) :: timestamp with time zone
            )
        ) / ((((24 * 60) * 60)) :: numeric (16, 2)) :: double precision
    ) AS delay,
    (
        date_part(
            'epoch' :: text,
            age(
                (l.date_planned) :: timestamp with time zone,
                (s.date_order) :: timestamp with time zone
            )
        ) / ((((24 * 60) * 60)) :: numeric (16, 2)) :: double precision
    ) AS delay_pass,
    count(*) AS nbr,
    (sum((l.price_unit * l.product_qty))) :: numeric (16, 2) AS price_total,
    (
        avg(
            (
                (100.0 * (l.price_unit * l.product_qty)) / NULLIF(
                    (
                        ((t.standard_price * l.product_qty) / u.factor) * u2.factor
                    ),
                    0.0
                )
            )
        )
    ) :: numeric (16, 2) AS negociation,
    (
        sum(
            (
                ((t.standard_price * l.product_qty) / u.factor) * u2.factor
            )
        )
    ) :: numeric (16, 2) AS price_standard,
    (
        (
            sum((l.product_qty * l.price_unit)) / NULLIF(
                sum(((l.product_qty / u.factor) * u2.factor)),
                0.0
            )
        )
    ) :: numeric (16, 2) AS price_average
FROM
    (
        (
            (
                (
                    (
                        purchase_order_line l
                        JOIN purchase_order s ON (
                            (
                                l.order_id = s.id
                            )
                        )
                    )
                    LEFT JOIN product_product p ON (
                        (
                            l.product_id = p.id
                        )
                    )
                )
                LEFT JOIN product_template t ON (
                    (p.product_tmpl_id = t.id)
                )
            )
            LEFT JOIN product_uom u ON ((u.id = l.product_uom))
        )
        LEFT JOIN product_uom u2 ON ((u2.id = t.uom_id))
    )
GROUP BY
    s.company_id,
    s.create_uid,
    s.partner_id,
    u.factor,
    s.location_id,
    l.price_unit,
    s.date_approve,
    l.date_planned,
    l.product_uom,
    s.minimum_planned_date,
    s.pricelist_id,
    s.validator,
    s.dest_address_id,
    l.product_id,
    t.categ_id,
    s.date_order,
    (
        to_char(
            (s.date_order) :: timestamp with time zone,
            'YYYY' :: text
        )
    ),
    (
        to_char(
            (s.date_order) :: timestamp with time zone,
            'MM' :: text
        )
    ),
    (
        to_char(
            (s.date_order) :: timestamp with time zone,
            'YYYY-MM-DD' :: text
        )
    ),
    s.state,
    s.warehouse_id,
    u.uom_type,
    u.category_id,
    t.uom_id,
    u.id,
    u2.factor