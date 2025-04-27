--교육생 ansi

--view

-- 교육생
-- 성적 조회 기능 > 성적 조회


-- 교육생 타이틀 출력
create or replace view vwStudent1
as
select s.student_id as 교육생번호,
       s.name as 교육생이름,
       s.jumin as "주민번호 뒷자리",
       s.tel as 전화번호,
       oc.title as 과정명 ,
       oc.startdate as "과정기간 시작",
       oc.enddate as "과정기간 종료",
       r.room_id as "강의실 이름"
    from mStudent s
        left outer join mOpenCurriStudent o
            on s.student_id = o.student_id
                inner join mOpenCurriculum oc
                    on o.open_curriculum_id = oc.open_curriculum_id
                        inner join mroom r
                            on oc.room_id = r.room_id
                                where s.student_id = 1;
                            
select * from vwStudent1;
drop view vwStudent1;

-- 과목별 성적 정보 출력
create or replace view vwStudent2 
as
select
    s.student_id as 교육생번호,
    s.name as 교육생이름,
    ms.title as 과목명,
    os.startdate as "과목기간 시작",
    os.enddate as "과목기간 종료",
    b.title as 교재명,
    t.name as 교사이름,
    dos.attendance as 출결배점,
    dos.written as 필기배점,
    dos.practical as 실기배점,
    xt.exam_type as 시험유형,
    e.score as 점수,
    x.exam_date as 시험날짜,
    x.title as 시험문제
    from mStudent s
        left join mExamResult e
            on s.student_id = e.student_id
                left join mExamType xt
                    on e.exam_type_id = xt.exam_type_id
                        left join mExam x
                            on e.exam_id = x.exam_id
                                left join mOpenCurriSubject ocs
                                    on x.open_curriculum_subject_id = ocs.open_curriculum_subject_id
                                        left join mOpenSubject os
                                            on ocs.open_subject_id = os.open_subject_id
                                                left join mSubject ms
                                                    on os.subject_id = ms.subject_id
                                                        left join mOpensubjectBook osb 
                                                            on os.open_subject_id = osb.open_subject_id
                                                                left join mBook b 
                                                                    on osb.book_id = b.book_id
                                                                        left join mAvailableSubject avs 
                                                                            on os.open_subject_id = avs.available_subject_id
                                                                                left join mTeacher t 
                                                                                    on avs.teacher_id = t.teacher_id
                                                                                        left join distributionOfScores dos
                                                                                            on x.exam_id = dos.exam_id
                                                                                                where s.student_id = 1;
                                            
select * from vwStudent2;
drop view vwStudent2;



--출결 관리 및 출결 조회
-- 교육생 전체/월별 출결 조회

create or replace view vwStudent3
as
select
    s.student_id as 교육생번호,
    s.name as 교육생이름,
    tk.clock_in as 입실시간,
    clock_out as 퇴실시간,
    at.name as 근태유형명
    
from mStudent s
    inner join mTimeKeeping tk
        on s.student_id = tk.student_id
            inner join mAttendanceType at
                on tk.attendance_type_id = at.attendance_type_id
                    where s.student_id = 285 and to_char(tk.clock_in, 'MM') = '01' and to_char(tk.clock_in, 'dd') = '20';

            
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';


select * from vwStudent3;
drop view vwStudent3;

    