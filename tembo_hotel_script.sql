create schema hotel_data;

--- Creating the table

create table hotel_data.tembo_hotel(
    booking_id TEXT,
    guest_name TEXT,
    guest_phone TEXT,
    guest_city TEXT,
    guest_nationality TEXT,
    room_no TEXT,
    room_type TEXT,
    room_rate_per_night TEXT,
    check_in_date TEXT,
    check_out_date TEXT,
    nights_stayed TEXT,
    staff_name TEXT,
    staff_department TEXT,
    staff_salary TEXT,
    payment_method TEXT,
    booking_status TEXT,
    total_amount TEXT,
    service_used TEXT,
    service_price TEXT,
    guest_rating TEXT
);

select * from hotel_data.tembo_hotel

select count(*)
from hotel_data.tembo_hotel;

-- Create clean data

CREATE TABLE hotel_data.tembo_hotel_clean (
    booking_id TEXT,
    guest_name TEXT,
    guest_phone TEXT,
    guest_city TEXT,
    guest_nationality TEXT,
    room_no INTEGER,
    room_type TEXT,
    room_rate_per_night NUMERIC,
    check_in_date DATE,
    check_out_date DATE,
    nights_stayed INTEGER,
    staff_name TEXT,
    staff_department TEXT,
    staff_salary NUMERIC,
    payment_method TEXT,
    booking_status TEXT,
    total_amount NUMERIC,
    service_used TEXT,
    service_price NUMERIC,
    guest_rating NUMERIC
);

select count(*)
from hotel_data.tembo_hotel_clean;

--- Booking ID n Guest name

INSERT INTO hotel_data.tembo_hotel_clean (
    booking_id,
    guest_name
)
SELECT DISTINCT ON (TRIM(booking_id))
    TRIM(booking_id),
    INITCAP(TRIM(guest_name))
FROM hotel_data.tembo_hotel
ORDER BY TRIM(booking_id);

select count(*)
from hotel_data.tembo_hotel_clean;


SELECT *
FROM hotel_data.tembo_hotel_clean
LIMIT 10;

--- Phone numbers

UPDATE hotel_data.tembo_hotel_clean c
SET guest_phone =
    CASE
        WHEN regexp_replace(TRIM(r.guest_phone), '[^0-9]', '', 'g') LIKE '254%'
            THEN '+' || regexp_replace(TRIM(r.guest_phone), '[^0-9]', '', 'g')
        WHEN regexp_replace(TRIM(r.guest_phone), '[^0-9]', '', 'g') LIKE '0%'
            THEN '+254' ||
                 SUBSTRING(
                     regexp_replace(TRIM(r.guest_phone), '[^0-9]', '', 'g')
                     FROM 2
                 )
        ELSE NULL
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT booking_id, guest_phone
FROM hotel_data.tembo_hotel_clean
LIMIT 10;

--- Guest City

UPDATE hotel_data.tembo_hotel_clean c
SET guest_city =
    CASE
        WHEN LOWER(TRIM(r.guest_city)) = 'nairobi'
            THEN 'Nairobi'
        WHEN LOWER(TRIM(r.guest_city)) = 'mombasa'
            THEN 'Mombasa'
        WHEN LOWER(TRIM(r.guest_city)) = 'kisumu'
            THEN 'Kisumu'
        WHEN LOWER(TRIM(r.guest_city)) = 'nakuru'
            THEN 'Nakuru'
        WHEN LOWER(TRIM(r.guest_city)) = 'eldoret'
            THEN 'Eldoret'
        WHEN LOWER(TRIM(r.guest_city)) = 'machakos'
            THEN 'Machakos'
        WHEN LOWER(TRIM(r.guest_city)) = 'meru'
            THEN 'Meru'
        WHEN LOWER(TRIM(r.guest_city)) = 'nyeri'
            THEN 'Nyeri'
        WHEN LOWER(TRIM(r.guest_city)) = 'thikax'
            THEN 'Thika'
        ELSE INITCAP(TRIM(r.guest_city))
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT guest_city, COUNT(*) AS bookings
FROM hotel_data.tembo_hotel_clean
GROUP BY guest_city
ORDER BY bookings DESC;


--- Nationality

-- Populate
UPDATE hotel_data.tembo_hotel_clean c
SET guest_nationality = INITCAP(TRIM(r.guest_nationality))
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

