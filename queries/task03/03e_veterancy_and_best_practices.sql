-- -----------------------------------------------------------------------------
-- Query 3E: Veterancy and Best Practices
-- -----------------------------------------------------------------------------
WITH
question_analysis AS (
    SELECT
        id AS question_id,
        owner_user_id,
        creation_date,
        CASE
            WHEN REGEXP_CONTAINS(LOWER(title), r'^how') THEN '1. How-to'
            WHEN REGEXP_CONTAINS(LOWER(title), r'^why') THEN '2. Why'
            WHEN REGEXP_CONTAINS(LOWER(title), r'^what') THEN '3. What'
            WHEN REGEXP_CONTAINS(LOWER(title), r'error|exception|not working|fails|failed|broken|issue') THEN '5. Error/Problem'
            ELSE '6. Other'
        END AS title_pattern,
        LENGTH(body) AS body_length,
        COALESCE(SUM(LENGTH(code)), 0) AS code_char_length
    FROM
        `bigquery-public-data.stackoverflow.posts_questions`
    LEFT JOIN
        UNNEST(REGEXP_EXTRACT_ALL(body, r'<code>(.*?)</code>')) AS code
    WHERE
        creation_date >= '2013-01-01'
    GROUP BY
        question_id,
        owner_user_id,
        creation_date,
        title_pattern,
        body_length
),
questions_numbered AS (
    SELECT
        question_id,
        owner_user_id,
        creation_date,
        title_pattern,
        body_length,
        code_char_length,
        ROW_NUMBER() OVER (
            PARTITION BY owner_user_id
            ORDER BY creation_date
        ) - 1 AS previous_questions_count
    FROM
        question_analysis
),
with_buckets AS (
    SELECT
        question_id,
        title_pattern,
        CASE
            WHEN SAFE_DIVIDE(code_char_length, body_length) = 0 THEN '0. No code'
            WHEN SAFE_DIVIDE(code_char_length, body_length) < 0.05 THEN '1. Low (0-5%)'
            WHEN SAFE_DIVIDE(code_char_length, body_length) < 0.20 THEN '2. Moderate (5-20%)'
            ELSE '3. High (20%+)'
        END AS code_pct_bucket,
        CASE
            WHEN previous_questions_count = 0 THEN '1. First question'
            WHEN previous_questions_count BETWEEN 1 AND 10 THEN '2. 1-10 questions'
            WHEN previous_questions_count BETWEEN 11 AND 50 THEN '3. 11-50 questions'
            ELSE '4. 50+ questions'
        END AS questions_experience_bucket
    FROM
        questions_numbered
)
SELECT
    questions_experience_bucket,
    COUNT(*) AS total_questions,
    -- Code distribution
    SAFE_DIVIDE(COUNTIF(code_pct_bucket = '0. No code'), COUNT(*)) AS pct_no_code,
    SAFE_DIVIDE(COUNTIF(code_pct_bucket = '1. Low (0-5%)'), COUNT(*)) AS pct_low_code,
    SAFE_DIVIDE(COUNTIF(code_pct_bucket = '2. Moderate (5-20%)'), COUNT(*)) AS pct_moderate_code,
    SAFE_DIVIDE(COUNTIF(code_pct_bucket = '3. High (20%+)'), COUNT(*)) AS pct_high_code,
    -- Title distribution
    SAFE_DIVIDE(COUNTIF(title_pattern = '1. How-to'), COUNT(*)) AS pct_howto,
    SAFE_DIVIDE(COUNTIF(title_pattern = '2. Why'), COUNT(*)) AS pct_why,
    SAFE_DIVIDE(COUNTIF(title_pattern = '3. What'), COUNT(*)) AS pct_what,
    SAFE_DIVIDE(COUNTIF(title_pattern = '5. Error/Problem'), COUNT(*)) AS pct_error,
    SAFE_DIVIDE(COUNTIF(title_pattern = '6. Other'), COUNT(*)) AS pct_other
FROM
    with_buckets
GROUP BY
    questions_experience_bucket
HAVING
    total_questions >= 1000
ORDER BY
    questions_experience_bucket
