set serveroutput on
create or replace package StudentRegistrationSystem as
   procedure displayStudents(c_dbcursor OUT SYS_REFCURSOR);
   procedure displayTAs(c_dbcursor OUT SYS_REFCURSOR);
   procedure displayCourses(c_dbcursor OUT SYS_REFCURSOR);
   procedure displayClasses(c_dbcursor OUT SYS_REFCURSOR);
   procedure displayEnrollments(c_dbcursor OUT SYS_REFCURSOR);
   procedure displayPrerequisites(c_dbcursor OUT SYS_REFCURSOR);
   procedure displayLogs(c_dbcursor OUT SYS_REFCURSOR);
   procedure get_TA_of_class(class_id in classes.classid%type,c_dbcursor OUT SYS_REFCURSOR,status out number);
   procedure getPreReq(deptCode in prerequisites.dept_code%type, courseNum in prerequisites.course#%type, c_dbcursor OUT SYS_REFCURSOR, status out number);
   procedure checkIfStudentIsPresent(bnum in students.B#%type, status out number);
   procedure checkIfClassIsPresent(class_Id in classes.classid%type, status out number);
   procedure getClassSemNYear(class_Id in classes.classid%type, semester1 out classes.semester%type, year1 out classes.year%type, 
   limit1 out classes.limit%type, class_size1 out classes.class_size%type);
   procedure getEnrollments (bnum in enrollments.B#%type, class_Id in enrollments.classid%type, status out number);
   procedure isStudentOverloaded (bnum in enrollments.B#%type, cnt out number);
   procedure checkStudentEnrollment(bnum in enrollments.B#%type,class_Id in enrollments.classid%type, status out number);
   procedure prereqViolation(bnum in enrollments.B#%type, class_Id in enrollments.classid%type, status out number);
   procedure totalEnrollmentForStudent(bnum in enrollments.B#%type, status out number);
   procedure dropStudentFromClass(bnum in enrollments.B#%type, class_Id in enrollments.classid%type);
   procedure deleteStudentFromStudentTable(bnum in enrollments.B#%type);
   procedure checkPreReqCondition(bnum in enrollments.B#%type, class_Id in enrollments.classid%type, status out number);
   procedure enrollStudentInClass(bnum in enrollments.B#%type, class_Id in enrollments.classid%type);
   procedure checkIfClasshasTA(class_Id in classes.classid%type, status out number);
   end;
   /
   show errors
create or replace package body StudentRegistrationSystem as
  procedure displayStudents (c_dbcursor OUT SYS_REFCURSOR) is
   BEGIN
   OPEN c_dbcursor for 
	SELECT * FROM Students;
   end;
  procedure displayTAs (c_dbcursor OUT SYS_REFCURSOR) is
   BEGIN
   OPEN c_dbcursor for 
	SELECT * FROM tas;
   end;
  procedure displayCourses (c_dbcursor OUT SYS_REFCURSOR) is
   BEGIN
   OPEN c_dbcursor for 
	SELECT * FROM courses ;
   end;
  procedure displayClasses (c_dbcursor OUT SYS_REFCURSOR) is
   BEGIN
   OPEN c_dbcursor for 
	SELECT * FROM classes;
   end;
  procedure displayEnrollments (c_dbcursor OUT SYS_REFCURSOR) is
   BEGIN
   OPEN c_dbcursor for 
	SELECT * FROM enrollments;
   end;
  procedure displayPrerequisites (c_dbcursor OUT SYS_REFCURSOR) is
   BEGIN
   OPEN c_dbcursor for 
	SELECT * FROM prerequisites;
   end;
  procedure displayLogs(c_dbcursor OUT SYS_REFCURSOR) is
   BEGIN
   OPEN c_dbcursor for 
	SELECT * FROM logs;
   end;
  procedure getEnrollments (bnum in enrollments.B#%type, class_Id in enrollments.classid%type, status out number) is
  bn enrollments.B#%type; 
  cls enrollments.classid%type; 
   BEGIN
	SELECT B#, classid into bn, cls FROM enrollments where B#=bnum  and classid=class_Id;
	status := 1;
    exception
        when no_data_found then status := 0;

   end;

  procedure isStudentOverloaded (bnum in enrollments.B#%type, cnt out number) is
   BEGIN
	select count(*) into cnt from enrollments e, classes c where e.classid = c.classid and B#=bnum and c.semester like 'Fall' and c.year = 2018;
   end;

  procedure checkIfStudentIsPresent(bnum in students.B#%type, status out number) is
  bn students.B#%type; 
   BEGIN 
	select B# into bn from students where B#=bnum;
	status := 1;
    exception
        when no_data_found then status := 0;
   end;
  procedure checkStudentEnrollment(bnum in enrollments.B#%type,class_Id in enrollments.classid%type, status out number) is 
  cls enrollments.classid%type; 
  BEGIN 
	select classid into cls from enrollments WHERE B#=bnum and classid=class_Id;
	status := 1;
    exception
        when no_data_found then status := 0;
   end;

  procedure totalEnrollmentForStudent(bnum in enrollments.B#%type, status out number) is 
  BEGIN 
	select count(B#) into status from enrollments WHERE B#=bnum;
    exception
        when no_data_found then status := 0;
   end;

  procedure prereqViolation(bnum in enrollments.B#%type, class_Id in enrollments.classid%type, status out number) is
  cnt number; 
  BEGIN 
	select count(*) into cnt from prerequisites where course# in (select distinct c.course# from classes c, enrollments e where c.classid!=class_Id and e.B#=bnum ) 
	and pre_course# in (select distinct c.course# from classes c, enrollments e where c.classid=class_Id and e.B#=bnum )
	and dept_code in (select distinct c.dept_code from classes c, enrollments e where c.classid!=class_Id and e.B#=bnum ) 
	and pre_dept_code in (select distinct c.dept_code from classes c, enrollments e where c.classid=class_Id and e.B#=bnum );
	status := 1;
    exception
        when no_data_found then status := 0;
   end;

  procedure checkIfClassIsPresent(class_Id in classes.classid%type, status out number) is
  cls classes.classid%type; 
  BEGIN 
	select classid into cls from classes WHERE classid=class_Id;
	status := 1;
    exception
        when no_data_found then status := 0;
   end;

  procedure checkIfClasshasTA(class_Id in classes.classid%type, status out number) is
  ta classes.ta_B#%type; 
  BEGIN 
	select ta_B# into ta from classes where classid=class_Id;
	IF ta IS NULL THEN
		status := 1;
	END IF;
    exception
        when no_data_found then status := 0;
   end;

  procedure getClassSemNYear(class_Id in classes.classid%type, semester1 out classes.semester%type, 
   year1 out classes.year%type, limit1 out classes.limit%type, class_size1 out classes.class_size%type) is
   BEGIN 
	select semester, year, limit, class_size into semester1, year1, limit1, class_size1 from classes WHERE classid=class_Id;
   end;

  procedure getPreReq(deptCode in prerequisites.dept_code%type, courseNum in prerequisites.course#%type, c_dbcursor OUT SYS_REFCURSOR, status out number) is
   BEGIN
   OPEN c_dbcursor for 
	select (pre_dept_code||' '|| pre_course#) as course_id from prerequisites where dept_code = deptCode and course# = courseNum or course# in 
	(select pre_course# from prerequisites p where dept_code = deptCode and course# = courseNum or course# in 
	(select pre_course# from prerequisites where dept_code = deptCode and course# = p.pre_course#));
	status := 1;
    exception
        when no_data_found then status := 0;
    end;

  procedure checkPreReqCondition(bnum in enrollments.B#%type, class_Id in enrollments.classid%type, status out number) is
  cnt number; 
  BEGIN 
	select count(*) into cnt from enrollments where B# = bnum and classid in (select classid from classes where course# in (select pre_course# from prerequisites where course# 
	in (select course# from classes where classid=class_Id) and dept_code in (select dept_code from classes where classid=class_Id)) 
	and dept_code in (select pre_dept_code from prerequisites where course# in (select course# from classes where classid=class_Id) 
	and dept_code in (select dept_code from classes where classid=class_Id))) and lgrade in ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C');
	status := 1;
    exception
        when no_data_found then status := 0;
   end;

  procedure get_TA_of_class(class_id in classes.classid%type,c_dbcursor OUT SYS_REFCURSOR,status out number) is
   begin
   OPEN c_dbcursor for
        select c.ta_B#, first_name, last_name
	from students s, classes c where s.B#=c.ta_B# and c.classid = class_id;        
	status := 1;
    exception
        when no_data_found then status := 0;
    end;

  procedure dropStudentFromClass(bnum in enrollments.B#%type, class_Id in enrollments.classid%type) is
   begin
        delete from enrollments where B#=bnum and classid= class_id; 
    end;

  procedure deleteStudentFromStudentTable(bnum in enrollments.B#%type) is
   begin
        delete from students where B#=bnum; 
    end;

  procedure enrollStudentInClass(bnum in enrollments.B#%type, class_Id in enrollments.classid%type) is
   begin
        insert into enrollments values (bnum, class_Id, null); 
    end;

end;
   /
show errors