--- Check
SELECT guest_nationality, COUNT(*) AS guests
FROM hotel_data.tembo_hotel_clean
GROUP BY guest_nationality
ORDER BY guests DESC;


--- Room Number


UPDATE hotel_data.tembo_hotel_clean c
SET room_no =
    CASE
        WHEN TRIM(r.room_no) ~ '^[0-9]+$'
            THEN TRIM(r.room_no)::INTEGER
        ELSE NULL
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT booking_id, room_no
FROM hotel_data.tembo_hotel_clean
LIMIT 10;


--- Room Type

UPDATE hotel_data.tembo_hotel_clean c
SET room_type =
    CASE
        WHEN LOWER(TRIM(r.room_type)) IN ('standard', 'std')
            THEN 'Standard'
        WHEN LOWER(TRIM(r.room_type)) IN ('deluxe', 'dlx')
            THEN 'Deluxe'
        WHEN LOWER(TRIM(r.room_type)) = 'suite'
            THEN 'Suite'
        WHEN LOWER(TRIM(r.room_type)) = 'penthouse'
            THEN 'Penthouse'
        ELSE INITCAP(TRIM(r.room_type))
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT room_type, COUNT(*) AS bookings
FROM hotel_data.tembo_hotel_clean
GROUP BY room_type
ORDER BY bookings DESC;


--- Room Rate

UPDATE hotel_data.tembo_hotel_clean c
SET room_rate_per_night =
    CASE
        WHEN TRIM(r.room_rate_per_night) ~ '^[0-9]+(\.[0-9]+)?$'
            THEN TRIM(r.room_rate_per_night)::NUMERIC
        ELSE NULL
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT
    booking_id,
    room_type,
    room_rate_per_night
FROM hotel_data.tembo_hotel_clean
LIMIT 10;



SELECT
    COUNT(*) AS total_rows,
    COUNT(guest_phone) AS phones,
    COUNT(guest_city) AS cities,
    COUNT(guest_nationality) AS nationalities,
    COUNT(room_no) AS room_numbers,
    COUNT(room_type) AS room_types,
    COUNT(room_rate_per_night) AS room_rates
FROM hotel_data.tembo_hotel_clean;

-- Check in date

UPDATE hotel_data.tembo_hotel_clean c
SET check_in_date =
    case
	    -- YYYY-MM-DD
        WHEN TRIM(r.check_in_date) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TO_DATE(
                 TRIM(r.check_in_date), 
                 'YYYY-MM-DD'
                 )
                 -- DD/MM/YYYY
        WHEN TRIM(r.check_in_date) ~ '^\d{1,2}/\d{1,2}/\d{4}$'
            THEN TO_DATE(
            TRIM(r.check_in_date), 
            'DD/MM/YYYY'
            )
            -- DD-MM-YYYY when first number is greater than 12
        WHEN TRIM(r.check_in_date) ~ '^\d{1,2}-\d{1,2}-\d{4}$'
             AND SPLIT_PART(
                 TRIM(r.check_in_date), 
                 '-', 
                 1
                 )::INTEGER > 12
                 THEN TO_DATE(
                      TRIM(r.check_in_date),
                      'DD-MM-YYYY'
                  )
                  -- DD-MM-YY
        WHEN TRIM(r.check_in_date) ~ '^\d{1,2}-\d{1,2}-\d{4}$'
              AND SPLIT_PART(
                    TRIM(r.check_in_date),
                    '-',
                    1
                 )::INTEGER > 12
            THEN TO_DATE(
                 TRIM(r.check_in_date), 
                 'MM-DD-YY'
                 )
            ELSE NULL
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

--Check
SELECT
    booking_id,
    check_in_date
FROM hotel_data.tembo_hotel_clean
ORDER BY booking_id
LIMIT 20;


-- Check out date

