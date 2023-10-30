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
                res_partner.phone,
                count(res_partner.phone) AS cnt
            FROM
                res_partner
            GROUP BY
                res_partner.phone
            HAVING
                (count(res_partner.phone) > 1)
        ) a ON (((a.phone) :: text = (t.phone) :: text))
    )