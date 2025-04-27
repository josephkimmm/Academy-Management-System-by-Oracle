-- 교육생 로그인 프로시저 생성
-- 교육생번호 = 285 , 교육생 = '민희진' 기준

CREATE OR REPLACE PROCEDURE proc_studentLogin (
    p_jumin IN mStudent.jumin%TYPE
) AS
    v_student_id mStudent.student_id%TYPE;
    v_name mStudent.name%TYPE;
    v_tel mStudent.tel%TYPE;
    v_jumin mStudent.jumin%TYPE;


BEGIN

    SELECT student_id, name, tel, jumin 
    INTO v_student_id, v_name, v_tel, v_jumin
    FROM mStudent
    WHERE jumin = p_jumin;
    
    DBMS_OUTPUT.PUT_LINE(' 교육생번호: ' || v_student_id || ', 이름: ' || v_name || ', 전화번호: ' || v_tel);
    DBMS_OUTPUT.PUT_LINE(v_name||'교육생님, 로그인 되었습니다.');
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- 비밀번호가 틀린 경우
            DBMS_OUTPUT.PUT_LINE('잘못된 비밀번호입니다.');
        WHEN OTHERS THEN
            -- 다른 예외 처리
            DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다: ' || SQLERRM);
        
END studentAccount;
/

begin
studentAccount('4722631');
end;
/

-- 로그인 과정 통과 시 -> 교육생 개인 정보출력
select * from vwStudentInfo;

-- 성적 정보는 과목별 목록 형태로 출력
select * from vwStudentResult;

-- 출결 관리 및 출결 조회
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'; -- 출결정보 시 필요
select * from vwStudentAttendance;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD'; -- 출결 정보 출력 후 실행(날짜 set up reset)
-----------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON;

-- 교육생 근태 관리(출근 1회, 퇴근 1회)
-- 교육생번호 = 285 , 교육생 = '민희진' 기준
CREATE OR REPLACE PROCEDURE proc_timekeeping (
    p_student_id NUMBER,
    p_mode VARCHAR2, -- 'IN(입실)', 'OUT(퇴실)', 'LEAVE(외출)', 'SICK(병가)', 'ETC(기타)'
    p_attendance_type_id NUMBER DEFAULT NULL -- 수동 입력 시 사용할 attendance_type_id
)
IS
    v_count NUMBER;
    v_new_id NUMBER;
    v_attendance_type_id NUMBER;
    v_clock_in DATE;
    v_clock_out DATE;
    v_student_name VARCHAR2(1500);
    v_existing_attendance_type_id NUMBER; -- 기존 출결 유형 저장