UPDATE hotel_data.tembo_hotel_clean c
SET check_out_date =
    CASE
       -- YYYY-MM-DD
        WHEN TRIM(r.check_out_date) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TO_DATE(
                TRIM(r.check_out_date),
                'YYYY-MM-DD'
            )
        -- DD/MM/YYYY
        WHEN TRIM(r.check_out_date) ~ '^\d{1,2}/\d{1,2}/\d{4}$'
            THEN TO_DATE(
                TRIM(r.check_out_date),
                'DD/MM/YYYY'
            )
         -- DD-MM-YYYY when first number is greater than 12
        WHEN TRIM(r.check_out_date) ~ '^\d{1,2}-\d{1,2}-\d{4}$'
             AND SPLIT_PART(
                    TRIM(r.check_out_date),
                    '-',
                    1
                 )::INTEGER > 12
            THEN TO_DATE(
                TRIM(r.check_out_date),
                'DD-MM-YYYY'
            )
         -- MM-DD-YYYY
        WHEN TRIM(r.check_out_date) ~ '^\d{1,2}-\d{1,2}-\d{4}$'
            THEN TO_DATE(
                TRIM(r.check_out_date),
                'MM-DD-YYYY'
            )
         -- DD-MM-YY
        WHEN TRIM(r.check_out_date) ~ '^\d{1,2}-\d{1,2}-\d{2}$'
             AND SPLIT_PART(
                    TRIM(r.check_out_date),
                    '-',
                    1
                 )::INTEGER > 12
            THEN TO_DATE(
                TRIM(r.check_out_date),
                'DD-MM-YY'
            )
         -- MM-DD-YY
        WHEN TRIM(r.check_out_date) ~ '^\d{1,2}-\d{1,2}-\d{2}$'
            THEN TO_DATE(
                TRIM(r.check_out_date),
                'MM-DD-YY'
            )
        ELSE NULL
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT
    booking_id,
    check_in_date,
    check_out_date
FROM hotel_data.tembo_hotel_clean
ORDER BY booking_id
LIMIT 20;



-- Find impossible dates

SELECT
    booking_id,
    check_in_date,
    check_out_date
FROM hotel_data.tembo_hotel_clean
WHERE check_in_date IS NOT NULL
  AND check_out_date IS NOT NULL
  AND check_out_date < check_in_date;




-- Nights stayed

-- Valid nights
UPDATE hotel_data.tembo_hotel_clean
SET nights_stayed =
    CASE
        WHEN check_in_date IS NOT NULL
         AND check_out_date IS NOT NULL
         AND check_out_date > check_in_date
        THEN check_out_date - check_in_date
        ELSE NULL
    END;


-- Problem bookings
SELECT
    booking_id,
    check_in_date,
    check_out_date,
    nights_stayed
FROM hotel_data.tembo_hotel_clean
WHERE booking_id IN ('BK9002', 'BK9003');



-- Checkkkk
SELECT
    COUNT(*) AS total_bookings,
    COUNT(nights_stayed) AS valid_stays,
    COUNT(*) - COUNT(nights_stayed) AS invalid_or_missing_stays,
    MIN(nights_stayed) AS minimum_nights,
    MAX(nights_stayed) AS maximum_nights,
    ROUND(AVG(nights_stayed), 2) AS average_nights
FROM hotel_data.tembo_hotel_clean;




-- Staff Name

UPDATE hotel_data.tembo_hotel_clean c
SET staff_name = INITCAP(TRIM(r.staff_name))
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT
    staff_name,
    COUNT(*) AS bookings
FROM hotel_data.tembo_hotel_clean
GROUP BY staff_name
ORDER BY bookings DESC;



-- Staff department

UPDATE hotel_data.tembo_hotel_clean c
SET staff_department = INITCAP(TRIM(r.staff_department))
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- check
SELECT
    staff_department,
    COUNT(*) AS bookings
FROM hotel_data.tembo_hotel_clean
GROUP BY staff_department
ORDER BY bookings DESC;



-- Staff salary

UPDATE hotel_data.tembo_hotel_clean c
SET staff_salary =
    CASE
        WHEN TRIM(r.staff_salary) ~ '^[0-9]+(\.[0-9]+)?$'
        THEN TRIM(r.staff_salary)::NUMERIC
        ELSE NULL
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT
    staff_name,
    staff_department,
    staff_salary
FROM hotel_data.tembo_hotel_clean
LIMIT 15;



-- Payment method

UPDATE hotel_data.tembo_hotel_clean c
SET payment_method =
    CASE
        WHEN LOWER(TRIM(r.payment_method)) = 'mpesa'
            THEN 'M-Pesa'
        WHEN LOWER(TRIM(r.payment_method)) = 'm-pesa'
            THEN 'M-Pesa'
         WHEN LOWER(TRIM(r.payment_method)) = 'cash'
            THEN 'Cash'
        WHEN LOWER(TRIM(r.payment_method)) = 'card'
            THEN 'Card'
        WHEN LOWER(TRIM(r.payment_method)) = 'bank transfer'
            THEN 'Bank Transfer'
        ELSE INITCAP(TRIM(r.payment_method))
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- check
SELECT
    payment_method,
    COUNT(*) AS bookings
