--ansi-SQL

CREATE OR REPLACE VIEW teacher_subject_info AS
SELECT 
    t.name AS 교사명, 
    t.jumin AS 주민번호,
    t.tel AS 전화번호,
    s.title AS 강의_가능_과목
FROM 
    mTeacher t
JOIN 
    mAvailableSubject asub ON t.teacher_id = asub.teacher_id
JOIN 
    mSubject s ON asub.subject_id = s.subject_id;
    
SELECT * FROM teacher_subject_info;

------------------------------------------------------------------------------
CREATE OR REPLACE VIEW teacher_class_schedule AS
SELECT 
    os.title AS 개설과목명,
    os.startdate AS 개설과목시작일,
    os.enddate AS 개설과목종료일,
    c.title AS 과정명,
    oc.startdate AS 개설과정시작일,
    oc.enddate AS 개설과정종료일,
    b.title AS 교재명,
    r.room_id AS 강의실번호,  -- 강의실 번호
    t.name AS 교사명,
    CASE
        WHEN SYSDATE < os.startdate THEN '강의예정'
        WHEN SYSDATE BETWEEN os.startdate AND os.enddate THEN '강의중'
        WHEN SYSDATE > os.enddate THEN '강의종료'
    END AS 강의진행여부
FROM 
    mTeacher t
    INNER JOIN mOpenCurriculum oc ON t.teacher_id = oc.teacher_id
    INNER JOIN mCurriculum c ON oc.curriculum_id = c.curriculum_id
    INNER JOIN mOpenCurriSubject ocs ON oc.open_curriculum_id = ocs.open_curriculum_id
    INNER JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id
    LEFT JOIN mOpensubjectBook osb ON os.open_subject_id = osb.open_subject_id
    LEFT JOIN mBook b ON osb.book_id = b.book_id
    LEFT JOIN mRoom r ON oc.room_id = r.room_id;


    SELECT * 
FROM teacher_class_schedule
where 교사명 = '김미숙';

------------------------------------------------------------
CREATE OR REPLACE VIEW curriculum_subject_info AS
SELECT 
    oc.title AS 과정명,  -- 개설 과정명
    oc.startdate AS 과정시작일,  -- 개설 과정 시작일
    oc.enddate AS 과정종료일,  -- 개설 과정 종료일
    r.room_id AS 강의실번호,  -- 강의실 번호
    os.title AS 과목명,  -- 과목명
    os.startdate AS 과목시작일,  -- 과목 시작일
    os.enddate AS 과목종료일,  -- 과목 종료일
    b.title AS 교재명,  -- 교재명
    t.name AS 교사명  -- 교사명
FROM 
    mOpenCurriculum oc
    INNER JOIN mCurriculum c ON oc.curriculum_id = c.curriculum_id  -- 개설 과정과 연결
    LEFT JOIN mRoom r ON oc.room_id = r.room_id  -- 강의실과 연결
    INNER JOIN mOpenCurriSubject ocs ON oc.open_curriculum_id = ocs.open_curriculum_id  -- 개설 과정과 개설 과목 연결
    INNER JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id  -- 개설 과목과 연결
    LEFT JOIN mOpensubjectBook osb ON os.open_subject_id = osb.open_subject_id  -- 교재 정보와 연결
    LEFT JOIN mBook b ON osb.book_id = b.book_id  -- 교재명
    INNER JOIN mTeacher t ON oc.teacher_id = t.teacher_id;  -- 교사 정보와 연결
    

SELECT * 
FROM curriculum_subject_info
    where 과목명 = 'AWS';


-----------------------------------------------------------

CREATE OR REPLACE VIEW available_teachers_for_current_subject AS
SELECT 
    t.name AS 교사명,  -- 교사명
    os.title AS 현재과목,  -- 개설 과목명
    s.title AS 강의가능과목  -- 강의 가능한 과목
FROM 
    mTeacher t
    INNER JOIN mAvailableSubject asub ON t.teacher_id = asub.teacher_id  -- 교사와 강의 가능한 과목 연결
    INNER JOIN mOpenCurriculum oc ON oc.teacher_id = t.teacher_id  -- 개설 과정과 교사 연결
    INNER JOIN mOpenCurriSubject ocs ON oc.open_curriculum_id = ocs.open_curriculum_id  -- 개설 과정과 개설 과목 연결
    INNER JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id  -- 개설 과목과 과목 연결
    INNER JOIN mSubject s ON asub.subject_id = s.subject_id  -- 강의 가능한 과목
