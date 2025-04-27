SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE procReservationCreate(
    ptel IN VARCHAR2,
    proom_id IN NUMBER,
    preservationDate IN DATE,
    preservationTime IN DATE,
    ppersonnel IN NUMBER
)
IS
    vcountTel number; -- Tel 유효성 검사용
    vcheckDate mHoliday.dateclassfication%type; -- 평일, 주말, 공휴일 확인용
    vcheckHour number; -- 시간 확인
    vcountSame number; -- 중복 확인
    vname mReservation.name%type; -- 이름 불러오기
BEGIN
    
    select count(*)
        INTO vcountTel
            from mStudent
                where tel = ptel;
    
    IF vcountTel = 0 then -- tel로 학원생인지 확인 
        DBMS_OUTPUT.PUT_LINE('등록된 교육생이 아닙니다');
        RETURN;
    END IF;
    
    IF preservationDate < sysdate OR preservationDate > (sysdate +7) THEN -- 당일부터 7일 뒤 까지 예약가능 
        DBMS_OUTPUT.PUT_LINE('예약 가능한 날짜가 아닙니다');
        RETURN;
    END IF;
    
    SELECT dateClassfication
        INTO vcheckDate
            FROM mHoliday 
                WHERE preservationDate = totalDate;
                
    SELECT TO_NUMBER(TO_CHAR(preservationTime, 'HH24')) 
        INTO vcheckHour
            FROM dual;
    
    IF vcheckDate = '공휴일' THEN -- 공휴일 확인
        DBMS_OUTPUT.PUT_LINE('공휴일에는 예약이 불가능합니다.');
        RETURN;
    ELSIF vcheckDate = '주말' THEN -- 주말 확인
        IF vcheckHour < 09 and vcheckHour > 18 THEN
            DBMS_OUTPUT.PUT_LINE('주말에는 09:00 ~ 18:00에만 이용가능합니다.');
            RETURN;
        END IF;
    ELSIF vcheckDate = '평일' THEN -- 평일 확인
        IF vcheckHour < 18 and vcheckHour > 22 THEN
            DBMS_OUTPUT.PUT_LINE('평일에는 18:00 ~ 22:00에만 이용가능합니다.');
            RETURN;
        END IF;
    END IF;

    SELECT name -- 이름불러오기
        INTO vname
            FROM mStudent
                WHERE tel = ptel;

    SELECT count(*)
        INTO vcountSame
            FROM mReservation
                WHERE proom_id = room_id and 
                        preservationDate = reservationDate and 
                        TO_CHAR(preservationTime, 'HH24:MI') 
                        || ' ~ ' || 
                        TO_CHAR(preservationTime + INTERVAL '1' HOUR, 'HH24:MI') = reservationTime;

    IF vcountSame > 0 THEN
        DBMS_OUTPUT.PUT_LINE('예약 할 수 없습니다.');
        DBMS_OUTPUT.PUT_LINE('다른 시간 대를 선택 해주세요.');
        RETURN;
    END IF;


    INSERT INTO mReservation(reservationNumber, name, tel, room_id, reservationDate, reservationTime, personnel)
    VALUES((select count(*) from mReservation) + 1, 
            vname, 
            ptel, 
            proom_id, 
            preservationDate, 
            TO_CHAR(preservationTime, 'HH24:MI') 
                || ' ~ ' || 
            TO_CHAR(preservationTime + INTERVAL '1' HOUR, 'HH24:MI'),
            ppersonnel);
    
    commit;
    
    DBMS_OUTPUT.PUT_LINE('예약이 완료되었습니다');
    
END procReservationCreate;
/

BEGIN
    procReservationCreate(                      
        '010-3737-2375',                        -- 번호
        6,                                      -- 강의실 번호
        TO_DATE('2025-02-13', 'YYYY-MM-DD'),    --예약날짜
        TO_DATE('19:00', 'HH24:MI'),            -- 예약 시간 (평일: 18~22시, 주말: 09~18시)
        4                                       -- 예약 인원
    );
END;
/