FROM hotel_data.tembo_hotel_clean
GROUP BY payment_method
ORDER BY bookings DESC;



-- Booking status

UPDATE hotel_data.tembo_hotel_clean c
SET booking_status =
    CASE
        WHEN LOWER(TRIM(r.booking_status)) IN ('checked out', 'checked-out')
            THEN 'Checked Out'
        WHEN LOWER(TRIM(r.booking_status)) IN ('cancelled', 'canceled')
            THEN 'Cancelled'
        WHEN LOWER(TRIM(r.booking_status)) IN ('no show', 'no-show')
            THEN 'No Show'
        ELSE INITCAP(TRIM(r.booking_status))
    END
FROM hotel_data.tembo_hotel r
WHERE c.booking_id = TRIM(r.booking_id);

-- Check
SELECT
    booking_status,
    COUNT(*) AS bookings
FROM hotel_data.tembo_hotel_clean
GROUP BY booking_status
ORDER BY bookings DESC;



-- Total amount

--- check first
-- original tembo
SELECT total_amount
FROM hotel_data.tembo_hotel
LIMIT 20;

-- data type
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'hotel_data'
  AND table_name = 'tembo'
  AND column_name = 'total_amount';

-- columns in total amount cleaned
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'hotel_data'
  AND table_name = 'tembo_hotel_clean'
  AND column_name = 'total_amount';
-- find table
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename ILIKE '%tembo%';

-- what's in cleaned data
SELECT total_amount
FROM hotel_data.tembo_hotel_clean
LIMIT 20;

-- Populate total amount
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'hotel_data'
  AND table_name = 'tembo_hotel'
ORDER BY ordinal_position;

-- Check booking IDs
SELECT
    c.booking_id AS clean_booking_id,
    o.booking_id AS original_booking_id,
    o.total_amount AS original_total
FROM hotel_data.tembo_hotel_clean c
JOIN hotel_data.tembo_hotel o
    ON c.booking_id = o.booking_id
LIMIT 20;


-- Populate total amount
UPDATE hotel_data.tembo_hotel_clean c
SET total_amount = NULLIF(
    REGEXP_REPLACE(o.total_amount, '[^0-9.]', '', 'g'),
    ''
)::numeric
FROM hotel_data.tembo_hotel o
WHERE c.booking_id = o.booking_id;

-- checkkkk
SELECT
    COUNT(*) AS total_rows,
    COUNT(total_amount) AS non_null_values,
    COUNT(*) - COUNT(total_amount) AS null_values,
    MIN(total_amount) AS minimum_amount,
    MAX(total_amount) AS maximum_amount,
    ROUND(AVG(total_amount), 2) AS average_amount
FROM hotel_data.tembo_hotel_clean;

SELECT *
FROM hotel_data.tembo_hotel_clean
WHERE total_amount < 0;

-- confirm the 11 null values
SELECT
    c.booking_id,
    o.total_amount
FROM hotel_data.tembo_hotel_clean c
JOIN hotel_data.tembo_hotel o
    ON c.booking_id = o.booking_id
WHERE c.total_amount IS NULL;



-- Check service used
SELECT
    service_used,
    COUNT(*) AS frequency
FROM hotel_data.tembo_hotel_clean
GROUP BY service_used
ORDER BY frequency DESC;

-- check original service used
SELECT
    booking_id,
    service_used
FROM hotel_data.tembo_hotel
LIMIT 30;

-- populate service used
UPDATE hotel_data.tembo_hotel_clean c
SET service_used = NULLIF(TRIM(o.service_used), '')
FROM hotel_data.tembo_hotel o
WHERE c.booking_id = o.booking_id;

-- Check service used
SELECT
    service_used,
    COUNT(*) AS frequency
FROM hotel_data.tembo_hotel_clean
GROUP BY service_used
ORDER BY frequency DESC;

-- Check blanks
SELECT *
FROM hotel_data.tembo_hotel_clean
WHERE service_used IS NULL
   OR TRIM(service_used) = '';


-- Service price

