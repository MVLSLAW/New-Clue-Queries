--Grabs the count of small claims from all counties in Maryland
--Used for the AG's Dashboard
--Created 90% by Manny 10% by Matthew Stubenberg
--Non MDEC Counties
SELECT yr, mo, initcap(replace(cnty,'''','')) as cnty,count(t1."caseNumber") as cases
	from(
		SELECT extract(YEAR FROM max(c."filingDate")) as yr, extract(MONTH FROM max(c."filingDate")) as mo,
		c."caseNumber", 
		replace(substring(c."courtSystem", '([A-Za-z]+\s?[a-zA-Z'']*\s)(COUNTY|CITY|County|City)'),'FOR ','') as cnty
		FROM
		"Cases" as c
		WHERE 
		c."parser" = 'districtCivil' 
		and c."filingDate" >= '2020-01-01' and c."filingDate" < CURRENT_DATE
		and c."caseType" = 'CONTRACT'
		GROUP BY cnty,c."caseNumber") as t1
GROUP BY yr, ROLLUP(mo, cnty)
union
--MDEC Counties
--We cut out Moco and PG Because they show up in the query above.
SELECT 
extract(YEAR FROM c."filingDate") as yr, extract(MONTH FROM c."filingDate") mo, 
replace(substring(c."courtSystem", '[A-Za-z]+\s?[a-zA-Z'']*\sCounty'),'For ','') as cnty,
count(*) as cases
FROM
	"Cases" as c
	WHERE 
	c."court" LIKE '%District Court'
	and c."caseType" in ('Contract - Small Claims', 'Contract - Large Claims', 'Contract','CONTRACT')
	and c."courtSystem" not in ('DISTRICT COURT FOR PRINCE GEORGE''S COUNTY - CIVIL SYSTEM', 'DISTRICT COURT FOR MONTGOMERY COUNTY - CIVIL SYSTEM')
	and c."filingDate" BETWEEN '2020-01-01' AND CURRENT_DATE
	GROUP BY cnty,yr, mo
order by yr,mo,cnty