WHERE 
    asub.subject_id = os.subject_id;  -- 강의 가능한 과목과 개설 과목이 일치하는 교사만

SELECT * FROM available_teachers_for_current_subject;

---------------------------------------------------------

CREATE OR REPLACE VIEW curriculum_subject_and_students AS
SELECT 
    os.title AS 과목명,
    os.startdate AS 과목시작일,
    os.enddate AS 과목종료일,
    b.title AS 교재명,
    t.name AS 교사명,
    s.name AS 교육생이름,
    s.jumin AS 주민번호,
    s.tel AS 전화번호,
    s.registration_date AS 등록일,
    s.completion_date AS 수료일,
    s.dropout_date AS 중도탈락일
FROM 
    mOpenCurriculum oc
    INNER JOIN mOpenCurriSubject ocs ON oc.open_curriculum_id = ocs.open_curriculum_id
    INNER JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id
    LEFT JOIN mOpensubjectBook osb ON os.open_subject_id = osb.open_subject_id
    LEFT JOIN mBook b ON osb.book_id = b.book_id
    LEFT JOIN mTeacher t ON oc.teacher_id = t.teacher_id
    LEFT JOIN mOpenCurriStudent cs ON oc.open_curriculum_id = cs.open_curriculum_id
    LEFT JOIN mStudent s ON cs.student_id = s.student_id
 where oc.title = 'Python과 Django를 활용한 웹 개발자 양성 과정';
 

SELECT * 
FROM curriculum_subject_and_students;


----------------------------------------------------------
CREATE OR REPLACE VIEW open_curriculum_info AS
SELECT 
    oc.title AS 개설과정명,
    oc.startdate AS 개설과정시작일,
    oc.enddate AS 개설과정종료일,
    r.room_id AS 강의실번호,
    CASE
        WHEN os.open_subject_id IS NOT NULL THEN '등록됨'
        ELSE '미등록'
    END AS 개설과목등록여부,
    COUNT(DISTINCT cs.student_id) AS 등록교육생수  -- DISTINCT를 사용하여 중복 교육생을 제거
FROM 
    mOpenCurriculum oc
    LEFT JOIN mRoom r ON oc.room_id = r.room_id  -- 강의실 정보
    LEFT JOIN mOpenCurriSubject ocs ON oc.open_curriculum_id = ocs.open_curriculum_id  -- 개설 과목
    LEFT JOIN mOpenSubject os ON ocs.open_subject_id = os.open_subject_id  -- 과목명
    LEFT JOIN mOpenCurriStudent cs ON oc.open_curriculum_id = cs.open_curriculum_id  -- 교육생 정보
GROUP BY 
    oc.title, oc.startdate, oc.enddate, r.room_id, os.open_subject_id;  -- 중복을 제거할 때 GROUP BY 사용

-- 중복이 없어진 결과를 확인하려면:
SELECT distinct * from open_curriculum_info
WHERE 개설과정명 = '빅데이터 분석과 데이터구조를 활용한 데이터 분석 전문가 과정';





--===================================================================================


--[관리자] 출결 관리 및 출결 조회 완

select * from mopencurriculum;
select * from mopencurristudent;

select * from mopencurristudent os
    inner join mstudent s
        on os.student_id = s.student_id;
    

CREATE OR REPLACE VIEW vwcurriStudent
as
select c.title, s.name, s.student_id from mopencurristudent os
    inner join mopencurriculum c
        on os.open_curriculum_id = c.open_curriculum_id
            inner join mstudent s
                on os.student_id = s.student_id
                    where c.status = '강의 진행중';

create or replace view vwStudentTime
as
select s.name, s.student_id, t.clock_out, t.clock_in, a.name as status from mStudent s
    left outer join mTimekeeping t
        on s.student_id = t.student_id
            left outer join mAttendanceType a
                on t.attendance_type_id = a.attendance_type_id
            order by t.clock_in;

select * from vwStudentTime;

