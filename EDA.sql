-- Looking at the average total_score per department compared to each student's total_score
SELECT
    full_name,
    student_id,
    department,
    total_score,
    ROUND(AVG(total_score) OVER(PARTITION BY department)::NUMERIC, 2) AS avg_total_score,
    CASE
        WHEN total_score < ROUND(AVG(total_score) OVER(PARTITION BY department)::NUMERIC, 2) THEN 'Below Average'
        WHEN total_score > ROUND(AVG(total_score) OVER(PARTITION BY department)::NUMERIC, 2) THEN 'Above Average'
        ELSE 'Average'
    END AS performance_category
FROM
    student_grading
ORDER BY
    avg_total_score DESC

-- Average total_score by department
-- Insights: 
    -- all of the average scores are within 1 point of each other, the difference from the highest and lowest being 1.07
    -- It is worth looking into the reason Business scores the lowest score, with Business courses traditionally being "easier" compared to the other departments
SELECT
    department,
    ROUND(AVG(total_score)::NUMERIC, 2) AS avg_total_score
FROM
    student_grading
GROUP BY
    department
ORDER BY
    avg_total_score DESC

-- Best students in each department
-- Insights:
    -- Study hours:
        -- 3/4 students studied below the average, with Ali Williams studying 10.76 hours less than the average
        -- It could be worth looking into Ali's study habits, as she has proven to be extremely efficient, minimizing time while maximizing output
    -- Stress level:
        -- 3/4 students reported stress levels before the average, with all 3 reporting a 10 on the stress level meter
        -- Ali Williams reported a 5 on the stress level meter, 0.48 below the average
    -- Sleep hours
        -- 2 students reported above average sleep, and 2 reported below average sleep
        -- John Davis, a business major, and Ali Williams, a mathematics major, reported sleep hours 1 and 2 more than the average, respectively
WITH ranked_student AS (
    SELECT
        full_name,
        student_id,
        department,
        total_score,
        study_hours_per_week,
        stress_level,
        sleep_hours_per_night,
        ROUND(AVG(study_hours_per_week) OVER()::NUMERIC, 2) AS avg_study_hours,
        ROUND(AVG(stress_level) OVER()::NUMERIC, 2) AS avg_stress_level,
        ROUND(AVG(sleep_hours_per_night) OVER()::NUMERIC, 2) AS avg_sleep_hours,
        ROW_NUMBER() OVER(PARTITION BY department ORDER BY total_score DESC) AS rank,
        CASE
            WHEN study_hours_per_week > ROUND(AVG(study_hours_per_week) OVER()::NUMERIC, 2) THEN 'Above Average'
            WHEN study_hours_per_week < ROUND(AVG(study_hours_per_week) OVER()::NUMERIC, 2) THEN 'Below Average'
            ELSE 'Average'
        END AS study_hours,
        CASE
            WHEN stress_level > ROUND(AVG(stress_level) OVER()::NUMERIC, 2) THEN 'Above Average'
            WHEN stress_level < ROUND(AVG(stress_level) OVER()::NUMERIC, 2) THEN 'Below Average'
            ELSE 'Average'
        END AS stress_level_case,
        CASE
            WHEN sleep_hours_per_night > ROUND(AVG(sleep_hours_per_night) OVER()::NUMERIC, 2) THEN 'Above Average'
            WHEN sleep_hours_per_night < ROUND(AVG(sleep_hours_per_night) OVER()::NUMERIC, 2) THEN 'Below Average'
            Else 'Average'
        END AS sleep_hours
    FROM
        student_grading
)
SELECT
    *
FROM
    ranked_student
WHERE rank = 1

-- Average score by stress level
-- Insights:
    -- Students who report stress across all categories score within less than 1 point of each other
    -- Students who report moderate stress have a higher average total score than those who report high stress
WITH stress_level_avg AS (
    SELECT
        total_score,
        CASE
            WHEN stress_level BETWEEN 1 AND 3 THEN 'Low'
            WHEN stress_level BETWEEN 4 AND 6 THEN 'Moderate'
            WHEN stress_level BETWEEN 7 AND 10 THEN 'High'
            ELSE 'Unknown'
        END AS stress_category
    FROM
        student_grading
)
SELECT
    stress_category,
    ROUND(AVG(total_score)::NUMERIC, 2) AS avg_total_score
FROM
    stress_level_avg
GROUP BY
    stress_category


-- Students who scored above the total score average within their department
-- Insights:
    -- 2521 students reported total scores higher than their respective department average
    -- Demographic split: 488 business students, 1030 CS students, 752 Engineering students, 251 Mathematics students
WITH department_avg AS (
    SELECT
        student_id,
        full_name,
        total_score,
        department,
        ROUND(AVG(total_score) OVER (PARTITION BY department)::NUMERIC, 2) AS dept_avg_total_score
    FROM
        student_grading
)
SELECT
    student_id,
    full_name,
    department,
    total_score,
    dept_avg_total_score
FROM
    department_avg
WHERE
    total_score > dept_avg_total_score


-- Viewing the department, the number of students, the avg total score, and the maximum score
-- Insights:
    -- The average total score across all departments are within 1 point of each other
    -- Business had the smallest avg_total_score at 74.50
    -- Mathematics had the largest avg_total_score at 75.57
    -- It could be worth omitting Mathematics in this analysis. Despite still have a large pool of 503 students, it is half of the next smallest pool, which is Business
WITH student_avg AS (
    SELECT
        student_id,
        department,
        total_score,
        MAX(total_score) OVER(PARTITION BY department) AS max_score
    FROM
        student_grading
)
SELECT
    department,
    COUNT(*) AS num_students,
    ROUND(AVG(total_score)::NUMERIC, 2) AS avg_total_score,
    MAX(max_score) AS max_score
FROM
    student_avg
GROUP BY
    department

-- Study habits: performance by study hours range
-- Insights:
    -- The least amount of students studied between 5 and 10 hours per week, but scored the highest Average Total Score at 75.58
    -- The most amount of students studied for 20+ hours per week, and scored the lowest Average Total Score at exactly 75.00
    -- No students studied for less than 5 hours per week
WITH study_brackets AS (
    SELECT
        total_score,
        CASE
            WHEN study_hours_per_week < 5 THEN '0-4 Hours'
            WHEN study_hours_per_week BETWEEN 5 AND 10 THEN '5-10 Hours'
            WHEN study_hours_per_week BETWEEN 11 AND 20 THEN '11-20 Hours'
            ELSE '20+ Hours'
        END AS study_hours  
    FROM
        student_grading
)
SELECT
    study_hours,
    COUNT(*) AS num_students,
    ROUND(AVG(total_score)::NUMERIC, 2) AS avg_total_score
FROM
    study_brackets
GROUP BY
    study_hours
ORDER BY
    avg_total_score DESC

-- Is internet access related to performance
-- Insights
    -- An overwhelming majority of students have internet access, with 8.7x more students having internet access
    -- Despite having no internet access, 
SELECT
    internet_access_at_home,
    COUNT(*) AS num_students,
    ROUND(AVG(total_score)::NUMERIC, 2) AS avg_total_score
FROM
    student_grading
GROUP BY
    internet_access_at_home


-- Counting the amount of grades per department
SELECT
    department,
    grade,
    COUNT(*) AS grade_count
FROM
    student_grading
GROUP BY
    department,
    grade
ORDER BY
    grade_count DESC
