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
        res_partner.email,
        count(res_partner.email) AS cnt
      FROM
        res_partner
      GROUP BY
        res_partner.email
      HAVING
        (count(res_partner.email) > 1)
    ) a ON (((a.email) :: text = (t.email) :: text))
  )