
DO $$
declare item record;
begin for item in select * from public."Providers" 
   loop
     INSERT INTO public."TaxPayer"(
	"tax_payerId", tax_payer_company_name, tax_payer_trade_name, tax_payer_about, col1, col2, col3, col4, created_at, tax_payer_state, tax_payer_payment_status)
	VALUES (item.id, item.name, item.name, '', '', '', '', '', to_char(current_timestamp,'dd/mm/yyyy'), 'ACTIVO', 'NORMAL');
   end loop;
end;
$$

select * from public."Providers" where id = '01001081726';

delete from public."Providers" where id = '01001081726';

select to_char(current_timestamp,'dd/mm/yyyy');
	
	
-- View: public.SalesView

DROP VIEW public."SalesView";

CREATE VIEW public."SalesView"
 AS
 SELECT s.id,
    s."totalInForeignCurrency",
    s.rate,
    s."rncOrId",
        CASE
            WHEN pr.name IS NULL THEN tp.tax_payer_company_name
            ELSE pr.name
        END AS "clientName",
    s."idType",
    s."conceptId",
    s."invoiceNcfTypeId",
    s."invoiceNcf",
    s."invoiceNcfModifedTypeId",
    s."invoiceNcfModifed",
    s."typeOfIncome",
    s."invoiceNcfDate",
    s."retentionDate",
    s.total,
    s.tax,
    s.total + s.tax AS "totalGeneral",
    s."taxRetentionOthers",
    s."perceivedTax",
    s."retentionOthers",
    s."perceivedISR",
    s."selectiveConsumptionTax",
    s."otherTaxesFees",
    s."legalTipAmount",
    s.effective,
    s."checkTransferDeposit",
    s."debitCreditCard",
    s."saleOnCredit",
    s."vouchersOrGiftCertificates",
    s.swap,
    s."otherFormsOfSales",
    s."companyId",
    tm.name AS "typeOfIncomeName",
    s."authorId",
    upper(us.name) AS "authorName",
    c.name AS "conceptName"
   FROM "Sale" s
     JOIN "TypeOfIncome" tm ON tm.id = s."typeOfIncome"
     LEFT JOIN "User" us ON us.id = s."authorId"
     LEFT JOIN "TaxPayer" tp ON tp."tax_payerId" = s."rncOrId"
     LEFT JOIN "Providers" pr ON pr.id = s."rncOrId"
     LEFT JOIN "Concept" c ON c.id = s."conceptId";

ALTER TABLE public."SalesView"
    OWNER TO josue;


