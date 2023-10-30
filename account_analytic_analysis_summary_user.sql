WITH mu AS (
  SELECT
    max(res_users.id) AS max_user
  FROM
    res_users
),
lu AS (
  SELECT
    l.account_id,
    COALESCE(l.user_id, 0) AS user_id,
    sum(l.unit_amount) AS unit_amount
  FROM
    account_analytic_line l,
    account_analytic_journal j
  WHERE
    (
      ((j.type) :: text = 'general' :: text)
      AND (j.id = l.journal_id)
    )
  GROUP BY
    l.account_id,
    l.user_id
)
SELECT
  ((lu.account_id * mu.max_user) + lu.user_id) AS id,
  lu.account_id,
  lu.user_id AS "user",
  lu.unit_amount
FROM
  lu,
  mu