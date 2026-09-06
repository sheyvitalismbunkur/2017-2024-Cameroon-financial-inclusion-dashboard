IF OBJECT_ID('dbo.vw_findex_trend', 'V') IS NOT NULL
    DROP VIEW dbo.vw_findex_trend;
GO

CREATE VIEW dbo.vw_findex_trend AS
SELECT
    year,
    SUM(weight) AS total_weight,
    SUM(CASE WHEN has_account = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_any_account,
    SUM(CASE WHEN has_bank_account = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_bank_account,
    SUM(CASE WHEN has_mobile_money = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_mobile_money,
    SUM(CASE WHEN did_save = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_saved,
    SUM(CASE WHEN did_borrow = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_borrowed
FROM dbo.findex_cameroon_panel
GROUP BY year;
GO

/* ---------------------------------------------------------
   STEP 4: Weighted breakdown by segment AND year
   (Gender / area / income cut, trended across years)
   --------------------------------------------------------- */
IF OBJECT_ID('dbo.vw_findex_trend_by_gender', 'V') IS NOT NULL
    DROP VIEW dbo.vw_findex_trend_by_gender;
GO

CREATE VIEW dbo.vw_findex_trend_by_gender AS
SELECT
    year,
    gender,
    SUM(weight) AS total_weight,
    SUM(CASE WHEN has_account = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_account,
    SUM(CASE WHEN has_mobile_money = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_mobile_money
FROM dbo.findex_cameroon_panel
WHERE gender IS NOT NULL
GROUP BY year, gender;
GO

IF OBJECT_ID('dbo.vw_findex_trend_by_income', 'V') IS NOT NULL
    DROP VIEW dbo.vw_findex_trend_by_income;
GO

CREATE VIEW dbo.vw_findex_trend_by_income AS
SELECT
    year,
    income_quintile,
    SUM(weight) AS total_weight,
    SUM(CASE WHEN has_account = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_account,
    SUM(CASE WHEN has_mobile_money = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_mobile_money
FROM dbo.findex_cameroon_panel
WHERE income_quintile IS NOT NULL
GROUP BY year, income_quintile;
GO

/* Note: area_type (urban/rural) is NULL for 2017 — only 2021 & 2024
   have this field. Filter WHERE area_type IS NOT NULL for that view. */
IF OBJECT_ID('dbo.vw_findex_trend_by_area', 'V') IS NOT NULL
    DROP VIEW dbo.vw_findex_trend_by_area;
GO

CREATE VIEW dbo.vw_findex_trend_by_area AS
SELECT
    year,
    area_type,
    SUM(weight) AS total_weight,
    SUM(CASE WHEN has_account = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_account,
    SUM(CASE WHEN has_mobile_money = 1 THEN weight ELSE 0 END) / SUM(weight) * 100 AS pct_mobile_money
FROM dbo.findex_cameroon_panel
WHERE area_type IS NOT NULL
GROUP BY year, area_type;
GO

/* ---------------------------------------------------------
   STEP 5: Row-level clean view for Power BI import
   (Power BI will do most slicing itself via DAX, but this
   view is handy for spot-checks / drillthrough tables)
   --------------------------------------------------------- */
IF OBJECT_ID('dbo.vw_findex_clean', 'V') IS NOT NULL
    DROP VIEW dbo.vw_findex_clean;
GO

CREATE VIEW dbo.vw_findex_clean AS
SELECT
    year, respondent_id, weight, gender, age, education, income_quintile,
    CASE employment_status WHEN 1 THEN 'In workforce' WHEN 0 THEN 'Out of workforce' END AS employment_status,
    area_type, has_account, has_bank_account, has_mobile_money, has_digital_account,
    did_save, did_borrow, owns_mobile_phone, uses_internet,
    receives_pension, receives_remittances, any_digital_payment
FROM dbo.findex_cameroon_panel;
GO
