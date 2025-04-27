-- 출결 관리 및 출결 조회
-- 모든 교육생의 출결을 조회

drop view vAttendanceByDate;
--출결 현황을 기간별(년, 월, 일) 조회할 수 있어야 한다.
CREATE OR REPLACE VIEW vAttendanceByDate AS
SELECT 
    EXTRACT(YEAR FROM tk.clock_in) AS 출결년도,
    EXTRACT(MONTH FROM tk.clock_in) AS 출결월,
    EXTRACT(DAY FROM tk.clock_in) AS 출결일,
    st.student_id AS 교육생번호,
    st.name AS 교육생이름,
    tk.clock_in AS 입실시간,
    tk.clock_out AS 퇴실시간,
    NVL(at.name, '중도탈락') AS 근태유형
FROM mTimeKeeping tk
JOIN mStudent st ON tk.student_id = st.student_id
LEFT JOIN mAttendanceType at ON tk.attendance_type_id = at.attendance_type_id;

-- 2025년 전체 출결 조회
SELECT * FROM vAttendanceByDate WHERE 출결년도 = 2025;

-- 2025년 2월 출결 조회
SELECT * FROM vAttendanceByDate WHERE 출결년도 = 2025 AND 출결월 = 2;

-- 2025년 2월 5일 출결 조회
SELECT * FROM vAttendanceByDate WHERE 출결년도 = 2025 AND 출결월 = 2 AND 출결일 = 5;




drop view vAttendanceByOpenCurriculum;
-- (특정 과정, 특정 인원) 출결 현황을 조회할 수 있어야 한다.
CREATE OR REPLACE VIEW vAttendanceByOpenCurriculum AS
SELECT 
    oc.open_curriculum_id AS 개설과정번호, 
    st.student_id AS 교육생번호,
    st.name AS 교육생이름,
    oc.title AS 개설과정명,
    oc.startdate AS 과정시작일,
    oc.enddate AS 과정종료일,
    tk.clock_in AS 입실시간,
    tk.clock_out AS 퇴실시간,
    NVL(at.name, '중도탈락') AS 근태유형
    
FROM mStudent st
JOIN mOpenCurriStudent ocs ON st.student_id = ocs.student_id
JOIN mOpenCurriculum oc ON ocs.open_curriculum_id = oc.open_curriculum_id
LEFT JOIN mTimeKeeping tk ON st.student_id = tk.student_id
LEFT JOIN mAttendanceType at ON tk.attendance_type_id = at.attendance_type_id;

-- 특정 개설과정 번호(예: 12번) 출결 조회
SELECT * FROM vAttendanceByOpenCurriculum WHERE 개설과정번호 = 12;

-- 특정 개설 과정(12번) & 특정 교육생(정수) 출결 조회
SELECT * FROM vAttendanceByOpenCurriculum 
WHERE 개설과정번호 = 12 AND 교육생이름 = '정수하';

-- 특정 개설 과정(12번)에서 2024년 1월~12월 동안 출결 조회
SELECT * FROM vAttendanceByOpenCurriculum 
WHERE 개설과정번호 = 12
AND 입실시간 BETWEEN TO_DATE('2025-01-19', 'YYYY-MM-DD') AND TO_DATE('2025-2-10', 'YYYY-MM-DD');

-- 2024년 데이터는 안들어가는건가?
-- 입실시간, 퇴실시간이 년월일로 데이터가 들어가있는건가?

--모든 출결 조회는 근태 상황을 구분할 수 있어야 한다.(정상, 지각, 조퇴, 외출, 병가, 기타)


drop view vAttendanceDetails;
--최종
CREATE OR REPLACE VIEW vAttendanceDetails AS
SELECT 
    EXTRACT(YEAR FROM tk.clock_in) AS 출결년도,
    EXTRACT(MONTH FROM tk.clock_in) AS 출결월,
    EXTRACT(DAY FROM tk.clock_in) AS 출결일,
    oc.open_curriculum_id AS 개설과정번호,
    oc.title AS 개설과정명,
    st.student_id AS 교육생번호,
    st.name AS 교육생이름,
    tk.clock_in AS 입실시간,
    tk.clock_out AS 퇴실시간,
    NVL(at.name, '미등록') AS 근태유형
