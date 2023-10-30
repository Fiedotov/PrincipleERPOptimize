SELECT
    t.id AS partner_name,
    t.id,
    t.name,
    t.email,
    t.phone
FROM
    (
        res_partner t
        JOIN (
            SELECT
                res_partner.name,
                count(res_partner.name) AS cnt
            FROM
                res_partner
            GROUP BY
                res_partner.name
            HAVING
                (count(res_partner.name) > 1)
        ) a ON (((a.name) :: text = (t.name) :: text))
    )