-- 1,3 완료
create or replace view vwCurriAttance
as
select s.title as "과목명", s.name as "교육생명", t.clock_in as "입실", t.clock_out as "퇴실", t.status as "근태 상황" from vwcurriStudent s
    right outer join vwStudentTime t
        on s.student_id = t.student_id
            order by "입실";
            
select * from vwCurriAttance;          
            
--특정 과정           
select * from vwCurriAttance
where 과목명 = 'Firebase와 React를 활용한 모바일 앱 개발 과정';        

        
--특정 인원
select * from vwCurriAttance
where 교육생명 = '박호진';       

--=======================================================================================
--[관리자] 시험 관리 및 성적 조회 >  교육생의 성적 조회 완

/*
--완
특정 개설 과정을 선택하는 경우 등록된 개설 과목 정보를 출력하고, 
개설 과목별로 성적 등록 여부, 시험 문제 파일 등록 여부를 확인할 수 있어야 한다. 
성적 정보 출력 시 개설 과목별, 교육생 개인별로 출력할 수 있어야 한다.

--완
과목별 출력 시 개설 과정명, 개설 과정 기간, 강의실명, 개설 과목명, 교사명, 교재명 등을 출력하고, 
해당 개설 과목을 수강한 모든 교육생들의 성적 정보(교육생 이름, 주민번호 뒷자리, 필기, 실기)를 같이 출력한다.

교육생 개인별 출력 시 교육생 이름, 주민번호 뒷자리, 
개설 과정명, 개설 과정 기간, 강의실명 등을 출력하고, 
교육생 개인이 수강한 모든 개설 과목에 대한 성적 정보(개설 과목명, 개설 과목 기간, 교사명, 필기, 실기)를 같이 출력한다.


*/

select * from mopencurriculum;
select * from mopencurrisubject;
select * from mopensubject;

-- 특정 과정 선택시, 과목 확인(1-1)
select c.title as "과정", j.title as "과목" from mopencurrisubject cj
    inner join mopensubject j
        on cj.open_subject_id = j.open_subject_id
            inner join mopencurriculum c
                on cj.open_curriculum_id = c.open_curriculum_id
                    where c.title = 'AWS와 Client 와 SPRING을 활용한 클라우드 개발자 양성과정';


-- 개설 과목별로 성적 등록 여부, 시험 문제 파일 등록 여부를 확인 (1-2)
select  
j.title, x.title, t.exam_type,
case
    when x.exam_date is null then '미등록'
    when x.exam_date is not null then '등록'
end as "성적 등록 여부",
case
    when x.exam_id is null then '미등록'
    when x.exam_id is not null then '등록'
end as "시험 문제 파일 등록 여부"

from mopencurrisubject c
    inner join mexam x
        on c.open_curriculum_subject_id = x.open_curriculum_subject_id
        inner join mexamtype t
            on x.exam_type_id = t.exam_type_id
            inner join mopensubject j
                on c.open_subject_id = j.open_subject_id;
                
select * from mstudent;


-- 교육생, 과목, 성적 뷰
create or replace view vwSubjectTest
as
select
s.name as 교육생명,
j.title as 과목,
e.title as 시험명,
case
    when e.exam_type_id = 1 then '필기'
    when e.exam_type_id = 2 then '실기'
end as 시험유형,
r.score 성적,
s.student_id,
s.jumin,
s.completion_date,
j.startdate as "과목 시작일",
j.enddate as "과목 종료일"
from mexamresult r
    inner join mstudent s
        on r.student_id = s.student_id
        inner join mexam e
        on r.exam_id = e.exam_id
            inner join mopencurrisubject cj
                on cj.open_curriculum_subject_id = e.open_curriculum_subject_id
                    inner join mopensubject j
                        on cj.open_subject_id = j.open_subject_id;
               
-- 성적 정보 출력 시 개설 과목별, 교육생 개인별로 출력(1-3)
-- 개설 과목별 성적 출력
select 교육생명, 과목, 시험명, 시험유형, 성적 from vwsubjecttest
    where 과목 = 'AWS';


-- 교육생별 성적 출력
select 교육생명, 과목, 시험명, 시험유형, 성적 from vwsubjecttest
    where 교육생명 = '민유리';


