SELECT
   row_number() OVER () AS id,
   tt.product_id,
   sum((tt.day_1) :: double precision) AS day_1,
   sum((tt.day_2) :: double precision) AS day_2,
   sum((tt.day_3) :: double precision) AS day_3,
   sum((tt.day_4) :: double precision) AS day_4,
   sum((tt.day_5) :: double precision) AS day_5
FROM
   (
      SELECT
         newtable.product_id,
         COALESCE(newtable.day_1, '0' :: character varying) AS day_1,
         COALESCE(newtable.day_2, '0' :: character varying) AS day_2,
         COALESCE(newtable.day_3, '0' :: character varying) AS day_3,
         COALESCE(newtable.day_4, '0' :: character varying) AS day_4,
         COALESCE(newtable.day_5, '0' :: character varying) AS day_5
      FROM
         crosstab(
            'SELECT product_id,date,max(valuation_difference)::float as valuation_difference FROM daily_product_stock_valuation where date>=(current_date-5) and date<=(current_date-1) group by product_id,date ORDER  BY 1;' :: text,
            'Select distinct(date) from daily_product_stock_valuation where date>=(current_date-5) and date<=(current_date-1) order by date desc' :: text
         ) newtable(
            product_id integer,
            day_1 character varying,
            day_2 character varying,
            day_3 character varying,
            day_4 character varying,
            day_5 character varying
         )
   ) tt
WHERE
   (
      ((tt.day_1) :: text <> (tt.day_2) :: text)
      OR ((tt.day_2) :: text <> (tt.day_3) :: text)
      OR ((tt.day_3) :: text <> (tt.day_4) :: text)
      OR ((tt.day_4) :: text <> (tt.day_5) :: text)
   )
GROUP BY
   tt.product_id