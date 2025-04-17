-- Checking the data
SELECT *
FROM student_grading


-- Filling in null values
UPDATE student_grading
SET gender = 'Male'
WHERE gender IS NULL

UPDATE student_grading
SET age = 21
WHERE age = '21'

UPDATE student_grading
SET department = 'Other'
WHERE department IS NULL

UPDATE student_grading -- Setting null values to the average
SET attendance_percent = 75
WHERE attendance_percent = '75'

UPDATE student_grading -- Setting null values to the average
SET midterm_score = 70
WHERE midterm_score = '70'

UPDATE student_grading
SET final_score = 69
WHERE final_score = '69'

UPDATE student_grading
SET assignments_avg = 74
WHERE assignments_avg = '74'

UPDATE student_grading
SET quizzes_avg = 75
WHERE quizzes_avg = '75'

UPDATE student_grading
SET participation_score = 5
WHERE participation_score = '5'

UPDATE student_grading
SET projects_score = 75
WHERE projects_score = '75'

UPDATE student_grading
SET total_score = 75
WHERE total_score = '75'

UPDATE student_grading
SET study_hours_per_week = 17
WHERE study_hours_per_week = '17'

UPDATE student_grading
SET stress_level = 5
WHERE stress_level = '5'

UPDATE student_grading
SET sleep_hours_per_night = 6
WHERE sleep_hours_per_night = '6'

UPDATE student_grading
SET grade = 'C'
WHERE grade IS NULL

UPDATE student_grading
SET extracurricular_activities = 'No'
WHERE extracurricular_activities IS NULL

UPDATE student_grading
SET internet_access_at_home = 'No'
WHERE internet_access_at_home IS NULL

UPDATE student_grading
SET parent_education_level = 'None'
WHERE parent_education_level IS NULL

UPDATE student_grading
SET family_income_level = 'Medium'
WHERE family_income_level IS NULL


-- Checking for duplicate student IDs
SELECT
    student_id,
    COUNT(*)
FROM student_grading
GROUP BY student_id
HAVING COUNT(*) > 1

-- Adding a full name column and deleting the first_name and last_name column
ALTER TABLE student_grading
ADD COLUMN full_name TEXT

UPDATE student_grading
SET full_name = first_name || ' ' || last_name

ALTER TABLE student_grading
DROP COLUMN first_name,
DROP COLUMN last_name

