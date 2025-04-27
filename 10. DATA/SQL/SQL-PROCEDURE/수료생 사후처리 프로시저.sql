-- 수료생 사후처리

-- 1-1. 전체 수료생 평균연봉 조회
select * from mGradStudent;
select * from mAfterService order by afterService_id;

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE gradAvgSalary (
    p_avg_salary OUT number
) 
AS

BEGIN
    select TRUNC(AVG(annualSalary)) into p_avg_salary
    from mAfterService;
    
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE(' 전체 교육생 평균 연봉: ' || p_avg_salary || '만원');
    DBMS_OUTPUT.PUT_LINE('==================================================');
    
    IF p_avg_salary IS NULL THEN p_avg_salary := 0;
    END IF;
    
    EXCEPTION
        WHEN OTHERS THEN
            -- 다른 예외 처리
            DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다: ' || SQLERRM);
        
END gradAvgSalary;
/

DECLARE
    v_avg_salary NUMBER;  -- OUT 파라미터의 결과를 받을 변수 선언
BEGIN
    gradAvgSalary(v_avg_salary);
END;
/


-- 1-2. 전체 수료생 연도별 평균연봉 조회
CREATE OR REPLACE PROCEDURE p_avg_yearly_salary (
    p_year IN NUMBER,      -- 입력: 조회할 연도
    p_avg_salary OUT NUMBER  -- 출력: 평균 연봉
)
IS
BEGIN

    SELECT AVG(annualSalary) INTO p_avg_salary
    FROM mAfterService
    WHERE EXTRACT(YEAR FROM enterDate) = p_year;
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE(p_year||'년 입사자 평균 연봉: '||TO_CHAR(p_avg_salary, '999,999,999')||'만원');
    DBMS_OUTPUT.PUT_LINE('==================================================');
    IF p_avg_salary IS NULL THEN
        p_avg_salary := 0;
    END IF;
END p_avg_yearly_salary;
/

DECLARE
    v_avg_salary NUMBER;
BEGIN

    p_avg_yearly_salary(2024, v_avg_salary);
    
END;
/


-- 2.1 수료생 수료후 입사일까지 평균 소요일
CREATE OR REPLACE PROCEDURE AfterServiceAvgEnterDate (
    p_avg_enter_date OUT NUMBER
) 
AS
    
BEGIN

    select TRUNC(AVG(enterdate - finishdate)) into p_avg_enter_date
    from mAfterService;
    
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE('전체 교육생 평균 입사 소요일: ' || p_avg_enter_date || '일');
    DBMS_OUTPUT.PUT_LINE('==================================================');
    IF p_avg_enter_date IS NULL THEN p_avg_enter_date := 0;
    END IF;
    
    EXCEPTION

        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다: ' || SQLERRM);
        
END AfterServiceAvgEnterDate;
/

DECLARE
    p_avg_enter_date NUMBER;  
BEGIN
    AfterServiceAvgEnterDate(p_avg_enter_date);
END;
/

--2.2 연도별 수료생 수료후 입사일까지 평균 소요일
CREATE OR REPLACE PROCEDURE AfterServiceYearlyAvgEnterDate (
    p_year IN NUMBER,
    p_yearly_avg_enter_date OUT NUMBER
) 
AS
    
BEGIN
    
    SELECT ROUND(AVG(enterdate - finishdate)) INTO p_yearly_avg_enter_date
    FROM mAfterService
    WHERE EXTRACT(YEAR FROM enterDate) = p_year;
    
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE(p_year|| '년 교육생 평균 입사 소요일: ' || p_yearly_avg_enter_date || '일');
    DBMS_OUTPUT.PUT_LINE('==================================================');
    
    IF p_yearly_avg_enter_date IS NULL THEN p_yearly_avg_enter_date := 0;
    END IF;
    
    EXCEPTION

        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다: ' || SQLERRM);
        
END AfterServiceYearlyAvgEnterDate;
/

DECLARE
    p_yearly_avg_enter_date NUMBER;  
BEGIN
    AfterServiceYearlyAvgEnterDate(2024, p_yearly_avg_enter_date);
END;
/