MAX(do.attendance) 
    - COUNT(CASE WHEN at.name = '기타' THEN 1 END) 
    - FLOOR((COUNT(CASE WHEN at.name = '지각' THEN 1 END) + COUNT(CASE WHEN at.name = '조퇴' THEN 1 END)) * 0.5) AS 출결,
     MAX(CASE WHEN er.exam_type_id = 1 THEN ER.score * (written/100) END) AS 필기,
    MAX(CASE WHEN er.exam_type_id = 2 THEN ER.score * (practical/100) END) AS 실기,

WHEN dropout_date IS NOT NULL THEN

-----------------------------------------------------------------------------------------------------------------------------------------
-- 출결, 필기, 실기 배점, 성적 등록 여부 등이 출력
-- 개설 과정
CREATE OR REPLACE VIEW vOpenSubjectsByCurriculum AS
SELECT
    
    t.teacher_id AS 교사번호,
    oc.open_curriculum_id AS 개설과정번호,
    oc.title AS 개설과정명,
    oc.startdate AS 과정시작일,
    oc.enddate AS 과정종료일,
    r.room_id AS 강의실,
    os.title AS 개설과목명,
    os.startdate AS 개설과목시작일,
    os.enddate AS 개설과목종료일,
    b.title AS 교재명,
    os.open_subject_id AS 개설과목번호,
    CASE 
        WHEN er.score IS NOT NULL THEN '등록' ELSE '미등록' END AS 성적등록여부,
    CASE 
        WHEN er.score IS NULL THEN NULL 
        ELSE do.attendance 
    END AS 출결배점,

    CASE 
        WHEN er.score IS NULL THEN NULL 
        ELSE do.written 
    END AS 필기배점,

    CASE 
        WHEN er.score IS NULL THEN NULL 
        ELSE do.practical 
    END AS 실기배점
    
FROM 
    mOpenCurriculum oc
INNER JOIN mRoom r ON oc.room_id = r.room_id
INNER JOIN mTeacher t ON oc.teacher_id = t.teacher_id
INNER JOIN mOpenCurriSubject ocs ON oc.open_curriculum_id = ocs.open_curriculum_id
INNER JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id
INNER JOIN mOpensubjectBook ob ON os.open_subject_id = ob.open_subject_id 
INNER JOIN mBook b ON ob.book_id = b.book_id
INNER JOIN mExam e ON ocs.open_curriculum_subject_id = e.open_curriculum_subject_id
INNER JOIN mExamResult er ON e.exam_id = er.exam_id
INNER JOIN distributionOfScores do ON er.exam_id = do.exam_id
INNER JOIN mTeacher t ON oc.teacher_id = t.teacher_id;

select 교사번호, 개설과정번호, 개설과정명, 과정시작일, 과정종료일, 강의실, 개설과목명, 개설과목시작일, 개설과목종료일, 교재명, 개설과목번호, 성적등록여부, 출결배점, 필기배점, 실기배점 from vOpenSubjectsByCurriculum;





----------------------------------------------------------------------------------------------------------------
-- 과목목록 출력시 > 과목번호, 과정명, 과정기간, 강의실, 과목명, 과목기간, 교재명, 출결, 필기, 실기 배점, 성적 등록여부
drop view vScoresByStudent;
CREATE OR REPLACE VIEW vScoresByStudent AS
SELECT 
    
    os.open_subject_id AS 과목번호,
    oc.title AS 개설과정명,
    MAX(oc.startdate) AS 과정시작일,
    MAX(oc.enddate) AS 과정종료일, 
    MAX(r.room_id) AS 강의실번호,
    os.title AS 개설과목명,
    MAX(os.startdate) AS 개설과목시작일,
    MAX(os.enddate) AS 개설과목종료일,
    
    do.attendance AS 출결 배점,
    do.written AS 필기 배점,
    do.practical AS 실기 배점,
    CASE 
        WHEN er.score IS NULL THEN '미등록' END AS 성적 등록 여부
