--drop

-- 출결 삭제
DROP TABLE mTimekeeping;

-- 사후관리 테이블 삭제
DROP TABLE mAfterService;

-- 수료생 테이블 삭제
DROP TABLE mGradStudent;

-- 관리자 강사 평가 삭제
DROP TABLE mAdminTeacherEval;

-- 시험 결과 삭제
DROP TABLE mExamResult;

-- 자료 삭제
DROP TABLE mMaterial;

-- 개설 과정 + 교육생
DROP TABLE mOpenCurriStudent;

-- 개설과목 + 교재 삭제
DROP TABLE mOpensubjectBook;

-- 강의실 예약 삭제
DROP TABLE mReservation;

-- 배점 삭제
DROP TABLE distributionOfScores;

-- 시험 삭제
DROP TABLE mExam;

-- 개설 과정 + 과목 삭제
DROP TABLE mOpenCurriSubject;

-- 개설 과정 삭제
DROP TABLE mOpenCurriculum;

-- 개설 과목 삭제
DROP TABLE mOpenSubject;

-- 강의 가능 과목
DROP TABLE mAvailableSubject;

-- 교육생 삭제
DROP TABLE mStudent;

-- 교사 삭제
DROP TABLE mTeacher;

-- 관리자 삭제
DROP TABLE mManager;

-- 강의실 삭제
DROP TABLE mRoom;

-- 교재 삭제
DROP TABLE mBook;

-- 과정 삭제
DROP TABLE mCurriculum;

-- 과목 삭제
DROP TABLE mSubject;

-- 시험 유형 삭제
DROP TABLE mExamType;

-- 근태 유형 삭제
DROP TABLE mAttendanceType;

-- 공휴일 삭제
DROP TABLE mHoliday;

SELECT * FROM tabs;

-- ================================================================= 기본 데이터 ===================================================================

--관리자
CREATE TABLE mManager(
    manager_id NUMBER PRIMARY KEY,
    name Varchar2(1500) NOT NULL,
    password VARCHAR2(200) NOT NULL
);
SELECT * FROM mManager;


--교육생
CREATE TABLE mStudent (
    student_id NUMBER PRIMARY KEY,
    name VARCHAR2(1500) NOT NULL,
    jumin VARCHAR2(1500) NOT NULL UNIQUE,
    tel VARCHAR2(1500) NOT NULL UNIQUE,
    registration_date DATE NOT NULL,
    completion_date DATE,
    dropout_date DATE
);
SELECT * FROM mStudent;


--교사
CREATE TABLE mTeacher (
    teacher_id NUMBER PRIMARY KEY,
    name VARCHAR2(1500) NOT NULL,
    jumin VARCHAR2(1500) NOT NULL UNIQUE,
    tel VARCHAR2(1500) NOT NULL
);
SELECT * FROM mTeacher;


--강의실
CREATE TABLE mRoom (
    room_id NUMBER PRIMARY KEY CHECK(room_id IN (1,2,3,4,5,6)),
    capacity NUMBER NOT NULL CHECK(capacity IN (30,26))
);
SELECT * FROM mRoom;

--교재
CREATE TABLE mBook (
    book_id NUMBER PRIMARY KEY,
    title  VARCHAR2(2000) NOT NULL,
    publisher  VARCHAR2(2000) NOT NULL
);
SELECT * FROM mBook;


--과정
CREATE TABLE mCurriculum (
    curriculum_id NUMBER PRIMARY KEY,
    title VARCHAR2(2000) NOT NULL
);
SELECT * FROM mCurriculum;



--과목
CREATE TABLE mSubject (
    subject_id NUMBER PRIMARY KEY,
    title  VARCHAR2(2000) NOT NULL
);
SELECT * FROM mSubject;



--시험 유형
CREATE TABLE mExamType (
    exam_type_id NUMBER PRIMARY KEY,
    exam_type varchar2(30) NOT NULL CHECK (exam_type IN ('필기', '실기'))
);
SELECT * FROM mExamType;


--근태테이블
CREATE TABLE mAttendanceType (
    attendance_type_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL CHECK (name in ('정상', '지각', '조퇴', '외출', '병가', '기타'))
);

SELECT * FROM mAttendanceType;


-- 공휴일
CREATE TABLE mHoliday (
    totalDate DATE PRIMARY KEY,
    dateClassfication VARCHAR2(100) NOT NULL CHECK (dateClassfication in ('평일', '주말', '공휴일'))
);

SELECT * FROM mHoliday;

