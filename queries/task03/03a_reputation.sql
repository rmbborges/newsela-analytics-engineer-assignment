-- -----------------------------------------------------------------------------
-- Query 3A: Reputation
-- -----------------------------------------------------------------------------
WITH 
user_experience AS (
    SELECT
        post_questions.id AS question_id,
        post_questions.answer_count,
        post_questions.accepted_answer_id IS NOT NULL has_accepted_answer,
        user.reputation AS user_reputation,
        DATE_DIFF(post_questions.creation_date, user.creation_date, DAY) AS account_age_days,
        CASE
            WHEN user.reputation < 10 THEN '1. New (< 10)'
            WHEN user.reputation < 100 THEN '2. Beginner (10-99)'
            WHEN user.reputation < 500 THEN '3. Intermediate (100-499)'
            WHEN user.reputation < 1000 THEN '4. Established (500-999)'
            WHEN user.reputation < 5000 THEN '5. Experienced (1K-5K)'
            ELSE '6. Expert (5K+)'
        END AS reputation_bucket,
        CASE
            WHEN DATE_DIFF(post_questions.creation_date, user.creation_date, DAY) = 0 THEN '1. First day'
            WHEN DATE_DIFF(post_questions.creation_date, user.creation_date, DAY) < 7 THEN '2. First week'
            WHEN DATE_DIFF(post_questions.creation_date, user.creation_date, DAY) < 30 THEN '3. First month'
            WHEN DATE_DIFF(post_questions.creation_date, user.creation_date, DAY) < 365 THEN '4. First year'
            ELSE '5. Veteran (1+ year)'
        END AS account_age_bucket
    FROM 
        `bigquery-public-data.stackoverflow.posts_questions` AS post_questions
    JOIN 
        `bigquery-public-data.stackoverflow.users` AS user
        ON post_questions.owner_user_id = user.id
    WHERE 
        post_questions.creation_date >= '2013-01-01'
)
SELECT
    account_age_bucket,
    reputation_bucket,
    COUNT(*) AS total_questions,
    SAFE_DIVIDE(COUNTIF(answer_count > 0), COUNT(*)) AS answer_rate,
    SAFE_DIVIDE(COUNTIF(has_accepted_answer), COUNT(*)) AS accepted_answer_rate
FROM 
    user_experience
GROUP BY 
    account_age_bucket,
    reputation_bucket
HAVING 
    total_questions >= 1000
ORDER BY 
    accepted_answer_rate DESC
