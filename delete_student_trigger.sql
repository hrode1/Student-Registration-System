create or replace trigger delete_student_trigger
after delete on students
for each row
declare
log_user varchar2(12);
log_table_name varchar2(12) default 'students'; 
log_operation varchar2(12) default 'delete';
log_b# char(4);
begin
log_b# := :old.b#;
select user into log_user from dual;
  insert into logs values(sequence_log.nextval,log_user,sysdate,log_table_name,log_operation,log_b#);
  delete from enrollments where b#=log_b#;
 
  end;
/ 