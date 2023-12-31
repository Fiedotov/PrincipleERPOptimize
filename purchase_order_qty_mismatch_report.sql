SELECT
    p.id,
    p.id AS order_id,
    p.date_order AS date,
    p.origin,
    p.minimum_planned_date AS planned_date,
    p.partner_id,
    p.shop_id,
    p.company_id,
    p.shipped,
    p.amount_total,
    p.amount_untaxed,
    p.state
FROM
    purchase_order p
WHERE
    (
        p.id = ANY (
            ARRAY [21081, 20225, 20995, 20868, 20761, 20737, 20744, 20204, 21079, 20747, 20930, 20638, 21037, 20987, 20952, 20372, 20758, 20276, 19353, 21022, 20254, 20896, 21035, 20260, 21029, 20006, 18728, 20828, 20906, 20916, 20786, 20402, 20275, 20148, 20533, 20919, 20409, 21050, 20170, 21054, 20799, 20787, 21060, 21061, 21062, 20935, 21064, 20938, 20900, 20940, 21070, 21071, 20304, 20562, 20963, 20665, 18520, 20388, 20996, 20444, 21085, 21093, 21072, 20859, 21092, 20646, 20577, 20999, 20860, 20971, 20332, 21074, 20887, 20725, 21089, 20600, 21091, 20347, 20732, 20861, 20863]
        )
    )