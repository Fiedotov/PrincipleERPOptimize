SELECT
    stock_valuation_compare.id,
    stock_valuation_compare.stock_move_id,
    stock_valuation_compare.product_id,
    stock_valuation_compare.name,
    stock_valuation_compare.valuation,
    stock_valuation_compare.picking_id,
    stock_valuation_compare.pick_name,
    stock_valuation_compare.date,
    stock_valuation_compare.acc_move_id,
    stock_valuation_compare.acc_ref,
    stock_valuation_compare.line_product_id,
    stock_valuation_compare.ref_stock_move,
    stock_valuation_compare.acc_name,
    stock_valuation_compare.acc_valuation,
    stock_valuation_compare.acc_date,
    stock_valuation_compare.valuation_diff
FROM
    (
        SELECT
            row_number() OVER () AS id,
            valuation_data.move_id AS stock_move_id,
            COALESCE(
                valuation_data.product_id,
                valuation_data.line_product_id
            ) AS product_id,
            valuation_data.prod_name AS name,
            valuation_data.valuation,
            valuation_data.picking_id,
            valuation_data.pick_name,
            valuation_data.mv_date AS date,
            valuation_data.acc_id AS acc_move_id,
            valuation_data.acc_ref,
            valuation_data.line_product_id,
            valuation_data.stock_move_id AS ref_stock_move,
            valuation_data.line_prod_name AS acc_name,
            valuation_data.acc_valuation,
            valuation_data.acc_date,
            (
                COALESCE(valuation_data.valuation, 0.0) - COALESCE(valuation_data.acc_valuation, 0.0)
            ) AS valuation_diff
        FROM
            (
                SELECT
                    row_number() OVER () AS row_no,
                    mv.id AS move_id,
                    (mv.price_unit * mv.product_qty) AS valuation,
                    mv.product_id,
                    'Test' :: character (1) AS pick_name,
                    mv.picking_id,
                    mv.name AS prod_name,
                    (mv.date) :: date AS mv_date,
                    row_number() OVER (
                        PARTITION BY am.id
                    ) AS row_no,
                    am.id AS acc_id,
                    am.stock_move_id,
                    am.ref AS acc_ref,
                    line.product_id AS line_product_id,
                    line.name AS line_prod_name,
                    line.debit AS acc_valuation,
                    am.date AS acc_date
                FROM
                    (
                        (
                            (
                                (
                                    (
                                        SELECT
                                            id,
                                            stock_move.price_unit,
                                            stock_move.product_qty,
                                            product_id,
                                            stock_move.picking_id,
                                            name,
                                            date,
                                            stock_move.location_id,
                                            stock_move.location_dest_id,
                                            stock_move.state
                                        FROM
                                            stock_move
                                        WHERE
                                            (
                                                (
                                                    stock_move.state
                                                ) :: text = 'done' :: text
                                            )
                                    ) mv
                                    JOIN (
                                        SELECT
                                            id,
                                            stock_move_id,
                                            account_move.ref,
                                            date
                                        FROM
                                            account_move
                                    ) am ON (
                                        (
                                            mv.id = am.stock_move_id
                                        )
                                    )
                                )
                                JOIN (
                                    SELECT
                                        product_id,
                                        move_id,
                                        name,
                                        account_move_line.debit
                                    FROM
                                        account_move_line
                                    WHERE
                                        (
                                            account_move_line.debit <> (
                                                0
                                            ) :: numeric
                                        )
                                ) line ON (
                                    (
                                        line.move_id = am.id
                                    )
                                )
                            )
                            JOIN (
                                SELECT
                                    id,
                                    stock_location.is_stock_location
                                FROM
                                    stock_location
                            ) stl ON (
                                (
                                    mv.location_id = stl.id
                                )
                            )
                        )
                        JOIN (
                            SELECT
                                id,
                                stock_location.is_stock_location
                            FROM
                                stock_location
                        ) stl1 ON (
                            (
                                mv.location_dest_id = stl1.id
                            )
                        )
                    )
                WHERE
                    (
                        (1 = 1)
                        AND (
                            (
                                stl.is_stock_location = false
                            )
                            OR (
                                stl1.is_stock_location = false
                            )
                        )
                        AND (1 = 1)
                    )
                UNION
                SELECT
                    stock_move.row_no,
                    stock_move.move_id,
                    stock_move.valuation,
                    stock_move.product_id,
                    stock_move.pick_name,
                    stock_move.picking_id,
                    stock_move.prod_name,
                    stock_move.mv_date,
                    data.row_no,
                    data.acc_id,
                    data.stock_move_id,
                    data.acc_ref,
                    data.line_product_id,
                    data.line_prod_name,
                    data.acc_valuation,
                    data.acc_date
                FROM
                    (
                        (
                            SELECT
                                row_number() OVER (
                                    PARTITION BY pick.name,
                                    mv.product_id,
                                    mv.name,
                                    mv.date
                                    ORDER BY
                                        pick.name,
                                        mv.product_id,
                                        mv.name,
                                        mv.date,
                                        mv.id
                                ) AS row_no,
                                mv.id AS move_id,
                                (mv.price_unit * mv.product_qty) AS valuation,
                                mv.product_id,
                                pick.name AS pick_name,
                                mv.picking_id,
                                mv.name AS prod_name,
                                mv.date AS mv_date
                            FROM
                                (
                                    (
                                        (
                                            (
                                                SELECT
                                                    id,
                                                    product_id,
                                                    name,
                                                    date,
                                                    stock_move.price_unit,
                                                    stock_move.product_qty,
                                                    stock_move.picking_id,
                                                    stock_move.location_id,
                                                    stock_move.location_dest_id,
                                                    stock_move.state
                                                FROM
                                                    stock_move
                                                WHERE
                                                    (
                                                        (stock_move.state) :: text = 'done' :: text
                                                    )
                                            ) mv
                                            JOIN (
                                                SELECT
                                                    id,
                                                    name
                                                FROM
                                                    stock_picking
                                            ) pick ON (
                                                (
                                                    mv.picking_id = pick.id
                                                )
                                            )
                                        )
                                        JOIN (
                                            SELECT
                                                id,
                                                stock_location.is_stock_location
                                            FROM
                                                stock_location
                                        ) stl ON (
                                            (mv.location_id = stl.id)
                                        )
                                    )
                                    JOIN (
                                        SELECT
                                            id,
                                            stock_location.is_stock_location
                                        FROM
                                            stock_location
                                    ) stl1 ON (
                                        (mv.location_dest_id = stl1.id)
                                    )
                                )
                            WHERE
                                (
                                    (1 = 1)
                                    AND (
                                        (stl.is_stock_location = false)
                                        OR (stl1.is_stock_location = false)
                                    )
                                    AND (
                                        NOT (
                                            EXISTS (
                                                SELECT
                                                    DISTINCT 1
                                                FROM
                                                    account_move
                                                WHERE
                                                    (account_move.stock_move_id IS NOT NULL)
                                                    AND (mv.id = account_move.stock_move_id)
                                            )
                                        )
                                    )
                                )
                        ) stock_move FULL
                        JOIN (
                            SELECT
                                move_line.row_no,
                                move_line.acc_id,
                                move_line.stock_move_id,
                                move_line.acc_ref,
                                move_line.line_product_id,
                                move_line.line_prod_name,
                                move_line.acc_valuation,
                                move_line.acc_date
                            FROM
                                (
                                    SELECT
                                        row_number() OVER (
                                            PARTITION BY move.ref,
                                            line.product_id,
                                            line.name,
                                            move.create_date
                                            ORDER BY
                                                move.ref,
                                                line.product_id,
                                                line.name,
                                                move.create_date,
                                                move.id
                                        ) AS row_no,
                                        move.id AS acc_id,
                                        move.stock_move_id,
                                        move.ref AS acc_ref,
                                        line.product_id AS line_product_id,
                                        line.name AS line_prod_name,
                                        line.debit AS acc_valuation,
                                        move.create_date AS acc_date
                                    FROM
                                        (
                                            (
                                                (
                                                    SELECT
                                                        id,
                                                        account_move.ref,
                                                        account_move.create_date,
                                                        stock_move_id,
                                                        account_move.journal_id
                                                    FROM
                                                        account_move
                                                    WHERE
                                                        (
                                                            (account_move.ref) :: text <> '' :: text
                                                        )
                                                ) move
                                                JOIN (
                                                    SELECT
                                                        move_id,
                                                        product_id,
                                                        name,
                                                        account_move_line.debit
                                                    FROM
                                                        account_move_line
                                                    WHERE
                                                        (
                                                            account_move_line.debit <> (0) :: numeric
                                                        )
                                                ) line ON (
                                                    (line.move_id = move.id)
                                                )
                                            )
                                            JOIN account_journal aj ON (
                                                (move.journal_id = aj.id)
                                            )
                                        )
                                    WHERE
                                        (
                                            (1 = 1)
                                            AND (move.stock_move_id IS NULL)
                                            AND (
                                                (move.ref IS NOT NULL)
                                                AND (1 = 1)
                                            )
                                            AND ((aj.type) :: text = 'general' :: text)
                                            AND (lower((aj.code) :: text) = 'stj' :: text)
                                        )
                                ) move_line
                        ) data ON (
                            (
                                (data.row_no = stock_move.row_no)
                                AND (
                                    (data.acc_ref) :: text = (stock_move.pick_name) :: text
                                )
                                AND (data.line_product_id = stock_move.product_id)
                                AND (
                                    lower(
                                        "substring"((data.line_prod_name) :: text, 1, 64)
                                    ) = lower(
                                        "substring"((stock_move.prod_name) :: text, 1, 64)
                                    )
                                )
                                AND (
                                    (
                                        date_part(
                                            'epoch' :: text,
                                            (stock_move.mv_date - data.acc_date)
                                        ) >= ('-59' :: integer) :: double precision
                                    )
                                    AND (
                                        date_part(
                                            'epoch' :: text,
                                            (stock_move.mv_date - data.acc_date)
                                        ) <= (59) :: double precision
                                    )
                                )
                            )
                        )
                    )
                UNION
                SELECT
                    stock_move.row_no,
                    stock_move.move_id,
                    stock_move.valuation,
                    stock_move.product_id,
                    stock_move.pick_name,
                    stock_move.picking_id,
                    stock_move.prod_name,
                    stock_move.mv_date,
                    data.row_no,
                    data.acc_id,
                    data.stock_move_id,
                    data.acc_ref,
                    data.line_product_id,
                    data.line_prod_name,
                    data.acc_valuation,
                    data.acc_date
                FROM
                    (
                        (
                            SELECT
                                row_number() OVER (
                                    PARTITION BY mv.product_id,
                                    mv.name,
                                    ((mv.date) :: date)
                                    ORDER BY
                                        mv.product_id,
                                        mv.name,
                                        ((mv.date) :: date)
                                ) AS row_no,
                                mv.id AS move_id,
                                (mv.price_unit * mv.product_qty) AS valuation,
                                mv.product_id,
                                'Test' :: text AS pick_name,
                                mv.picking_id,
                                mv.name AS prod_name,
                                (mv.date) :: date AS mv_date
                            FROM
                                (
                                    (
                                        (
                                            SELECT
                                                id,
                                                product_id,
                                                stock_move.product_qty,
                                                name,
                                                date,
                                                stock_move.price_unit,
                                                stock_move.picking_id,
                                                stock_move.location_id,
                                                stock_move.location_dest_id,
                                                stock_move.state
                                            FROM
                                                stock_move
                                            WHERE
                                                (
                                                    (stock_move.state) :: text = 'done' :: text
                                                )
                                        ) mv
                                        JOIN (
                                            SELECT
                                                id,
                                                stock_location.is_stock_location,
                                                stock_location.usage
                                            FROM
                                                stock_location
                                        ) stl ON (
                                            (mv.location_id = stl.id)
                                        )
                                    )
                                    JOIN stock_location stl1 ON ((mv.location_dest_id = stl1.id))
                                )
                            WHERE
                                (
                                    (1 = 1)
                                    AND (
                                        (stl.is_stock_location = false)
                                        OR (stl1.is_stock_location = false)
                                    )
                                    AND (
                                        (
                                            (stl.usage) :: text = 'inventory' :: text
                                        )
                                        OR (
                                            (stl1.usage) :: text = 'inventory' :: text
                                        )
                                    )
                                    AND (
                                        NOT (
                                            EXISTS (
                                                SELECT
                                                    DISTINCT 1
                                                FROM
                                                    account_move
                                                WHERE
                                                    (account_move.stock_move_id IS NOT NULL)
                                                    AND (mv.id = account_move.stock_move_id)
                                            )
                                        )
                                    )
                                )
                        ) stock_move FULL
                        JOIN (
                            SELECT
                                row_number() OVER (
                                    PARTITION BY move_line.line_product_id,
                                    move_line.line_prod_name,
                                    move_line.acc_date
                                    ORDER BY
                                        move_line.line_product_id,
                                        move_line.line_prod_name,
                                        move_line.acc_date
                                ) AS row_no,
                                move_line.acc_id,
                                move_line.stock_move_id,
                                move_line.acc_ref,
                                move_line.line_product_id,
                                move_line.line_prod_name,
                                move_line.acc_valuation,
                                move_line.acc_date
                            FROM
                                (
                                    SELECT
                                        move.id AS acc_id,
                                        move.stock_move_id,
                                        move.ref AS acc_ref,
                                        line.product_id AS line_product_id,
                                        line.name AS line_prod_name,
                                        line.debit AS acc_valuation,
                                        move.create_date AS acc_date
                                    FROM
                                        (
                                            (
                                                (
                                                    SELECT
                                                        id,
                                                        stock_move_id,
                                                        account_move.ref,
                                                        journal_id,
                                                        account_move.create_date
                                                    FROM
                                                        account_move
                                                    WHERE
                                                        (
                                                            (
                                                                (account_move.ref) :: text = NULL :: text
                                                            )
                                                            OR (
                                                                (account_move.ref) :: text = '' :: text
                                                            )
                                                        )
                                                ) move
                                                JOIN (
                                                    SELECT
                                                        product_id,
                                                        name,
                                                        account_move_line.debit,
                                                        move_id
                                                    FROM
                                                        account_move_line
                                                    WHERE
                                                        (
                                                            account_move_line.debit <> (0) :: numeric
                                                        )
                                                ) line ON ((line.move_id = move.id))
                                            )
                                            JOIN (
                                                SELECT
                                                    id,
                                                    account_journal.type,
                                                    account_journal.code
                                                FROM
                                                    account_journal
                                                WHERE
                                                    (
                                                        (account_journal.type) :: text = 'general' :: text
                                                    )
                                                    AND (
                                                        lower((account_journal.code) :: text) = 'stj' :: text
                                                    )
                                            ) aj ON ((move.journal_id = aj.id))
                                        )
                                    WHERE
                                        (
                                            (1 = 1)
                                            AND (move.stock_move_id IS NULL)
                                            AND (1 = 1)
                                            AND (1 = 1)
                                            AND (1 = 1)
                                        )
                                ) move_line
                        ) data ON (
                            (
                                (data.row_no = stock_move.row_no)
                                AND (data.line_product_id = stock_move.product_id)
                                AND (
                                    lower(
                                        "substring"((data.line_prod_name) :: text, 1, 64)
                                    ) = lower(
                                        "substring"((stock_move.prod_name) :: text, 1, 64)
                                    )
                                )
                                AND ((data.acc_date) :: date = stock_move.mv_date)
                            )
                        )
                    )
            ) valuation_data(
                row_no,
                move_id,
                valuation,
                product_id,
                pick_name,
                picking_id,
                prod_name,
                mv_date,
                row_no_1,
                acc_id,
                stock_move_id,
                acc_ref,
                line_product_id,
                line_prod_name,
                acc_valuation,
                acc_date
            )
    ) stock_valuation_compare