SELECT
        row_number() OVER () AS id,
        sum(tmp.qty) AS qty,
        tmp.product_id,
        tmp.category_id,
        (SELECT
            stock_move.price_unit 
        FROM
            stock_move 
        WHERE
            (
                (
                    (
                        stock_move.state
                    )::text = 'done'::text
                ) 
                AND (
                    stock_move.date < '2017-05-26 00:00:00'::timestamp without time zone
                ) 
                AND (
                    stock_move.product_id = tmp.product_id
                )
            ) 
        ORDER BY
            stock_move.id DESC LIMIT 1) AS cost_price 
    FROM
        (SELECT
            sum(sm.product_qty) AS qty,
            sm.product_id,
            p.category_id 
        FROM
            (stock_move sm 
        JOIN
            product_product p 
                ON (
                    (
                        sm.product_id = p.id
                    )
                )
            ) 
    WHERE
        (
            (
                NOT (sm.location_id IN (SELECT
                    stock_location.id 
                FROM
                    stock_location 
                WHERE
                    (stock_location.is_stock_location = true)))
            ) 
            AND (
                sm.location_dest_id IN (
                    SELECT
                        stock_location.id 
                    FROM
                        stock_location 
                    WHERE
                        (
                            stock_location.is_stock_location = true
                        )
                )
            ) 
            AND (
                (
                    sm.state
                )::text = 'done'::text
            ) 
            AND (
                sm.date < '2017-05-26 00:00:00'::timestamp without time zone
            )
        ) 
    GROUP BY
        sm.product_id,
        p.category_id 
    UNION
    ALL SELECT
        (sum(sm.product_qty) * ('-1'::integer)::numeric) AS qty,
        sm.product_id,
        p.category_id 
    FROM
        (stock_move sm 
    JOIN
        product_product p 
            ON (
                (
                    sm.product_id = p.id
                )
            )
        ) 
WHERE
    (
        (
            sm.location_id IN (
                SELECT
                    stock_location.id 
                FROM
                    stock_location 
                WHERE
                    (
                        stock_location.is_stock_location = true
                    )
            )
        ) 
        AND (
            NOT (sm.location_dest_id IN (SELECT
                stock_location.id 
            FROM
                stock_location 
            WHERE
                (stock_location.is_stock_location = true)))
        ) 
        AND (
            (
                sm.state
            )::text = 'done'::text
        ) 
        AND (
            sm.date < '2017-05-26 00:00:00'::timestamp without time zone
        )
    ) 
GROUP BY
    sm.product_id,
    p.category_id) tmp 
GROUP BY
    tmp.product_id,
    tmp.category_id