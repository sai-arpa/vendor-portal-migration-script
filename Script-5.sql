select distinct apm.status_id, s.status_name   from utility.approval_process_main apm 
left join globaldata.status s
on s.id = apm.status_id