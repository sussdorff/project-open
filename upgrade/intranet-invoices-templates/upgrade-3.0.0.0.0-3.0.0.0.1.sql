
-- -------------------------------------------------------------
-- Helper function

create or replace function im_invoice_nr_from_id (integer)
returns varchar as '
DECLARE
        p_id    alias for $1;
        v_name  varchar(50);
BEGIN
        select i.invoice_nr
        into v_name
        from im_invoices i
        where invoice_id = p_id;

        return v_name;
end;' language 'plpgsql';


---------------------------------------------------
-- not being used yet (V3.0.0).
-- reserved for adding a reference nr for items
-- from a catalog or similar
alter table im_invoice_items add
        item_nr                 varchar(200)
;


---------------------------------------------------
-- include in VAT calculation?
alter table im_invoice_items add
        apply_vat_p             char(1)
                                constraint im_invoices_apply_vat_p
                                check (apply_vat_p in ('t','f'))
;

-- set the default to "t" to maintain backward compatibility
-- to pre-V3.0.0 versions
alter table im_invoice_items
alter column apply_vat_p
set default 't';

-- default value doesn't affect existing columns, so set them explicitely
update im_invoice_items
set apply_vat_p = 't';