--=================================================================중간 데이터===========================================================================
--개설과정
create table mOpenCurriculum (
    open_curriculum_id NUMBER PRIMARY KEY,
    title  VARCHAR2(2000) NOT NULL,
    startdate  DATE NOT NULL,
    enddate  DATE NOT NULL,
    month  VARCHAR2(500) NOT NULL,
    status varchar2(100) NOT NULL CHECK(status IN ('강의 종료', '강의 예정', '강의 진행중')),
    
    curriculum_id NUMBER,
    CONSTRAINT FK_mOpenCurriculum_mCurriculum FOREIGN KEY (curriculum_id) REFERENCES mCurriculum(curriculum_id),
    
    room_id NUMBER,
    CONSTRAINT FK_mOpenCurriculum_mRoom FOREIGN KEY (room_id) REFERENCES mRoom(room_id),
    
    teacher_id NUMBER,
    CONSTRAINT FK_mOpenCurriculum_mTeacher FOREIGN KEY (teacher_id) REFERENCES mTeacher(teacher_id)
);

SELECT * FROM mOpenCurriculum;




--교육생 + 개설과정
create table mOpenCurriStudent (
    open_curriculum_student_id NUMBER PRIMARY KEY,
    open_curriculum_id NUMBER,
    CONSTRAINT FK_mOpenCurriStudent_mOpenCurriculum FOREIGN KEY (open_curriculum_id) REFERENCES mOpenCurriculum(open_curriculum_id),
    student_id NUMBER,
    CONSTRAINT FK_mOpenCurriStudent_mStudent FOREIGN KEY (student_id) REFERENCES mStudent(student_id)
);

SELECT * FROM mOpenCurriStudent;




--개설과목
create table mOpenSubject (
    open_subject_id NUMBER PRIMARY KEY,
    title  VARCHAR2(2000) NOT NULL,
    startdate  date NOT NULL,
    enddate  date NOT NULL,
    
    subject_id NUMBER,
    CONSTRAINT FK_mOpenSubject_mSubject FOREIGN KEY (subject_id) REFERENCES mSubject(subject_id)
);
SELECT * FROM mOpenSubject;




--개설과목 - 개설과정
create table mOpenCurriSubject (
    open_curriculum_subject_id NUMBER PRIMARY KEY,
    open_curriculum_id NUMBER,
    CONSTRAINT FK_mOpenCurriSubject_mOpenCurriculum FOREIGN KEY (open_curriculum_id) REFERENCES mOpenCurriculum(open_curriculum_id),
    open_subject_id NUMBER,
    CONSTRAINT FK_mOpenCurriSubject_mOpenSubject FOREIGN KEY (open_subject_id) REFERENCES mOpenSubject(open_subject_id)
);

SELECT * FROM mOpenCurriSubject;




--자료 : 중복이 발생하나, 성능상 그냥 두겠습니다.
create table mMaterial (
    material_id NUMBER PRIMARY KEY,
    title  VARCHAR2(2000) NOT NULL,
    mcontent  VARCHAR2(4000) NOT NULL,
    memo  VARCHAR2(4000) null,
    
    -- 교사 연결
    teacher_id NUMBER,
    CONSTRAINT FK_mMaterial_mTeacher FOREIGN KEY (teacher_id) REFERENCES mTeacher(teacher_id),
    
    -- 과정연결
    open_curriculum_id NUMBER,
    CONSTRAINT FK_mMaterial_mOpenCurriculum FOREIGN KEY (open_curriculum_id) REFERENCES mOpenCurriculum(open_curriculum_id),
    
    create_date  date NOT NULL
);
SELECT * FROM mMaterial;




--시험
create table mExam (
    exam_id NUMBER PRIMARY KEY,
    title varchar2(2500),
    
    exam_type_id NUMBER,
    CONSTRAINT FK_mExam_mExamType FOREIGN KEY (exam_type_id) REFERENCES mExamType(exam_type_id),
    
    questions NUMBER NULL,
    
    open_curriculum_subject_id NUMBER,
    CONSTRAINT FK_mExam_mOpenCurriSubject FOREIGN KEY (open_curriculum_subject_id) REFERENCES mOpenCurriSubject(open_curriculum_subject_id),
    
    exam_date date
);

SELECT * FROM mExam;


-- 배점
CREATE TABLE distributionOfScores (
    distribution_id NUMBER PRIMARY KEY,
    attendance NUMBER null CHECK (attendance BETWEEN 20 AND 100),
    written NUMBER null CHECK (written BETWEEN 10 AND 80),
    practical NUMBER null CHECK (practical BETWEEN 10 AND 80),
    CONSTRAINT CHECK_total_score CHECK (practical + written + attendance = 100),
    
    -- 시험별로 넣기
    exam_id NUMBER,
    CONSTRAINT FK_distributionOfScores_mExam FOREIGN KEY (exam_id) REFERENCES mExam(exam_id)
);

SELECT * FROM distributionOfScores;
drop table distributionOfScores;

