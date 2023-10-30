SELECT
  row_number() OVER () AS id,
  res.name,
  res.sale_id,
  res.task_id,
  res.partner_id,
  res.shop_id,
  res.date,
  res.date_deadline,
  res.type,
  sum(res.pick_qty) AS picked_qty,
  sum(res.qty_to_pick) AS can_pick,
  sum(res.not_picked) AS can_not_pick,
  (sum(res.qty_to_pick) + sum(res.not_picked)) AS not_pick
FROM
  (
    SELECT
      tmp.name,
      tmp.sale_id,
      tmp.task_id,
      tmp.partner_id,
      tmp.shop_id,
      tmp.date,
      tmp.date_deadline,
      tmp.type,
      tmp.backorder_qty,
      tmp.qty_to_pick,
      tmp.pick_qty,
      (
        tmp.backorder_qty - (tmp.qty_to_pick + tmp.pick_qty)
      ) AS not_picked
    FROM
      (
        SELECT
          tp.name,
          tp.sale_id,
          tp.task_id,
          tp.partner_id,
          tp.shop_id,
          tp.date,
          tp.date_deadline,
          tp.type,
          tp.backorder_qty,
          COALESCE(
            CASE
              WHEN (COALESCE(picked.picked_qty) < (0) :: numeric) THEN (0) :: numeric
              WHEN (
                COALESCE(picked.picked_qty) <= (
                  COALESCE(tp.backorder_qty, (0) :: numeric) - COALESCE(tp.pick_qty, (0) :: numeric)
                )
              ) THEN COALESCE(picked.picked_qty, (0) :: numeric)
              WHEN (
                COALESCE(picked.picked_qty) > (
                  COALESCE(tp.backorder_qty, (0) :: numeric) - COALESCE(tp.pick_qty, (0) :: numeric)
                )
              ) THEN (
                COALESCE(tp.backorder_qty, (0) :: numeric) - COALESCE(tp.pick_qty, (0) :: numeric)
              )
              ELSE NULL :: numeric
            END,
            (0) :: numeric
          ) AS qty_to_pick,
          tp.pick_qty
        FROM
          (
            (
              SELECT
                s.name,
                s.id AS sale_id,
                NULL :: integer AS task_id,
                s.partner_id,
                s.shop_id,
                s.date_order AS date,
                s.date_deadline,
                'sale' :: text AS type,
                sl.product_id,
                sl.backorder_qty,
                sl.pick_qty
              FROM
                sale_order s,
                sale_order_line sl
              WHERE
                (
                  (s.id = sl.order_id)
                  AND (sl.backorder_qty <> sl.pick_qty)
                  AND (
                    (s.state) :: text = ANY (
                      ARRAY [('progress'::character varying)::text, ('manual'::character varying)::text]
                    )
                  )
                )
              UNION
              SELECT
                ('Job ' :: text || t.job_no) AS name,
                NULL :: integer AS sale_id,
                t.id AS task_id,
                t.partner_id,
                t.shop_id,
                t.create_date AS date,
                t.date_deadline,
                'task' :: text AS type,
                ts.product_id,
                ts.backorder_qty,
                ts.pick_qty
              FROM
                project_task t,
                project_task_stock ts
              WHERE
                (
                  (t.id = ts.task_id)
                  AND (ts.backorder_qty <> ts.pick_qty)
                )
            ) tp
            LEFT JOIN (
              SELECT
                sum(t.picked_qty) AS picked_qty,
                t.product_id,
                t.product_uom
              FROM
                (
                  SELECT
                    sum(stock_move.product_qty) AS picked_qty,
                    stock_move.product_id,
                    stock_move.product_uom
                  FROM
                    stock_move
                  WHERE
                    (
                      (
                        NOT (
                          stock_move.location_id IN (
                            SELECT
                              sw.lot_stock_id
                            FROM
                              (
                                stock_warehouse sw
                                JOIN stock_location sl ON ((sw.lot_stock_id = sl.id))
                              )
                            WHERE
                              (
                                (sl.do_not_count_in_stock = false)
                                OR (
                                  (sl.do_not_count_in_stock IS NULL)
                                  AND (sw.active = true)
                                )
                              )
                          )
                        )
                      )
                      AND (
                        stock_move.location_dest_id IN (
                          SELECT
                            sw.lot_stock_id
                          FROM
                            (
                              stock_warehouse sw
                              JOIN stock_location sl ON ((sw.lot_stock_id = sl.id))
                            )
                          WHERE
                            (
                              (sl.do_not_count_in_stock = false)
                              OR (
                                (sl.do_not_count_in_stock IS NULL)
                                AND (sw.active = true)
                              )
                            )
                        )
                      )
                      AND ((stock_move.state) :: text = 'done' :: text)
                    )
                  GROUP BY
                    stock_move.product_id,
                    stock_move.product_uom
                  UNION
                  SELECT
                    (
                      sum(stock_move.product_qty) * ('-1' :: integer) :: numeric
                    ) AS picked_qty,
                    stock_move.product_id,
                    stock_move.product_uom
                  FROM
                    stock_move
                  WHERE
                    (
                      (
                        stock_move.location_id IN (
                          SELECT
                            sw.lot_stock_id
                          FROM
                            (
                              stock_warehouse sw
                              JOIN stock_location sl ON ((sw.lot_stock_id = sl.id))
                            )
                          WHERE
                            (
                              (sl.do_not_count_in_stock = false)
                              OR (
                                (sl.do_not_count_in_stock IS NULL)
                                AND (sw.active = true)
                              )
                            )
                        )
                      )
                      AND (
                        NOT (
                          stock_move.location_dest_id IN (
                            SELECT
                              sw.lot_stock_id
                            FROM
                              (
                                stock_warehouse sw
                                JOIN stock_location sl ON ((sw.lot_stock_id = sl.id))
                              )
                            WHERE
                              (
                                (sl.do_not_count_in_stock = false)
                                OR (
                                  (sl.do_not_count_in_stock IS NULL)
                                  AND (sw.active = true)
                                )
                              )
                          )
                        )
                      )
                      AND (
                        (stock_move.state) :: text = ANY (
                          (
                            ARRAY ['done'::character varying, 'assigned'::character varying]
                          ) :: text []
                        )
                      )
                    )
                  GROUP BY
                    stock_move.product_id,
                    stock_move.product_uom
                ) t
              GROUP BY
                t.product_id,
                t.product_uom
            ) picked ON ((tp.product_id = picked.product_id))
          )
      ) tmp
    WHERE
      (tmp.qty_to_pick > (0) :: numeric)
  ) res
GROUP BY
  res.name,
  res.sale_id,
  res.task_id,
  res.partner_id,
  res.shop_id,
  res.date,
  res.date_deadline,
  res.type
ORDER BY
  res.date DESC