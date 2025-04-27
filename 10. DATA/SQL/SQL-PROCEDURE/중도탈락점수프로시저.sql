-- 중도탈락된 수강생 기준 필기, 실기 점수 실데이터를 null 로 변경하는 프로시저 작성하기

   
CREATE OR REPLACE PROCEDURE DropoutStudentScoreUpdate
IS
BEGIN
    -- 중도탈락된 교육생이 dropout_date 이후에 본 시험 점수를 NULL로 업데이트
    UPDATE mExamResult er
    SET er.score = NULL
    WHERE EXISTS (
        SELECT 1
        FROM mStudent s
        JOIN mExam e ON er.exam_id = e.exam_id
        WHERE er.student_id = s.student_id
        AND s.dropout_date IS NOT NULL
        AND e.exam_date > s.dropout_date -- dropout_date 이후의 시험만 반영
    );

    COMMIT;
END;
/

begin
DropoutStudentScoreUpdate;
end;
/    


-- 중도탈락생 시험 점수 조회
SELECT er.student_id, er.exam_id, er.score, s.dropout_date, e.exam_date
FROM mExamResult er
JOIN mStudent s ON er.student_id = s.student_id
JOIN mExam e ON er.exam_id = e.exam_id
WHERE s.dropout_date IS NOT NULL
AND e.exam_date > s.dropout_date;
