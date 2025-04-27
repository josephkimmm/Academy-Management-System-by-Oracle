-- 자료 전체 뷰

create or replace view vwMaterial
as
SELECT m.title as "자료명", m.mcontent as "내용", m.memo as "메모", t.name as 교사명, c.title as 강의명, c.open_curriculum_id, t.teacher_id FROM mmaterial m
    inner join mteacher t
    on m.teacher_id = t.teacher_id
        inner join mopencurriculum  c
            on m.open_curriculum_id = c.open_curriculum_id;



--자료명으로 관련 자료 모두 조회
select 자료명, 내용, 메모, 교사명, 강의명 from vwmaterial
where 자료명 like '%AWS%';

--강의명으로 관련 자료 모두 조회
select 자료명, 내용, 메모, 교사명, 강의명 from vwmaterial
where 강의명 like '%AWS와 Client%';

--선생님별 조회
select 자료명, 내용, 메모, 교사명, 강의명 from vwmaterial
where 교사명 like '김미숙';

--생성
select * from mmaterial;

savepoint sp_insert_1;

insert into mmaterial values ((select count(*) from mmaterial) + 1, '하하', '호호', '히히', 1, 1, sysdate);

commit;

savepoint sp_insert_2;

insert into mmaterial values ((select count(*) from mmaterial) + 1, '하하', '호호', '히히', 1, 10, sysdate);

rollback to sp_insert_2;

rollback;

select * from mmaterial;

delete from mmaterial
    where title = 'AWS 공식 문서';

commit;

--삭제
delete from mmaterial
    where title = 'AWS 공식 문서';
    
    
CREATE OR REPLACE TRIGGER mmaterial_validation
BEFORE INSERT OR UPDATE OR DELETE ON mmaterial
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- mteacher와 mopencurriculum의 관계 검증 (vwMaterial 활용)
    SELECT COUNT(*) INTO v_count FROM vwMaterial
    WHERE teacher_id = :NEW.teacher_id AND open_curriculum_id = :NEW.open_curriculum_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, '현재 교사가 진행하는 과정이 아닙니다.');
    END IF;
END;
/
