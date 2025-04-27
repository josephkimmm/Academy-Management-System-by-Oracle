--프로시저
--setting 설정
set serverout on;


--관리자 번호 passwrod 테이블 변경 > 로그인 완 (유효성 검증완)
CREATE OR REPLACE PROCEDURE managerAccount (
    p_password IN mManager.password%TYPE
) IS
    v_manager_id mManager.manager_id%TYPE;
    v_name mManager.name%TYPE;
    v_password mManager.password%TYPE;

BEGIN
    
    SELECT manager_id, name, password 
    INTO v_manager_id, v_name, v_password 
    FROM mManager
    WHERE password = p_password;
        
    DBMS_OUTPUT.PUT_LINE('관리자 번호: ' || v_manager_id || ', 관리자 이름: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('로그인 되었습니다.');
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- 비밀번호가 틀린 경우
            DBMS_OUTPUT.PUT_LINE('잘못된 비밀번호입니다.');
        WHEN OTHERS THEN
            -- 다른 예외 처리
            DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다: ' || SQLERRM);
     
END;
/

begin
managerAccount('222221');
end;
/



-- 교사 로그인 프로시저 생성 완
CREATE OR REPLACE PROCEDURE teacherAccount (
    p_jumin IN mTeacher.jumin%TYPE
) AS
    v_teacher_id mTeacher.teacher_id%TYPE;
    v_name mTeacher.name%TYPE;
    v_tel mTeacher.tel%TYPE;
    v_jumin mTeacher.jumin%TYPE;


BEGIN

    SELECT teacher_id, name, tel, jumin 
    INTO v_teacher_id, v_name, v_tel, v_jumin
    FROM mTeacher
    WHERE jumin = p_jumin;
    
    DBMS_OUTPUT.PUT_LINE('교사 번호: ' || v_teacher_id || ', 이름: ' || v_name || ', 전화번호: ' || v_tel);
    DBMS_OUTPUT.PUT_LINE(v_name||'선생님, 로그인 되었습니다.');
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- 비밀번호가 틀린 경우
            DBMS_OUTPUT.PUT_LINE('잘못된 비밀번호입니다.');
        WHEN OTHERS THEN
            -- 다른 예외 처리
            DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다: ' || SQLERRM);
        
END teacherAccount;
/

begin
teacherAccount('1645784');
end;
/

select * from vwcheck;
BEGIN
managerAccount('22222');
teacherAccount('1645784');
END;


