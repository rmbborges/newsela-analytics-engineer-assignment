-- -----------------------------------------------------------------------------
-- Query 3D: Title and Length of Code
-- -----------------------------------------------------------------------------
WITH 
question_analysis AS (
    SELECT
        id AS question_id,
        answer_count,
        accepted_answer_id IS NOT NULL AS has_accepted_answer,
        CASE
            WHEN REGEXP_CONTAINS(LOWER(title), r'^how') THEN '1. How-to'
            WHEN REGEXP_CONTAINS(LOWER(title), r'^why') THEN '2. Why'
            WHEN REGEXP_CONTAINS(LOWER(title), r'^what') THEN '3. What'
            WHEN REGEXP_CONTAINS(LOWER(title), r'error|exception|not working|fails|failed|broken|issue') THEN
    '5. Error/Problem'
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
        answer_count,
        has_accepted_answer,
        body_length,
        title_pattern
),
with_buckets AS (
    SELECT
        question_id,
        answer_count,
        has_accepted_answer,
        title_pattern,
        code_char_length,
        body_length,
        SAFE_DIVIDE(
            code_char_length,
            body_length
        ) AS code_pct,
        CASE
            WHEN SAFE_DIVIDE(code_char_length, body_length) = 0 THEN '0. No code'
            WHEN SAFE_DIVIDE(code_char_length, body_length) < 0.05 THEN '1. Low (0-5%)'
            WHEN SAFE_DIVIDE(code_char_length, body_length) < 0.20 THEN '2. Moderate (5-20%)'
            ELSE '3. High (20%+)'
        END AS code_pct_bucket
    FROM 
        question_analysis
)
SELECT
    title_pattern,
    code_pct_bucket,
    COUNT(*) AS total_questions,
    SAFE_DIVIDE(
        COUNTIF(answer_count > 0), 
        COUNT(*)
    ) AS answer_rate,
    SAFE_DIVIDE(
        COUNTIF(has_accepted_answer), 
        COUNT(*)
    ) AS accepted_answer_rate
FROM 
    with_buckets
GROUP BY 
    title_pattern, 
    code_pct_bucket
HAVING 
    total_questions >= 1000
ORDER BY
    accepted_answer_rate DESC