FROM mExamResult er
INNER JOIN mStudent s ON er.student_id = s.student_id
INNER JOIN mExam e ON er.exam_id = e.exam_id
INNER JOIN mOpenCurriSubject ocs ON e.open_curriculum_subject_id = ocs.open_curriculum_subject_id
INNER JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id
INNER JOIN mOpenCurriculum oc ON ocs.open_curriculum_id = oc.open_curriculum_id
INNER JOIN mRoom r ON oc.room_id = r.room_id
INNER JOIN mTeacher t ON oc.teacher_id = t.teacher_id
INNER JOIN distributionOfScores do ON er.exam_id = do.exam_id
INNER JOIN mTimeKeeping tk ON s.student_id = tk.student_id
INNER JOIN mAttendanceType at ON tk.attendance_type_id = at.attendance_type_id
GROUP BY s.name, s.jumin, oc.title, os.title, t.name
ORDER BY oc.title, os.title, s.name;

select * from vScoresByStudent;



drop view vScoresBySubject;
-------------------------------------------------------------------------------
-- 특정과목을 과목 번호로 선택시 > 교육생 정보, 및 성적이 출결, 필기, 실기 점수로 구분
CREATE OR REPLACE VIEW vScoresBySubject AS
SELECT 
    
    ocs.open_curriculum_subject_id as 과목번호,
    s.name AS 교육생이름,
    s.tel AS 전화번호,
    case when s.dropout_date IS NOT NULL THEN s.dropout_date
         WHEN s.dropout_date IS NULL THEN s.completion_date END AS 수료일,
    CASE WHEN s.dropout_date IS NOT NULL THEN '중도탈락'
        WHEN s.completion_date <= SYSDATE THEN '수료'
        ELSE '수강중'
    END AS 수료여부,    
    CASE 
        WHEN s.dropout_date IS NOT NULL THEN null  -- 중도 탈락자는 출결 0
        ELSE 
            COALESCE(MAX(do.attendance), 0) 
            - SUM(CASE WHEN at.name = '기타' THEN 1 ELSE 0 END) 
            - FLOOR((SUM(CASE WHEN at.name = '지각' THEN 1 ELSE 0 END) 
            + SUM(CASE WHEN at.name = '조퇴' THEN 1 ELSE 0 END)) * 0.5)
    END AS 출결,
    MAX(CASE WHEN s.dropout_date IS NOT NULL THEN null WHEN er.exam_type_id = 1 THEN er.score END) AS 필기,
    MAX(CASE WHEN s.dropout_date IS NOT NULL THEN null WHEN er.exam_type_id = 2 THEN er.score END) AS 실기
FROM 
    mStudent s
LEFT JOIN mTimeKeeping tk ON s.student_id = tk.student_id    
LEFT JOIN mAttendanceType at ON tk.attendance_Type_id = at.attendance_Type_id
LEFT JOIN mExamResult er ON er.student_id = s.student_id
LEFT JOIN mExamType et ON er.exam_type_id = et.exam_type_id
LEFT JOIN mExam e ON er.exam_id = e.exam_id
LEFT JOIN distributionOfScores do ON e.exam_id = do.exam_id
LEFT JOIN mOpenCurriSubject ocs ON e.open_curriculum_subject_id = ocs.open_curriculum_subject_id
LEFT JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id

GROUP BY ocs.open_curriculum_subject_id, os.open_subject_id, s.name, s.tel, s.completion_date, s.dropout_date
ORDER BY ocs.open_curriculum_subject_id;

select 교육생이름, 전화번호, 수료일, 수료여부, 출결, 필기, 실기 from vScoresBySubject; 


--oc.open_curriculum_id as 과정번호,
--LEFT JOIN mOpenCurriculum oc ON ocs.open_curriculum_id = oc.open_curriculum_id
--LEFT JOIN mOpenCurriStudent oct ON oct.student_id = s.student_id
--oc.open_curriculum_id,