-- 시험 결과
CREATE TABLE mExamResult (
    exam_result_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    CONSTRAINT FK_mExamResult_mStudent FOREIGN KEY (student_id) REFERENCES mStudent(student_id),
    exam_id NUMBER,
    CONSTRAINT FK_mExamResult_mExam FOREIGN KEY (exam_id) REFERENCES mExam(exam_id),
    exam_type_id NUMBER CHECK(exam_type_id IN (1, 2)), --1,2
    CONSTRAINT FK_mExamResult_mExamType FOREIGN KEY (exam_type_id) REFERENCES mExamType(exam_type_id),
    
    score NUMBER CHECK (score BETWEEN 0 AND 100)
);

SELECT * FROM mExamResult;
drop table mExamResult;



--교사가 강의 가능한 과목
create table mAvailableSubject (
    available_subject_id NUMBER PRIMARY KEY,
    teacher_id NUMBER,
    CONSTRAINT FK_mAvailableSubject_mTeacher FOREIGN KEY (teacher_id) REFERENCES mTeacher(teacher_id),
    subject_id NUMBER,
    CONSTRAINT FK_mAvailableSubject_mSubject FOREIGN KEY (subject_id) REFERENCES mSubject(subject_id)
);

SELECT * FROM mAvailableSubject;



--관리자 강사 평가
create table mAdminTeacherEval(
    adminEval_id NUMBER PRIMARY KEY,  -- 관리자 평가 고유 번호
    evalScore NUMBER null CHECK(evalScore between 1 and 5),  -- 평가 점수 (1~5점)
    evalDate date null,  -- 평가 작성일
    evalContent varchar2(500) null,
    
    -- 평가 내용
    manager_id NUMBER NOT NULL,  -- 관리자 고유 번호
    constraint FK_mAdminTeacherEval_mManager foreign key (manager_id) references mManager(manager_id),  -- 관리자 번호
    
    teacher_id NUMBER NOT NULL,  -- 강사 고유 번호
    constraint FK_mAdminTeacherEval_mTeacher foreign key (teacher_id) references mTeacher(teacher_id)  -- 강사 번호
);

--출결테이블
CREATE TABLE mTimeKeeping (
    timekeeping_id NUMBER PRIMARY KEY,
    clock_in date null,
    clock_out date null,
    student_id NUMBER,
    CONSTRAINT FK_mTimeKeeping_mStudent FOREIGN KEY (student_id) REFERENCES mStudent(student_id),
    attendance_type_id NUMBER,
    CONSTRAINT FK_mTimeKeeping_mAttendanceType FOREIGN KEY (attendance_type_id) REFERENCES mAttendanceType(attendance_type_id)
);
SELECT * FROM mTimeKeeping;

SELECT * FROM mStudent;
SELECT * FROM mAttendanceType;

-- 개설과목 + 교재
CREATE TABLE mOpensubjectBook (
    open_subject_book_id NUMBER PRIMARY KEY,
    open_subject_id NUMBER,
    CONSTRAINT fk_mOpensubjectBook_mOpensubject FOREIGN KEY (open_subject_id) REFERENCES mOpensubject(open_subject_id),
    book_id NUMBER,
    CONSTRAINT fk_mOpensubjectBook_mBook FOREIGN KEY (book_id) REFERENCES mBook(book_id)
);

SELECT * FROM mOpensubjectBook;



--수료생 테이블
CREATE TABLE mGradStudent (
    gradStudent_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    CONSTRAINT fk_mGradStudent_mStudent FOREIGN KEY (student_id) REFERENCES mStudent(student_id)
);

SELECT * FROM mGradStudent;


-- 사후관리 테이블
CREATE TABLE mAfterService (
	afterService_id NUMBER PRIMARY KEY,
    gradStudent_id NUMBER,
	CONSTRAINT fk_mAfterService_mGradStudent FOREIGN KEY (gradStudent_id) REFERENCES mGradStudent(gradStudent_id),
	finishDate date null,
	enterDate date null,
    companyName varchar2(2000) null,
	annualSalary NUMBER null,
    region varchar2(3000) null
);

SELECT * FROM mAfterService;


-- 강의실 예약
CREATE TABLE mReservation (

    reservationNUMBER NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    tel VARCHAR2(1500) NOT NULL,
    room_id NUMBER NOT NULL,
    reservationDate DATE NOT NULL,
    reservationTime VARCHAR2(1500) NOT NULL,
    personnel NUMBER NOT NULL CHECK(personnel between 1 and 5),
    
    CONSTRAINT FK_mReservation_mStudent_tel FOREIGN KEY (tel) REFERENCES mStudent(tel),
    CONSTRAINT FK_mReservation_mRoom_room_id FOREIGN KEY (room_id) REFERENCES mRoom(room_id),
    CONSTRAINT FK_mReservation_mHoliday_totalDate FOREIGN KEY (reservationDate) REFERENCES mHoliday(totalDate)

);

SELECT * FROM mReservation;

