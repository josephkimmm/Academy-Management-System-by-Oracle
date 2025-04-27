
--관리자
--1. 관리자 정보 등록(관리자번호, 관리자 이름) 
insert into mManager values (6, '조민제');

 --2. 관리자 정보 수정 
update mManager set name = '조인제' where Manager_id = 6;

 --3. 관리자 정보 삭제 
delete from mManager where Manager_id = 6; 

--4. 관리자 정보 조회(관리자번호, 관리자 이름)을 출력한다.
SELECT * FROM mManager;



--교육생
--1. 교육생 정보 등록(교육생번호, 교육생 이름, 민증 뒷자리, 연락처, 등록일, 수료일, 중도탈락) 
insert into mStudent values (337, '조성제', '1822111', '010-6822-3727', '24-09-28', '24-12-27', null);

 --2. 교육생 정보 수정 
update mStudent set name = '조인제' where Student_id = 337;

 --3. 교육생 정보 삭제 
delete from mStudent where Student_id = 337; 

--4. 교육생 정보 조회(교육생번호, 교육생 이름, 민증 뒷자리, 연락처, 등록일, 수료일, 중도탈락)을 출력한다.
SELECT * FROM mStudent;




--교사
--1. 교사 정보 등록(교사번호, 교사 이름, 민증 뒷자리, 연락처) 
insert into mTeacher values (11, '조성제', '1822111', '010-6822-3727');

 --2. 교사 정보 수정 
update mTeacher set name = '조인제' where Teacher_id = 11;

 --3. 교사 정보 삭제 
delete from mTeacher where Teacher_id = 11; 

--4. 교사 정보 조회(교사번호, 교사 이름, 민증 뒷자리, 연락처, 강의가능 과목)을 출력한다.
SELECT * FROM mTeacher;
select  
    t.name as "이름", 
    t.jumin as "민증 뒷자리", 
    t.tel as "전화번호", 
    s.title as "강의가능과목" 
    
from mTeacher t 
    inner join mAvailableSubject a 
        on t.teacher_id = a.teacher_id 
            inner join mSubject s 
                on a.subject_id = s.subject_id; 


--강의실
--1. 강의실 정보 등록(강의실 번호, 인원수) 
INSERT INTO mRoom VALUES (7, 30);

 --2. 강의실 정보 수정 
update mRoom set capacity = 26 where room_id = 7;

 --3. 강의실 정보 삭제 
delete from mRoom where room_id = 7; 

--4. 강의실 정보 조회(강의실 번호, 인원수)을 출력한다.
SELECT * FROM mRoom;



-- 교재
--1. 교재 정보 등록(교재 번호, 제목, 출판사) 
INSERT INTO mBook VALUES (51, '조인제의 정석', '도우미출판');

 --2. 교재 정보 수정 
update mBook set title = '나의 정석' where book_id = 51;

 --3. 교재 정보 삭제 
delete from mBook where book_id = 51; 

--4. 교재 정보 조회(교재 번호, 제목, 출판사)을 출력한다.
SELECT * FROM mBook;

--=========================================================================================
select count(*) from mCurriculum;
select * from mCurriculum;

-- 과정 생성
insert into mCurriculum values ((select count(*) from mCurriculum) +1, 'Chat GPT를 활용한 웹 개발 과정');

-- 과정명 수정
update mCurriculum SET title = 'Chat GPT를 활용한 앱 개발 과정' where curriculum_id = 51;

-- 과정 삭제
delete from mCurriculum where curriculum_id = 51;

--=============================================================================================

select count(*) from mSubject;
select * from mSubject;

-- 과목 생성
insert into msubject values ((select count(*) from msubject) + 1, 'LARAVEL');

-- 과목명 수정
update msubject set title = 'golang' where subject_id = 51;

-- 과목 삭제
delete from msubject where subject_id = 51;


--============================================================================================
select * from mHoliday;

--공휴일 생성
insert into mHoliday values(to_date('2027-06-06', 'yyyy-mm-dd'), '공휴일');

--공휴일 수정
update mHoliday set totaldate = '2027-10-4', dateClassfication = '평일' where totaldate = '2027-06-06';

--공휴일 삭제
delete from mHoliday where totaldate = '2027-10-4';


