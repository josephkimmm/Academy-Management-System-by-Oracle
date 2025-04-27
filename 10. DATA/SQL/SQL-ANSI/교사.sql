--교육생 정보(교육생 이름, 전화번호, 등록일, 수료 or 중도탈락)
CREATE OR REPLACE VIEW vStudent
AS
SELECT st.name 교육생명,
	st.jumin 주민번호뒷자리,
        st.tel 연락처, 
        st.registration_date 등록일,
        COUNT(st.student_id) OVER(PARTITION BY c.title) AS 교육생수,
        case
            WHEN st.dropout_date IS NOT NULL THEN '중도탈락'
            WHEN st.completion_date IS NOT NULL THEN '수료'
            ELSE '수료 중'
        END 수료여부,
        ocst.open_curriculum_id 개설과정번호
    FROM mCurriculum c
        INNER JOIN mOpenCurriculum oc
            ON c.curriculum_id = oc.curriculum_id
                INNER JOIN mOpenCurriStudent ocst
                    ON oc.open_curriculum_id = ocst.open_curriculum_id
                        INNER JOIN mStudent st
                            ON ocst.student_id = st.student_id; 


-- 교재명까지
CREATE OR REPLACE VIEW vSubAndCurriAndBook
AS
SELECT s.subject_id 과목번호, 
        c.title 과정명, 
        oc.startdate 과정시작일, 
        oc.enddate 과정종료일, 
        oc.room_id 강의실번호, 
        s.title 과목명, 
        os.startdate 과목시작일, 
        os.enddate 과목종료일, 
        b.title 교재명,
        t.jumin 교사비밀번호,
        t.name 교사이름,
        CASE
            WHEN sysdate >= oc.enddate THEN '강의종료'
            WHEN sysdate < oc.enddate THEN '강의중'
            WHEN sysdate < oc.startdate THEN '강의예정'
        END 강의여부,
        ocs.open_curriculum_subject_id 개설과정중간번호,
        oc.open_curriculum_id 개설과정번호
    FROM mSubject s
        INNER JOIN mOpenSubject os
            ON s.subject_id = os.subject_id
                INNER JOIN mOpenCurriSubject ocs
                    ON os.open_subject_id = ocs.open_subject_id
                        INNER JOIN mOpenCurriculum oc
                            ON ocs.open_curriculum_id = oc.open_curriculum_id
                                INNER JOIN mCurriculum c
                                    ON oc.curriculum_id = c.curriculum_id
                                        INNER JOIN mOpensubjectBook obs
                                            ON os.open_subject_id = obs.open_subject_id
                                                INNER JOIN mBook b
                                                    ON obs.book_id = b.book_id
                                                        RIGHT JOIN mTeacher t
                                                            ON t.teacher_id = oc.teacher_id; 
   
select * from vSubAndCurriAndBook;

-- 배점                              
CREATE OR REPLACE VIEW vDistribution
AS
SELECT d.attendance 출결배점,
        d.written 필기배점,
        d.practical 실기배점,
        d.distribution_id 배점번호,
        e.open_curriculum_subject_id 개설과정중간번호,
        d.exam_id 시험번호
    FROM distributionofscores d
        INNER JOIN mExam e
            ON d.exam_id = e.exam_id
                INNER JOIN mOpenCurriSubject ocs
                    ON e.open_curriculum_subject_id = ocs.open_curriculum_subject_id
                        INNER JOIN mOpenCurriculum oc
                            ON ocs.open_curriculum_id = oc.open_curriculum_id
                               INNER JOIN mCurriculum c
                                    ON oc.curriculum_id = c.curriculum_id;
    select * from vDistribution;
            
--시험 날짜, 시험 문제
CREATE OR REPLACE VIEW vExamDate
AS
SELECT e.exam_date 시험날짜,
        e.questions 문제,
        e.exam_id 시험번호
    FROM mExam e
        INNER JOIN mOpenCurriSubject ocs
            ON ocs.open_curriculum_subject_id = e.open_curriculum_subject_id
              INNER JOIN mOpenCurriculum oc
                ON ocs.open_curriculum_id = oc.open_curriculum_id
                    INNER JOIN mCurriculum c
                        ON c.curriculum_id = oc.curriculum_id;
                        
