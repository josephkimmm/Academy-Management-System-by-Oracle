-- 관리자 요구사항

SET SERVEROUTPUT ON;

--=====================================C-06==============================================================

-- 교육생 정보 입력 시
-- 교육생 이름, 주민번호 뒷자리, 전화번호를 기본 입력, 등록일 자동 입력

CREATE OR REPLACE PROCEDURE insert_student(
    p_name IN VARCHAR2,
    p_jumin IN VARCHAR2,
    p_tel IN VARCHAR2
)
IS
    v_id NUMBER;
BEGIN
    SELECT COUNT(*) + 1 INTO v_id FROM mStudent;
    
    INSERT INTO mStudent (student_id, name, jumin, tel, registration_date)
    VALUES (v_id, p_name, p_jumin, p_tel, SYSDATE);
    dbms_output.put_line(p_name || ' 교육생이 등록되었습니다.');
    COMMIT;
END insert_student;
/

begin
    insert_student('조성제', '9887618', '010-6822-3793');
end;
/

rollback;

select * from mStudent;

-- 교육생 정보 출력 시
-- 교육생 이름, 주민번호 뒷자리, 전화번호, 등록일, 수강(신청) 횟수 출력

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


-- 특정 교육생 정보 선택 시
-- 수강 신청한 강의 또는 수강 중, 수강했던 개설 과정 정보(과정 명, 과정 기간(시작 년월일, 종료 년월일), 강의실, 수료 및 중도탈락 여부, 수료 및 중도탈락 날짜) 출력

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
            
            
--검색


-- 인덱스 추가 > 검색 속도 향상
CREATE INDEX idx_student_name_jumin ON mStudent(name, jumin);

select * from vwStudentAlldate;


CREATE OR REPLACE PROCEDURE studentsearch(
    p_name IN vwStudentAlldate.교육생명%TYPE,
    p_jumin IN vwStudentAlldate."주민번호 뒷자리"%TYPE
)
IS
    v_name vwStudentAlldate.교육생명%TYPE;
    v_jumin vwStudentAlldate."주민번호 뒷자리"%TYPE;
    v_curriname vwStudentAlldate."개설 과정명"%TYPE;
    v_status vwStudentAlldate."개설 현황"%TYPE;

    CURSOR c1 IS
        SELECT 교육생명, "주민번호 뒷자리", "개설 과정명", "개설 현황"
        FROM vwStudentAlldate
        WHERE 교육생명 = p_name
        AND "주민번호 뒷자리" = p_jumin;

BEGIN
    OPEN c1;

    LOOP
        FETCH c1 INTO v_name, v_jumin, v_curriname, v_status;
        EXIT WHEN c1%NOTFOUND;

        -- 교육생명과 주민번호가 일치하는 경우 출력
        DBMS_OUTPUT.PUT_LINE('교육생명: ' || v_name || ', 주민번호 뒷자리: ' || v_jumin || ', 개설 과정명: ' || v_curriname || ', 개설 현황: ' || v_status);
    END LOOP;

    CLOSE c1;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('해당 교육생 정보가 없습니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다: ' || SQLERRM);
    
    
    
end studentsearch;
/

begin
    studentsearch('김희재','1065487');
end;
/

-- 교육생에 대한 수료 및 중도 탈락 처리 필요 -> 날짜 데이터 입력 > 프로시저 만들기
select * from mStudent;

create or replace PROCEDURE studentdropdate(
    p_name IN mStudent.name%TYPE,
    p_jumin IN mStudent.jumin%TYPE,
    p_dropdate IN mStudent.dropout_date%TYPE
)
is
    v_name mStudent.name%type;
    v_jumin mStudent.jumin%type;
    v_tel mStudent.tel%type;
    v_regdate mStudent.registration_date%type;
    v_dropdate mStudent.dropout_date%type;
begin
    
    begin
        select name, jumin, tel, registration_date, dropout_date
        into v_name, v_jumin, v_tel, v_regdate, v_dropdate
        from mStudent
        where jumin = p_jumin;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('해당 교육생이 존재하지 않습니다.');
            RETURN;
    end;
    
    IF v_dropdate IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('해당 날짜로 중퇴 처리 된 교육생입니다. 중퇴일: ' || v_dropdate);
        RETURN;
    END IF;
    
    update mStudent set dropout_date = p_dropdate where jumin = p_jumin;
    
    DBMS_OUTPUT.PUT_LINE('교육생명: ' || v_name || ', 주민번호 뒷자리: ' || v_jumin || ', 연락처: ' || v_tel || ', 등록일: ' || v_regdate);
    DBMS_OUTPUT.PUT_LINE(v_dropdate || '로 중퇴일 등록하였습니다.');
    
end;
/

begin
    studentdropdate('김희재', '1065487', '2030-01-01');
end;
/
rollback;
select * from mstudent
where name = '김희재';

-- CRUD
 -- 교육생 정보 수정 
update mStudent set name = '조인제' where Student_id = 337;

 -- 교육생 정보 삭제 
delete from mStudent where Student_id = 337; 

-- 교육생 정보 조회
SELECT * FROM mStudent;

--=====================================C-07==============================================================
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
create or replace view vwStudentAlldate
as
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
        on t.student_id = i.student_id;
    
select * from vwStudentAlldate     
    where 교육생명 = '김기민';


--=====================================C-08==============================================================

--[관리자] 출결 관리 및 출결 조회 완
-- 특정 개설 과정 선택 시 -> 해당 과정 모든 교육생의 출결 조회
-- 출결 현황을 기간 별(년, 월, 일)로 조회 필요
-- 특정 과정, 특정 인원 출결 현황 조회 필요
-- 출결 조회 시 근태상황 구분 필요 > 정상, 지각, 조퇴, 외출, 병가, 기타


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

-- 특정 개설 과정 선택 시 -> 해당 과정 모든 교육생의 출결 조회 > 출결 현황을 기간 별(년, 월, 일)로 조회  
--특정 과정           
select * from vwCurriAttance
where 과목명 = 'Firebase와 React를 활용한 모바일 앱 개발 과정';        

-- 특정 인원 출결 현황 조회 필요 > 출결 조회 시 근태상황 구분 필요 > 정상, 지각, 조퇴, 외출, 병가, 기타         
--특정 인원
select * from vwCurriAttance
where 교육생명 = '박호진';       


--=====================================C-09==============================================================




