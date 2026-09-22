-- LearnAI SQL Business Analysis
-- MySQL Workbench
-- Run LearnAI_Dummy_Dataset.sql first, then execute these queries one by one.

USE learnai;

-- ============================================================
-- Q1. OVERALL PLATFORM HEALTH
-- Why: Establish a simple baseline before deeper analysis.
-- Gives: total enrollments, unique learners, status counts and rates.
-- ============================================================
SELECT
    COUNT(*) AS total_enrollments,
    COUNT(DISTINCT learner_id) AS unique_learners,
    SUM(completion_status = 'Completed') AS completed_enrollments,
    SUM(completion_status = 'Active') AS active_enrollments,
    SUM(completion_status = 'Dropped') AS dropped_enrollments,
    ROUND(100 * SUM(completion_status = 'Completed') / COUNT(*), 2) AS completion_rate_pct,
    ROUND(100 * SUM(completion_status = 'Dropped') / COUNT(*), 2) AS dropout_rate_pct
FROM enrollments;

-- ============================================================
-- Q2. PROGRAM PARTICIPATION AND COMPLETION
-- Why: The problem says programs behave differently, so compare them.
-- Gives: enrollment volume, average sessions, progress and completion rate.
-- ============================================================
SELECT
    p.program_name,
    COUNT(e.enrollment_id) AS enrollments,
    ROUND(AVG(e.sessions_completed), 1) AS avg_sessions,
    ROUND(AVG(e.progress_pct), 1) AS avg_progress_pct,
    ROUND(100 * SUM(e.completion_status = 'Completed') / COUNT(*), 2)
        AS completion_rate_pct
FROM programs p
JOIN enrollments e ON p.program_id = e.program_id
GROUP BY p.program_id, p.program_name
ORDER BY completion_rate_pct DESC;

-- ============================================================
-- Q3. POSSIBLE WEAK ENGAGEMENT
-- Why: Find learners who may need attention early.
-- Dummy threshold: fewer than 7 sessions OR progress below 50%.
-- Note: A real company should validate these thresholds with history.
-- ============================================================
SELECT
    l.learner_name,
    p.program_name,
    e.sessions_completed,
    e.progress_pct,
    e.completion_status,
    e.last_activity_date
FROM enrollments e
JOIN learners l ON e.learner_id = l.learner_id
JOIN programs p ON e.program_id = p.program_id
WHERE e.sessions_completed < 7
   OR e.progress_pct < 50
ORDER BY e.progress_pct ASC;

-- ============================================================
-- Q4. PROGRAM LEARNING OUTCOMES
-- Why: Completion alone may not show learning outcome differences.
-- Gives: average hours, progress and final score by program.
-- ============================================================
SELECT
    p.program_name,
    ROUND(AVG(e.learning_hours), 1) AS avg_learning_hours,
    ROUND(AVG(e.progress_pct), 1) AS avg_progress_pct,
    ROUND(AVG(e.final_score), 2) AS avg_final_score
FROM programs p
JOIN enrollments e ON p.program_id = e.program_id
GROUP BY p.program_id, p.program_name
ORDER BY avg_final_score DESC;

-- ============================================================
-- Q5. ENGAGEMENT VS OUTCOMES
-- Why: Test whether more participation corresponds to better outcomes.
-- Gives: average progress and score for low/medium/high engagement.
-- ============================================================
SELECT
    CASE
        WHEN sessions_completed < 7 THEN 'Low engagement'
        WHEN sessions_completed BETWEEN 7 AND 15 THEN 'Medium engagement'
        ELSE 'High engagement'
    END AS engagement_level,
    COUNT(*) AS enrollments,
    ROUND(AVG(progress_pct), 1) AS avg_progress_pct,
    ROUND(AVG(final_score), 2) AS avg_final_score
FROM enrollments
GROUP BY
    CASE
        WHEN sessions_completed < 7 THEN 'Low engagement'
        WHEN sessions_completed BETWEEN 7 AND 15 THEN 'Medium engagement'
        ELSE 'High engagement'
    END
ORDER BY
    CASE
        WHEN sessions_completed < 7 THEN 1
        WHEN sessions_completed BETWEEN 7 AND 15 THEN 2
        ELSE 3
    END;

-- ============================================================
-- Q6. ADDITIONAL BUSINESS QUESTION
-- Why: Explore whether experience level is associated with dropout.
-- Gives: dropout rate, sessions and progress by experience level.
-- ============================================================
SELECT
    l.experience_level,
    COUNT(*) AS enrollments,
    SUM(e.completion_status = 'Completed') AS completed,
    SUM(e.completion_status = 'Dropped') AS dropped,
    ROUND(100 * SUM(e.completion_status = 'Dropped') / COUNT(*), 2)
        AS dropout_rate_pct,
    ROUND(AVG(e.sessions_completed), 1) AS avg_sessions,
    ROUND(AVG(e.progress_pct), 1) AS avg_progress_pct
FROM learners l
JOIN enrollments e ON l.learner_id = e.learner_id
GROUP BY l.experience_level
ORDER BY dropout_rate_pct DESC;

-- ============================================================
-- Q7. HIGH ENGAGEMENT BUT LOWER OUTCOME
-- Why: Averages can hide individual exceptions.
-- Finds highly engaged learners whose score is below the overall score average.
-- ============================================================
SELECT
    l.learner_name,
    p.program_name,
    e.sessions_completed,
    e.learning_hours,
    e.final_score
FROM enrollments e
JOIN learners l ON e.learner_id = l.learner_id
JOIN programs p ON e.program_id = p.program_id
WHERE e.sessions_completed >= 15
  AND e.final_score IS NOT NULL
  AND e.final_score < (
      SELECT AVG(final_score)
      FROM enrollments
      WHERE final_score IS NOT NULL
  )
ORDER BY e.final_score ASC;

-- ============================================================
-- Q8. PROGRAM RANKING
-- Why: Turn program completion into a clear comparison for review.
-- Demonstrates a CTE and DENSE_RANK without changing the business question.
-- ============================================================
WITH program_metrics AS (
    SELECT
        p.program_id,
        p.program_name,
        ROUND(100 * SUM(e.completion_status = 'Completed') / COUNT(*), 2)
            AS completion_rate_pct
    FROM programs p
    JOIN enrollments e ON p.program_id = e.program_id
    GROUP BY p.program_id, p.program_name
)
SELECT
    program_name,
    completion_rate_pct,
    DENSE_RANK() OVER (ORDER BY completion_rate_pct DESC) AS completion_rank
FROM program_metrics
ORDER BY completion_rank, program_name;
