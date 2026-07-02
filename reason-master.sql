create foreign table if not exists sqlserver_fdw.mcsreasonmaster
(
    CSReasonNo INTEGER,
    Reason VARCHAR(50),
    Code CHAR(6),
    CreatedBy smallint,
    CreatedDate TEXT,
    ModifiedBy smallint,
    ModifiedDate TEXT,
    Inactive BOOLEAN
)
server sqlserver_fdw
options
(
    schema_name 'masterdata',
    table_name 'mCSReasonMaster'
);

insert
	into
	masterdata.reason_master
(
    id,
	reason_name,
	code,
	created_by_id,
	created_date,
	modified_by_id,
	modified_date,
	status_id,
	status_remarks
)
overriding system VALUE
select
	r.CSReasonNo,
	left(TRIM(coalesce(r.Reason, '')), 100),
	left(TRIM(coalesce(r.Code, '')), 6),
	coalesce(r.CreatedBy, 1),
	coalesce(
        migration.parse_sqlserver_datetime(r.CreatedDate),
        now()
    ),
	r.ModifiedBy,
	coalesce(
        migration.parse_sqlserver_datetime(r.ModifiedDate),
        migration.parse_sqlserver_datetime(r.CreatedDate),
        now()
    ),
	case
		when coalesce(r.Inactive, false)
            then 2::smallint
		else 1::smallint
	end,
	case
		when Inactive then 'inactive'
	end as status_remarks
from
	sqlserver_fdw.mcsreasonmaster r;