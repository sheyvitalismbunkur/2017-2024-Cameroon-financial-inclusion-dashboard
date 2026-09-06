# Power BI DAX Measures

Account Ownership % =
DIVIDE(
    CALCULATE(
        SUM(vw_findex_clean[weight]),
        vw_findex_clean[has_account] = TRUE()
    ),
    SUM(vw_findex_clean[weight])
)


Account % Prior Round =
VAR PriorYear =
    LOOKUPVALUE(
        SurveyRound[prior_round_year],
        SurveyRound[year],
        MAX(vw_findex_clean[year])
    )
RETURN
CALCULATE(
    [Account Ownership %],
    ALL(vw_findex_clean[year]),
    vw_findex_clean[year] = PriorYear
)


Account % Change (pp) =
[Account Ownership %] - [Account % Prior Round]


Borrowing Rate % =
DIVIDE(
    CALCULATE(
        SUM(vw_findex_clean[weight]),
        vw_findex_clean[did_borrow] = TRUE
    ),
    SUM(vw_findex_clean[weight])
)


Formal Bank Account % =
DIVIDE(
    CALCULATE(
        SUM(vw_findex_clean[weight]),
        vw_findex_clean[has_bank_account] = TRUE()
    ),
    SUM(vw_findex_clean[weight])
)


Gender Gap (pp) =
CALCULATE(
    [Account Ownership %],
    vw_findex_clean[gender] = "Female"
)
-
CALCULATE(
    [Account Ownership %],
    vw_findex_clean[gender] = "Male"
)


Mobile Money % =
DIVIDE(
    CALCULATE(
        SUM(vw_findex_clean[weight]),
        vw_findex_clean[has_mobile_money] = TRUE()
    ),
    SUM(vw_findex_clean[weight])
)


Mobile Money vs Bank Gap (pp) (2017–24) =
[Mobile Money %] - [Formal Bank Account %]


Savings Rate % =
DIVIDE(
    CALCULATE(
        SUM(vw_findex_clean[weight]),
        vw_findex_clean[did_save] = TRUE
    ),
    SUM(vw_findex_clean[weight])
)


SurveyRound =
DATATABLE(
    "year", INTEGER,
    "round_label", STRING,
    "prior_round_year", INTEGER,
    {
        {2017, "2017 Round", BLANK()},
        {2021, "2021 Round", 2017},
        {2024, "2024 Round", 2021}
    }
)