FROM mTimeKeeping tk
JOIN mStudent st ON tk.student_id = st.student_id
JOIN mOpenCurriStudent ocs ON st.student_id = ocs.student_id
JOIN mOpenCurriculum oc ON ocs.open_curriculum_id = oc.open_curriculum_id
LEFT JOIN mAttendanceType at ON tk.attendance_type_id = at.attendance_type_id;

---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vAttendanceDetails AS
SELECT 
    
    EXTRACT(YEAR FROM tk.clock_in) AS 출결년도,
    EXTRACT(MONTH FROM tk.clock_in) AS 출결월,
    EXTRACT(DAY FROM tk.clock_in) AS 출결일,
    T.teacher_id AS 교사번호,
    oc.open_curriculum_id AS 과정번호,
    oc.title AS 과정명,
    st.student_id AS 교육생번호,
    st.name AS 교육생이름,
    tk.clock_in AS 입실,
    tk.clock_out AS 퇴실,
    at.name AS 근태유형
FROM mTimeKeeping tk
RIGHT JOIN mStudent st ON tk.student_id = st.student_id
RIGHT JOIN mOpenCurriStudent ocs ON st.student_id = ocs.student_id
RIGHT JOIN mOpenCurriculum oc ON ocs.open_curriculum_id = oc.open_curriculum_id
RIGHT JOIN mAttendanceType at ON tk.attendance_type_id = at.attendance_type_id
RIGHT JOIN mTeacher t ON oc.teacher_id = T.teacher_id;


-- 2025년 전체 출결 조회
SELECT 교사번호, 과정번호, 과정명, 출결년도, 출결월, 출결일, 교육생번호, 교육생이름, 입실, 퇴실, 근태유형 
FROM vAttendanceDetails 
WHERE 교사번호 = 7 
AND 출결년도 = 2025;

-- 2025년 1월 출결 조회
SELECT 교사번호, 과정번호, 과정명, 출결년도, 출결월, 출결일, 교육생번호, 교육생이름, 입실, 퇴실, 근태유형
FROM vAttendanceDetails
WHERE 교사번호 = 7 
AND 출결년도 = 2025 
AND 출결월 = 1;

-- 특정 개설 과정(개설과정번호: 11)의 모든 교육생 출결 조회
SELECT 교사번호, 과정번호, 과정명, 출결년도, 출결월, 출결일, 교육생번호, 교육생이름, 입실, 퇴실, 근태유형  
    FROM vAttendanceDetails 
    WHERE 교사번호 = 7 
    AND 과정번호 = 11;

-- 특정 개설 과정(12) + 특정 교육생(교육생이름: 이태영) 출결 조회
SELECT 교사번호, 과정번호, 과정명, 출결년도, 출결월, 출결일, 교육생번호, 교육생이름, 입실, 퇴실, 근태유형
FROM vAttendanceDetails 
WHERE 교사번호 = 7 
AND 개설과정번호 = 12 
AND 교육생이름 = '이태영';

-- 특정 근태 유형(지각)만 조회 (2025년 1월)
SELECT 교사번호, 과정번호, 과정명, 출결년도, 출결월, 출결일, 교육생번호, 교육생이름, 입실, 퇴실, 근태유형
FROM vAttendanceDetails 
WHERE 교사번호 = 7
AND 근태유형 = '지각'
AND 출결년도 = 2025 
AND 출결월 = 1;

----------------------------------------------------------------------------출결
DROP VIEW VTEST;
CREATE OR REPLACE VIEW vtest AS
SELECT 
    oc.open_curriculum_id AS d,
    oc.title AS 개설과정명,
    oc.startdate AS 과정시작일,
    oc.enddate AS 과정종료일,
    os.title AS 개설과목명,
    t.name AS 교사명,
    CASE 
        WHEN er.score IS NOT NULL THEN '등록' 
        ELSE '미등록' 
    END AS 성적등록여부,
    CASE 
        WHEN e.questions IS NOT NULL THEN '등록' 
        ELSE '미등록' 
    END AS 시험문제파일등록여부
FROM mOpenCurriculum oc
JOIN mOpenCurriSubject ocs ON oc.open_curriculum_id = ocs.open_curriculum_id
JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id
JOIN mTeacher t ON oc.teacher_id = t.teacher_id
LEFT JOIN mExam e ON ocs.open_curriculum_subject_id = e.open_curriculum_subject_id
LEFT JOIN mExamResult er ON e.exam_id = er.exam_id;

select * from vtest WHERE d = :개설과정번호;