-- 개설 현황 뷰
create or replace view vwopenCurrStatus
as
select 
oc.title as "개설 과정명",
oc.startdate as "개설 시작일",
oc.enddate as "개설 종료일",
oc.status as "개설 현황",
oc.room_id as "강의실명",
os.title as "개설과목명",
oc.teacher_id,
cs.open_subject_id,
os.startdate as "과목 시작일",
os.enddate as "과목 종료일"
from mopencurrisubject cs
    inner join mopencurriculum oc
        on cs.open_curriculum_id = oc.open_curriculum_id
    inner join mopensubject os
        on cs.open_subject_id = os.open_subject_id;


--과목별 출력 시 개설 과정명, 개설 과정 기간, 강의실명, 개설 과목명, 교사명, 교재명 등을 출력(2-1)
--뷰 1
--개설 과정명, 개설 시작일, 개설 종료일, 개설 현황, 강의실명, 개설과목명
-- 1과목에 다수의 책
create or replace view vwCurrInfo
as
select 개설과목명, "개설 과정명", "개설 시작일", "개설 종료일", "개설 현황", 강의실명, t.name as 교사명, b.title 교재명 from mopensubjectbook sb
    inner join vwopenCurrStatus c
        on sb.open_subject_id = c.open_subject_id
            inner join mbook b
                on sb.book_id = b.book_id
                    inner join mteacher t
                        on c.teacher_id = t.teacher_id;



--해당 개설 과목을 수강한 모든 교육생들의 성적 정보(교육생 이름, 주민번호 뒷자리, 필기, 실기)를 같이 출력한다.(2-2)
select 과목, 교육생명, jumin as "주민번호 뒷자리", 시험명, 시험유형, 성적 
from vwSubjectTest
where 과목 = '자바';


--완료
--교육생 개인별 출력 시 교육생 이름, 주민번호 뒷자리, 
--개설 과정명, 개설 과정 기간, 강의실명 등을 출력하고, 
--교육생 개인이 수강한 모든 개설 과목에 대한 성적 정보(개설 과목명, 개설 과목 기간, 교사명, 필기, 실기)를 같이 출력한다.

-- 과정명, 기간, 강의실명
create or replace view vwcurrInfo
as
select c.title, c.startdate, c.enddate, c.status, c.room_id, c.open_curriculum_id, t.name as 교사명, os.student_id from mopencurristudent os
    inner join mopencurriculum c
        on os.open_curriculum_id = c.open_curriculum_id
            inner join mteacher t
                on t.teacher_id = c.teacher_id;


-- 교육생 이름, 민증, 과목명, 시험명, 유형, 성적
select 교육생명, jumin as "주민번호 뒷자리", 
i.title as "개설 과정명",
i.startdate as "과정 시작일", 
i.enddate as "과정 종료일", 
i.status as "개설 현황", 
i.room_id as 강의실,
과목,
과목 시작일,
과목 종료일,
시험명,
시험유형,
성적,
교사명

from vwSubjectTest t
    inner join vwcurrinfo i
        on t.student_id = i.student_id
            where 교육생명 = '김기민';

--=======================================================================================
--[관리자] 교육생 관리 기능 > 교육생 정보 등록 및 관리 --완

/*

- 교육생 정보 출력시 교육생 이름, 주민번호 뒷자리, 전화번호, 등록일, 수강(신청) 횟수를 출력한다.
- 특정 교육생 선택시 교육생이 수강 신청한 또는 수강중인, 수강했던 개설 과정 정보(과정명, 과정기간(시작 년월일, 끝 년월일), 강의실, 수료 및 중도탈락 여부, 수료 및 중도탈락 날짜)를 출력

*/

--교육생 정보 출력시 교육생 이름, 주민번호 뒷자리, 전화번호, 등록일, 수강(신청) 횟수를 출력한다.
WITH student_info AS (
    SELECT s.student_id, s.name, s.jumin, s.tel, s.registration_date
    FROM mstudent s
    WHERE s.name = '김희재'
)
select
   si.name AS 교육생명, 
    si.jumin AS "주민번호 뒷자리", 
    si.tel AS 전화번호, 
    si.registration_date AS 등록일,
    (SELECT COUNT(*) FROM mopencurristudent c WHERE c.student_id = si.student_id) AS "수강(신청) 횟수"
from student_info si;