SELECT
    COUNT(*) AS total_rows,
    COUNT(service_price) AS non_null_values,
    MIN(service_price) AS minimum_price,
    MAX(service_price) AS maximum_price,
    ROUND(AVG(service_price),2) AS average_price
FROM hotel_data.tembo_hotel_clean;

-- original service price
SELECT
    booking_id,
    service_used,
    service_price
FROM hotel_data.tembo_hotel
LIMIT 30;

-- Populate service price
UPDATE hotel_data.tembo_hotel_clean c
SET service_price = NULLIF(
    REGEXP_REPLACE(o.service_price, '[^0-9.]', '', 'g'),
    ''
)::numeric
FROM hotel_data.tembo_hotel o
WHERE c.booking_id = o.booking_id;

-- checkkk
SELECT
    COUNT(*) AS total_rows,
    COUNT(service_price) AS non_null_values,
    COUNT(*) - COUNT(service_price) AS null_values,
    MIN(service_price) AS minimum_price,
    MAX(service_price) AS maximum_price,
    ROUND(AVG(service_price), 2) AS average_price
FROM hotel_data.tembo_hotel_clean;

-- check negative prices
SELECT *
FROM hotel_data.tembo_hotel_clean
WHERE service_price < 0;

-- Guest rating
-- check how it appears as
SELECT
    booking_id,
    guest_rating
FROM hotel_data.tembo_hotel
LIMIT 30;

-- populate
UPDATE hotel_data.tembo_hotel_clean c
SET guest_rating = NULLIF(
    REGEXP_REPLACE(o.guest_rating, '[^0-9.]', '', 'g'),
    ''
)::numeric
FROM hotel_data.tembo_hotel o
WHERE c.booking_id = o.booking_id;


-- Check
SELECT
    COUNT(*) AS total_rows,
    COUNT(guest_rating) AS non_null_values,
    COUNT(*) - COUNT(guest_rating) AS null_values,
    MIN(guest_rating) AS minimum_rating,
    MAX(guest_rating) AS maximum_rating,
    ROUND(AVG(guest_rating), 2) AS average_rating
FROM hotel_data.tembo_hotel_clean;

-- check for the invalid ratings
SELECT
    booking_id,
    guest_rating
FROM hotel_data.tembo_hotel_clean
WHERE guest_rating < 1
   OR guest_rating > 5;

-- chek original values for invalid ratings
SELECT
    c.booking_id,
    o.guest_rating
FROM hotel_data.tembo_hotel_clean c
JOIN hotel_data.tembo_hotel o
    ON c.booking_id = o.booking_id
WHERE c.guest_rating < 1
   OR c.guest_rating > 5
ORDER BY c.booking_id;

-- fix invalid
UPDATE hotel_data.tembo_hotel_clean
SET guest_rating = NULL
WHERE guest_rating < 1
   OR guest_rating > 5;

--verify
SELECT
    COUNT(*) AS total_rows,
    COUNT(guest_rating) AS valid_ratings,
    COUNT(*) - COUNT(guest_rating) AS null_ratings,
    MIN(guest_rating) AS minimum_rating,
    MAX(guest_rating) AS maximum_rating,
    ROUND(AVG(guest_rating), 2) AS average_rating
FROM hotel_data.tembo_hotel_clean;


SELECT *
FROM hotel_data.tembo_hotel_clean
WHERE guest_rating < 1
   OR guest_rating > 5;

-- FINAL CHECK
SELECT
    COUNT(*) AS total_rows,
    COUNT(total_amount) AS total_amount_valid,
    COUNT(*) - COUNT(total_amount) AS total_amount_nulls,
    COUNT(service_used) AS service_used_recorded,
    COUNT(*) - COUNT(service_used) AS service_used_nulls,
    COUNT(service_price) AS service_price_valid,
    COUNT(*) - COUNT(service_price) AS service_price_nulls,
    COUNT(guest_rating) AS guest_rating_valid,
    COUNT(*) - COUNT(guest_rating) AS guest_rating_nulls
FROM hotel_data.tembo_hotel_clean;2


SELECT *
FROM hotel_data.tembo_hotel_clean
WHERE total_amount < 0
   OR service_price < 0
   OR guest_rating < 1
   OR guest_rating > 5;

--Ensure it still has 285 bookings
SELECT COUNT(*) AS total_rows
FROM hotel_data.tembo_hotel_clean;
