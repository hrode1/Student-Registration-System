create or replace trigger drop_from_class_trigger
after delete on enrollments
for each row
declare
log_user varchar2(12);
log_table_name varchar2(12) default 'enrollments'; 
log_operation varchar2(12) default 'delete';
log_b# char(4);
old_classid char(5);
log_concat varchar2(30);

begin
log_b# := :old.b#;
old_classid:= :old.classid;
log_concat := (log_b#||','||old_classid);

select user into log_user from dual;
 insert into logs values(sequence_log.nextval,log_user,sysdate,log_table_name,log_operation,log_concat);
 update classes set class_size=class_size-1 where classid=old_classid;
 end;
/