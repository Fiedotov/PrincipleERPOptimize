SELECT
        min(f.id) AS id,
        to_char(f.create_date,
        'YYYY'::text) AS name,
        to_char(f.create_date,
        'MM'::text) AS month,
        f.user_id,
        count(*) AS nbr,
        d.name AS directory,
        f.datas_fname,
        f.create_date,
        f.file_size,
        min((d.type)::text) AS type,
        f.write_date AS change_date 
    FROM
        (ir_attachment f 
    LEFT JOIN
        document_directory d 
            ON (
                (
                    (
                        f.parent_id = d.id
                    ) 
                    AND (
                        (
                            d.name
                        )::text <> ''::text
                    )
                )
            )
        ) 
GROUP BY
    (to_char(f.create_date,
    'YYYY'::text)),
    (to_char(f.create_date,
    'MM'::text)),
    d.name,
    f.parent_id,
    d.type,
    f.create_date,
    f.user_id,
    f.file_size,
    f.write_date,
    f.datas_fname
		