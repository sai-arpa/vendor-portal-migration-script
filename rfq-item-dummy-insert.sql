BEGIN;

INSERT INTO purchase.pur_rfq_item_detail
(
    id,
    rfq_id,
    line_no,
    item_id,
    make_id,
    hsn_code,
    tech_specification,
    unit_id,
    qty,
    cs_booking_qty,
    balance_qty,
    remarks,
    status_id
)
overriding system value
VALUES%%
(
    275703,
    58906,
    20,
    6,
    669,
    NULL,
    'DUMMY RFQ ITEM DETAIL FOR AUCTION QUOTATION MIGRATION',
    71,
    1,
    0,
    1,
    'Auto generated dummy record during quotation item migration',
    9
);

COMMIT;