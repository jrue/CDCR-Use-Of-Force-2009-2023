# CDCR Use of Force Data

This repository is a project by KQED regarding Use of Force cases by prisons in California. Specifically, we aim to compare these cases among the different prisons as a rate adjusted by population of the prison. We are only looking at High Security prisons from the years 2008 to 2023. 

CDCR does not publish historical data, so we drew from multiple sources. Some were obtains from COMPSTAT reports, others directly from public records requests. 

## [scrape-pdf-2009-2014.ipynb](scrape-pdf-2009-2014.ipynb)

Scrape COMPSTAT data from Division of Adult Institutions (DAI) statistical reports. These PDFs come in three different forms. 

* DAI High Security - These were deemed as high security prisons at that time.
* DAI Reception Centers - We scrape this in order to include Los Angeles County (LAC) for 2009. In 2010, LAC was included in the above High Security PDFs. 
* DAI General Population - We scrape this in order to include Substance Abuse Treatment Facility and State Prison (SATF), which wasn't included in High Security PDFs until 2011. 

These PDFs have header rows throughout the sheets with blank values across remaining cells. To account for this, these headers were programmatically prepended to subsequent rows in order to individually identify the values (e.g. `header_name - subsequent_row_name`). In some instances, false header rows were misidentified because no values existed for the year (see Vacancies for example), which spuriously established them as a prefix for subsequent rows. Since this project is only focusing on Use of Force and Inmate Count rows, this issue is moot, but would need to be addressed if further analysis were needed on other variables. 

PDFPlumber has an unsupported mechanism to identify the [background color of cells](https://stackoverflow.com/a/73759921), but only if you already know the coordinates of the cell in question. This would require some additional coding to identify the coordinates of a cell based on its value. This might be one way to approach this issue, since rows with no values are usually grayed out.

## [scrape-pdf-2015-2019-Population.ipynb](scrape-pdf-2015-2019-Population.ipynb)

To get the population of prisons in 2015-2019, a public records request was made, which provided monthly population details. This was because COMPSTAT data from this period did not include population information for prisons. 

These PDFs are identified as "midnight" on the last day of the month, which seem would omit the last day of the month. But when comparing to other sources, we believe this simply as a misnomer and midnight simply means 11:59pm, referring to the totality of the month in question. 

The population amounts are identified differently than COMPSTAT. In this case, columns for "Felon/Other" and "Civil/Addict" were combined to determine a total population of each facility. In later COMPSTAT reports, the column identifier is labeled as "Inmate Count."

## [scrape-pdf-2015-2020-UOF.ipynb](scrape-pdf-2015-2020-UOF.ipynb)

These are PDFs scraped from COMPSTAT websites directly, filtering for Documented Use of Force. This was joined with population data from this same period (see section directly above).

Note: This COMPSTAT UOF also includes 2020, one more year than the above date range. This was because COMPSTAT data for 2020 omitted Use of Force data for some unknown reason.

## [scrape-pdf-2020-to-2021.ipynb](scrape-pdf-2020-to-2021.ipynb)

These are scraped from COMPSTAT generated PDFs. Oddly, the 2020 COMPSTAT PDFs omits the UOF field, which was dashed out across each institution. We used COMPSTAT data from the website (see immediately above) to fill in these values.

## [scrape-pdf-2022-2023-Population.ipynb](scrape-pdf-2022-2023-Population.ipynb)

This is scraped from COMPSTAT generated PDFs. In 2022, CDCR stopped reporting Use of Force cases on COMPSTAT reports, so this PDF was only used to identify the population of prisons.

## [scrape-pdf-2022-2023-UOF.ipynb](scrape-pdf-2022-2023-UOF.ipynb)

This PDF was obtained through a public records request in order to identify Use of Force cases, and maintain consistency throughout the entire time period. 

## [FINAL_merge_all_pdfs.ipynb](FINAL_merge_all_pdfs.ipynb)

This notebook merges all of the above .csv files, sorts the sheet, and filters only for High Security prisons. 

The final generated file can be downloaded at [finished-csvs/all_data_final.csv](finished-csvs/all_data_final.csv)



