-- 관리자 평가 조회

CREATE OR REPLACE VIEW v_admin_teacher_eval AS
SELECT 
    a.adminEval_id AS "관리자 평가 번호", 
    m.name AS "관리자 이름", 
        t.name AS "강사 이름",
    a.evalScore AS "점수", 
    a.evalDate AS "작성일", 
    a.evalContent AS "평가 내용"
FROM 
    mAdminTeacherEval a
JOIN 
    mManager m ON a.manager_id = m.manager_id
JOIN 
    mTeacher t ON a.teacher_id = t.teacher_id;

SELECT * FROM v_admin_teacher_eval;


-- 관리자 평가 추가
INSERT INTO mAdminTeacherEval (adminEval_id, evalScore, evalDate, evalContent, manager_id, teacher_id)
VALUES (51, 4, TO_DATE('2025-02-07', 'YYYY-MM-DD'), '강사님은 수업 자료 준비가 잘 되어 있었고, 교육생들이 매우 만족스러워 했습니다.', 1, 10);

-- 관리자 평가 수정
UPDATE mAdminTeacherEval
SET evalScore = 5,
    evalContent = '강사님은 수업을 매우 체계적으로 진행하였고, 교육생들에게 많은 도움이 되었습니다.'
WHERE adminEval_id = 51;

-- 관리자 평가 삭제
DELETE FROM mAdminTeacherEval WHERE adminEval_id = 51;

--결과 조회
SELECT * FROM v_admin_teacher_eval;

