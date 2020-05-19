create or replace trigger enroll_student_trigger
after insert on enrollments
for each row
declare
log_user varchar2(12);
log_table_name varchar2(12) default 'enrollments'; 
log_operation varchar2(12) default 'insert';
log_b# char(4);
log_classid char(5);
log_concat varchar2(30);
begin
log_b# := :new.b#;
log_classid := :new.classid;
log_concat := (log_b#||','||log_classid);
select user into log_user from dual;
 insert into logs values(sequence_log.nextval,log_user,sysdate,log_table_name,log_operation,log_concat);
 update classes set class_size=class_size+1 where classid=log_classid;
 end;
/