SELECT
    min(f.id) AS id,
    count(*) AS nbr,
    min(
        (
            (
                date_part('month' :: text, f.create_date) || '-' :: text
            ) || to_char(f.create_date, 'Month' :: text)
        )
    ) AS month,
    sum(f.file_size) AS file_size
FROM
    ir_attachment f
GROUP BY
    (date_part('month' :: text, f.create_date))