--시험 결과 등록 여부     
CREATE OR REPLACE VIEW vScroeAddCheck
AS
SELECT CASE
            WHEN er.score IS NOT NULL THEN '등록'
            ELSE '미등록'
        END as 성적등록여부,
	oc.open_curriculum_id 개설과정번호
    FROM mExamResult er
        JOIN mStudent st
            ON er.student_id = st.student_id
                JOIN mOpenCurriStudent ocs
                    ON st.student_id = ocs.student_id
                        JOIN mOpenCurriculum oc
                            ON oc.open_curriculum_id = ocs.open_curriculum_id
                                JOIN mCurriculum c
                                    ON c.curriculum_id = oc.curriculum_id;
                

--교재명+교육생정보 = 강의 스케줄 정보
CREATE OR REPLACE VIEW vClassSchedule
AS
SELECT b.교사비밀번호,
        b.과목번호,
        b.강의여부,
        b.과정명,
        b.과정시작일,
        b.과정종료일,
        b.강의실번호,
        b.과목명,
        b.과목시작일,
        b.과목종료일,
        b.교재명,
        s.교육생명,
        s.교육생수,
        s.등록일,
        s.수료여부
    FROM vSubAndCurriAndBook b
        INNER Join vStudent s
            ON b.개설과정번호 = s.개설과정번호;

SELECT * FROM vClassSchedule;

           
-- 과목목록 출력 - 배점
CREATE OR REPLACE VIEW vDistributionPrint
AS
SELECT b.과목번호,
        b.과정명,
        b.과정시작일,
        b.과정종료일,
        b.강의실번호,
        b.과목명,
        b.과목시작일,
        b.과목종료일,
        b.교재명,
        d.출결배점,
        d.필기배점,
        d.실기배점,
        b.교사비밀번호,
        e.시험날짜,
        e.문제,
        e.시험번호
    FROM vSubAndCurriAndBook b
        INNER JOIN vDistribution d
            ON b.개설과정중간번호 = d.개설과정중간번호
                INNER JOIN vExamDate e
                    ON e.시험번호 = d.시험번호;

select * from vDistributionPrint;


-- 목록 선택 후 배점
CREATE OR REPLACE VIEW vDistributionExamPrint
AS
SELECT d.출결배점,
        d.필기배점,
        d.실기배점,
        ed.시험날짜,
        ed.문제
    FROM vExamDate ed
        INNER JOIN vDistribution d
            ON ed.시험번호 = d.시험번호;

select * from vDistributionExamPrint;

commit;
--============================================================

-- 자신의 강의 스케줄
SELECT 과목번호,
        강의여부,
        과정명,
        과정시작일,
        과정종료일,
        강의실번호,
        과목명,
        과목시작일,
        과목종료일,
        교재명,
        교육생수,
        교육생명,
        등록일,
        수료여부
FROM vClassSchedule
    WHERE 교사비밀번호 = 1345678;
   
-- 배점- 과목 목록 출력
SELECT DISTINCT
        과목번호,
        과정명,
        과정시작일,
        과정종료일,
        강의실번호,
        과목명,
        과목시작일,
        과목종료일,
        교재명,
        출결배점,
        필기배점,
        실기배점
FROM vDistributionPrint
    WHERE 교사비밀번호 = 1345678;
    
-- 과목번호 입력
-- 출결 배점, 필기 배점, 시험 날짜, 문제, 시험 번호 출력 입력가능 화면
SELECT DISTINCT
        출결배점,
        필기배점,
        실기배점,
        시험날짜,
        문제,
        시험번호
    FROM vDistributionPrint
        WHERE 교사비밀번호 = 1345678 AND 과목번호 = 27;

-- 배점 입력
INSERT INTO distributionOfScores 
    VALUES((select count(*) from distributionOfScores) +1, 20, 40, 40, 21);

commit;
rollback;
-- 배점 수정
UPDATE distributionOfScores
    SET attendance = 25, written = 35, practical = 40
        WHERE exam_id = 21;

commit;
rollback;        
-- 시험 추가
INSERT INTO mExam
    VALUES((select count(*) from mExam) +1, 'ORACLE 필기', 1, 35, 21, '2025-02-05');

commit;
rollback;
-- 시험 수정
UPDATE mExam
    SET questions = 50, exam_date = '2025-02-05'
        WHERE exam_id = 21;

commit;
rollback;