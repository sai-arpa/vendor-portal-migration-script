-- vendor type fix --

UPDATE mvld
SET vendorTypeNo = 3
FROM masterdata.mVendorLocationDetail AS mvld
WHERE mvld.vendorTypeNo NOT IN (
    SELECT mvtm.vendorTypeNo
    FROM masterdata.mVendorTypeMaster AS mvtm
);

-- city no fix --

UPDATE mvld
SET cityno = 268, stateno=60, countryno=3
FROM masterdata.mVendorLocationDetail AS mvld
WHERE mvld.cityno NOT IN (
    SELECT mvtm.cityno
    FROM masterdata.mcitymaster AS mvtm
);

-- business type no fix --
UPDATE mvld
SET businesstypeno=9
FROM masterdata.mVendorLocationDetail AS mvld
WHERE mvld.BusinessTypeNo  NOT IN (
    SELECT mvtm.VendorBusinessTypeNo
    FROM masterdata.mVendorBusinessTypeMaster AS mvtm
);


-- region no fix --
UPDATE mvld
SET regionno=7
FROM masterdata.mVendorLocationDetail AS mvld
WHERE mvld.RegionNo   NOT IN (
    SELECT mvtm.regionno
    FROM masterdata.mRegionMaster AS mvtm
);

select * from masterdata.mLocationMaster mlm 
select distinct otherchargeno from purchase.revisedQuotationOtherChargeDetail

select * from globaldata.quotationothercharges
select top 100 im.DocumentNoYearly   from purchase.POAmendmentMain im order by im.DocumentNoYearly desc

SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(DocumentNoYearly, 0, LEN(DocumentNoYearly)) AS INT)), 0) + 1
FROM purchase.poamendmentmain
WHERE TRY_CAST(SUBSTRING(DocumentNoYearly, 6, LEN(DocumentNoYearly)) AS INT) IS NOT NULL;


SELECT ISNULL(MAX(TRY_CAST(DocumentNoYearly AS INT)), 0) + 1
FROM purchase.poamendmentmain;
-------- Rought work -----------

select distinct vendortypeno from masterdata.mVendorLocationDetail order by VendorTypeNo

select cm.cityno, sm.StateNo, ctm.countryNo from masterdata.mcitymaster cm
inner join masterdata.mstatemaster sm
on sm.StateNo   = cm.StateNo  
inner join masterdata.mcountrymaster ctm
on ctm.CountryNo = sm.CountryNo 


select * from masterdata.mVendorBusinessTypeMaster mvbtm 

--238 60 3