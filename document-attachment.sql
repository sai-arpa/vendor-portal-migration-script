ALTER TABLE utility.document_attachment  
ALTER COLUMN alt_file_name TYPE VARCHAR(150);

CREATE FOREIGN TABLE sqlserver_fdw.documentsummary
(
    DocNo integer,
    CompanyNo integer,
    FormCode varchar(50),
    Description varchar(500),
    DocName varchar(255),
    DocSize bigint,
    DocType varchar(50),
    ServerFilePath varchar(500),
    DocumentNo varchar(200),
    AttachmentDocumentTypeNo smallint
)
SERVER sqlserver_fdw
OPTIONS
(
    schema_name 'utility',
    table_name 'DocumentSummary'
);

INSERT INTO utility.document_attachment
(
    id,
    path_name,
    original_file_name,
    alt_file_name,
    file_type,
    file_size,
    attachment_context_id,
    status_id,
    created_date,
    created_by_id
)
OVERRIDING SYSTEM VALUE
SELECT
    dts.DocNo,
    TRIM(dts.ServerFilePath) as path_name,
    TRIM(dts.DocName) as original_file_name,
    TRIM(dts.DocName) as alt_file_name,
    LOWER(
        split_part(TRIM(dts.DocName), '.', array_length(string_to_array(TRIM(dts.DocName), '.'), 1))
    ) AS file_type,
    COALESCE(dts.DocSize, 0) as file_size,
    gac.id as attachment_context_id,
    1 as status_id,
    now() as created_date,
    1 as created_by_id
FROM sqlserver_fdw.documentsummary dts
INNER JOIN sqlserver_fdw.formMaster fm
ON fm.formcode = dts.formcode
INNER JOIN migration.form_mapping mfm
ON fm.formno = mfm.old_form_id
INNER JOIN globaldata.attachment_context gac
ON mfm.new_form_id = gac.form_id AND gac.context_name LIKE '%header%';



INSERT INTO utility.document_attachment_detail
(
    attachment_id,
    doc_main_id,
    attached_to_doc_id,
    form_id,
    created_by_id,
    created_date
)
SELECT
    da.id AS attachment_id,
    dts.DocumentNo::INTEGER AS doc_main_id,
    REPLACE(
        REPLACE(
            gac.doc_id_format,
            '{formCode}',
            nf.form_code
        ),
        '{Id}',
        TRIM(dts.DocumentNo)
    ) AS attached_to_doc_id,
    mfm.new_form_id AS form_id,
    1 AS created_by_id,
    NOW() AS created_date
FROM sqlserver_fdw.documentsummary dts
INNER JOIN utility.document_attachment da
    ON da.id = dts.DocNo
INNER JOIN sqlserver_fdw.formMaster fm
    ON fm.formcode = dts.formcode
INNER JOIN migration.form_mapping mfm
    ON fm.formno = mfm.old_form_id
INNER JOIN globaldata.form_master nf
    ON nf.id = mfm.new_form_id
INNER JOIN globaldata.attachment_context gac
    ON gac.id = da.attachment_context_id;
 