BEGIN
    -- 교육생 이름 조회
    SELECT name INTO v_student_name
    FROM mStudent
    WHERE student_id = p_student_id;
    
    IF p_mode = 'IN' THEN
        -- 기존에 같은 날 입실 기록이 있는지 확인 (유효성 체크)
        SELECT COUNT(*)
        INTO v_count
        FROM mTimeKeeping
        WHERE student_id = p_student_id
        AND TRUNC(clock_in) = TRUNC(SYSDATE);

        IF v_count = 0 THEN
            SELECT NVL(MAX(timekeeping_id), 0) + 1 INTO v_new_id FROM mTimeKeeping;

            -- 입실시간 09:00을 기준으로 지각, 정상 구분
            IF TO_CHAR(SYSDATE, 'HH24:MI:SS') > '09:00:00' THEN
                v_attendance_type_id := 2; -- 지각
            ELSE
                v_attendance_type_id := 1; -- 정상
            END IF;

            -- 입실 기록 추가
            INSERT INTO mTimeKeeping (timekeeping_id, clock_in, student_id, attendance_type_id)
            VALUES (v_new_id, SYSDATE, p_student_id, v_attendance_type_id);
            
            DBMS_OUTPUT.PUT_LINE('안녕하세요.' || v_student_name || ' 교육생님, 정상 입실 처리 되었습니다.');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_student_name || ' 교육생님, 이미 입실 기록이 있습니다.');
        END IF;

    ELSIF p_mode = 'OUT' THEN
        -- 가장 최근 입실 기록 찾기
        SELECT clock_in, attendance_type_id INTO v_clock_in, v_existing_attendance_type_id
        FROM mTimeKeeping
        WHERE student_id = p_student_id AND clock_out IS NULL
        ORDER BY clock_in DESC
        FETCH FIRST 1 ROW ONLY;

        IF v_clock_in IS NOT NULL THEN
            -- 퇴실 시간 기록
            UPDATE mTimeKeeping 
            SET clock_out = SYSDATE
            WHERE student_id = p_student_id AND clock_out IS NULL;

            -- 조퇴 여부 판별
            IF TO_CHAR(SYSDATE, 'HH24:MI:SS') < '17:50:00' THEN
                v_attendance_type_id := 3; -- 조퇴
            ELSE
                v_attendance_type_id := v_existing_attendance_type_id; -- 정상 퇴실은 기존 출결 상태 유지
            END IF;

            -- 출결 유형 업데이트
            UPDATE mTimeKeeping
            SET attendance_type_id = v_attendance_type_id
            WHERE student_id = p_student_id AND clock_out = SYSDATE;

            DBMS_OUTPUT.PUT_LINE('안녕하세요.' || v_student_name || ' 교육생님, 정상 퇴실 처리 되었습니다.');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_student_name || ' 교육생님, 입실 기록이 없어 퇴실할 수 없습니다.');
        END IF;

    -- 수동 입력 (외출, 병가, 기타)
    ELSIF p_mode IN ('LEAVE', 'SICK', 'ETC') THEN
    
        SELECT COUNT(*)
        INTO v_count
        FROM mTimeKeeping
        WHERE student_id = p_student_id
        AND attendance_type_id IN (4, 5, 6) -- 외출, 병가, 기타
        AND TRUNC(clock_in) = TRUNC(SYSDATE); -- 같은 날에 이미 기록이 있는지 확인

        IF v_count = 0 THEN
            -- 수동 출결 유형 설정 (외출, 병가, 기타)
            IF p_attendance_type_id IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('출결 유형번호를 입력하세요. ("외출" = 4, "병가" = 5, "기타" = 6)');
                RETURN;
            END IF;

            -- 새로운 timekeeping_id 생성
            SELECT NVL(MAX(timekeeping_id), 0) + 1 INTO v_new_id FROM mTimeKeeping;

            -- 출결 기록 추가 (clock_in, clock_out은 NULL)
            INSERT INTO mTimeKeeping (timekeeping_id, clock_in, clock_out, student_id, attendance_type_id)
            VALUES (v_new_id, NULL, NULL, p_student_id, p_attendance_type_id);
            
            DBMS_OUTPUT.PUT_LINE(v_student_name || ' 교육생님, ' || p_mode || ' 처리 완료');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_student_name || ' 교육생님, 오늘은 이미 ' || p_mode || ' 기록이 있습니다.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('잘못된 입력입니다. "IN", "OUT", "LEAVE", "SICK", "ETC" 중 하나를 입력하세요.');
    END IF;

    COMMIT;
END;
/



rollback;

SET SERVEROUTPUT ON;

-- 입실
EXEC proc_timekeeping(285, 'IN');

-- 퇴실
EXEC proc_timekeeping(285, 'OUT');

--수동입력
-- 외출
EXEC proc_timekeeping(285, 'LEAVE', 4);

-- 병가
EXEC proc_timekeeping(285, 'SICK', 5);

-- 기타
EXEC proc_timekeeping(285, 'ETC', 6);


-- 출결 데이터 확인
SELECT * FROM mTimeKeeping WHERE student_id = 285;
DELETE FROM mTimeKeeping WHERE student_id = 285;  

drop procedure proc_timekeeping;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'; -- 출결정보 시 필요
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD'; -- 출결 정보 출력 후 실행(날짜 set up reset)