-- 특정 교육생 선택시 교육생이 수강 신청한 또는 수강중인, 수강했던 개설 과정 정보(과정명, 과정기간(시작 년월일, 끝 년월일), 강의실, 수료 및 중도탈락 여부, 수료 및 중도탈락 날짜)를 출력
select 
    교육생명,
    i.title as 과정명,
    i.startdate as "과정 시작일",
    i.enddate as "과정 종료일",
    i.room_id as 강의실명,
    case
        when t.completion_date is not null then '수료'
        else '중도 탈락'
    end as "수료(중도 탈락) 여부",
    
    case
        when t.completion_date is not null then t.completion_date
        else null
    end

from vwSubjectTest t
    inner join vwcurrinfo i
        on t.student_id = i.student_id
            where 교육생명 = '박동현';



--=====================================================================
--개설 과정 정보에 대한 curd

-- 1. 새로운 개설 과정 추가
INSERT INTO mOpenCurriculum VALUES (13, 'Machine Learning 전문가 과정', TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-07-10', 'YYYY-MM-DD'), '6개월', '강의 예정', 3, 2, 4);

-- 2. 전체 개설 과정 조회
SELECT * FROM mOpenCurriculum ORDER BY open_curriculum_id;

-- 4. 특정 개설 과정 정보 수정 (ID: 13)
UPDATE mOpenCurriculum SET title = 'AI 전문가 과정', status = '강의 진행중' WHERE open_curriculum_id = 13;

-- 5. 특정 개설 과정 삭제 (ID: 13)
DELETE FROM mOpenCurriculum WHERE open_curriculum_id = 13;

-- 6. 특정 개설 과정 수료 처리 (ID: 3)
UPDATE mStudent st
SET completion_date = SYSDATE
WHERE st.student_id IN (
    SELECT ocs.student_id 
    FROM mOpenCurriStudent ocs
    JOIN mStudent s ON ocs.student_id = s.student_id
    WHERE ocs.open_curriculum_id = 3
    AND s.dropout_date IS NULL
);

SELECT 
    open_curriculum_id AS "개설 과정 ID", 
    title AS "과정명", 
    startdate AS "시작일", 
    enddate AS "종료일", 
    room_id AS "강의실 ID", 
    CASE WHEN EXISTS (
        SELECT 1 
        FROM mOpenCurriSubject 
        WHERE open_curriculum_id = mOpenCurriculum.open_curriculum_id) 
    THEN 'O' ELSE 'X' END AS "개설 과목 등록 여부", 
    (SELECT COUNT(*) 
     FROM mOpenCurriStudent 
     WHERE open_curriculum_id = mOpenCurriculum.open_curriculum_id) AS "교육생 등록 인원"
FROM mOpenCurriculum
ORDER BY open_curriculum_id;

--=================================================================================================


-- 개설 과목 정보 입력 시 > 과목 명, 과목 기간(시작 년월일, 종료 년월일), 교재명, 교사명 입력

select * from mbook; -- 교재명 출력
select * from mteacher; -- 교사명 출력
select * from mcurriculum; -- 과정 출력

select * from mopencurriculum;

rollback;

-- 과정 생성
insert into mopencurriculum values ((select count(*) from mopencurriculum) + 1, 'AI 모델 학습 및 딥러닝을 활용한 AI개발자 양성 과정', '2025-04-01', '2025-10-01', '6', '강의 예정',48, 3, 1); 

-- 과정 수정
update mopencurriculum set title = 'AI 모델 학습 및 머신러닝을 활용한 AI개발자 양성 과정', startdate = '2025-05-01', enddate = '2025-11-01' where open_curriculum_id = 13; 

-- 과정 삭제
delete from mopencurriculum where open_curriculum_id = 13;


















-- 과정 생성, 수정시 트리거
CREATE OR REPLACE TRIGGER trg_mopencurriculum_validation
BEFORE INSERT OR UPDATE ON mopencurriculum
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM mcurriculum WHERE curriculum_id = :NEW.curriculum_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '존재하지 않는 과정입니다.');
    END IF;
    
    SELECT COUNT(*) INTO v_count FROM mRoom WHERE room_id = :NEW.room_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '잘못된 강의실 번호입니다.');
    END IF;
    
    SELECT COUNT(*) INTO v_count FROM mteacher WHERE teacher_id = :NEW.teacher_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '잘못된 교사 번호입니다.');
    END IF;
END;
/






