# bots-paper-repo
Anonymous repo for a paper in submission to CSCW 2018. This is an updated repo containing new April 2017 datasets, a reorganized structure, better documentation, and Docker/mybinder support. You can launch this repository now in a free mybinder Jupyter Notebook server by clicking the button below (note that this server is temporary and will expire after an hour or so). All the notebooks in `analysis/main/` can be run in your browser from the mybinder server without any additional setup or data processing. Or if you can open any of the notebooks in the `analysis/` folder in GitHub and see static renderings of the analysis.

[![Binder](http://mybinder.org/badge.svg)](http://mybinder.org:/repo/anon-cscw2018-author1/bots-paper-repo-binder)

## Requirements
Python >=3.3, with the packages:
```
pip install mwcli mwreverts mwtypes mwxml jsonable docopt mysqltsv pandas seaborn
```
R >= 3.2, with the packages:
```
install.packages("ggplot2")
install.packages("data.table")
```
Jupyter Notebooks >=4.0 for running notebooks, with the [IRKernel](https://github.com/IRkernel/IRkernel) for the R notebooks.

### Docker container
Alternatively, use the `Dockerfile` to create a Docker container with all the prerequsites to run the analyses.

## Datasets

### 0. Bot lists
We have two datasets of bots across language versions of Wikipedia:

- `datasets\crosswiki_category_bot_20170328.tsv` is generated from `get_category_bots.py` (also made in the `Makefile`) and contains a list of bots based on Wikidata categories for various language versions of Wikipedia's equivalent of [Category:All Wikipedia bots](https://www.wikidata.org/wiki/Q3681760)

- `datasets\crosswiki_unified_bot_20170328.tsv` is made in the `Makefile` and contains the above dataset combined with lists of bots from the `user_groups` and `former_user_groups` database tables ("the bot flag") in our seven language versions of Wikipedia. This dataset can be considered as complete of a list of current and historical bots (including unauthorized bots) as is possible to automatically generate for these language versions of Wikipedia.

### 1. Data dumps
This project begins with the the stub-meta-history.xml.gz dumps from the Wikimedia foundation. A BASH script to download these data dumps is in `download_dumps.sh`. Note that these files are large -- approximately 85GB compressed -- and on a 16 core Xeon workstation, it can take a week for the first stage of parsing all reverts from the dumps. As we are not taking issue with how previous researchers have computationally identified reverts (only how to interpret reverts as conflict), replicating this step is not crucial. We recommend those interested in replication start with the bot-bot revert datasets, described below.

### 2. All reverts
The `Makefile` loads the data dumps and runs `mwreverts dump2reverts` to generate .json.bz2 formatted tables of all reverts to all pages across the languages we analyzed, stored in `datasets/reverts/`. These are then parsed by the `Makefile` to generate the monthly bot revert tables in step 3.1 and the bot-bot revert datasets in step 4. These data are not included in the GitHub repo because they are multiple gigabytes, but we will be releasing them publicly on other platforms after peer review.

### 3. Monthly bot activity datasets
#### 3.1 Monthly bot reverts
The `Makefile` loads the full table of reverts and runs `bot_revert_monthly_stats.py` generate TSV formatted tables for each language, which contain namespace-grouped counts of: the number of reverts (reverts), reverts by bots (bot_reverts), bot edits that were reverted (bot_reverteds), and bot-bot-reverts (bot2bot_reverts). This is stored in `datasets/monthly_bot_reverts/` and included in this repo.
#### 3.2 Monthly bot edits
The `Makefile` downloads SQL queries run on the Wikimedia Foundation's open analytics cluster (Tool Labs) to create, for each language, monthly counts by namespace of the number of total bot edits. This is stored in `datasets/monthly_bot_edits/` and included in this repo.

### 4. bot-bot revert datasets
The `Makefile` loads the revert datasets in `datasets/reverts/` and the bot list and runs `revert_json_2_tsv.py` to generate TSV formatted, bz2 compressed datasets of every bot-bot revert across pages in all namespaces for each language. This is stored in `datasets/reverted_bot2bot/` and included in this repo. The format of these datasets can be seen in `analysis/0-load-process-data.ipynb`. Starting with these datasets lets you reproduce the novel parts of our analysis pipeline, and so we recommend starting here.

### 5. Parsed dataframes
Datasets in `datasets/parsed_dataframes/` are created out of the analyses in the Jupyter notebooks in the `analysis/` folder. If you are primarily interested in exploring our results and conducting further analysis, we'd recommend starting with `df_all_comments_parsed_2016.pickle.xz`. These datasets are compressed with xz (extremely compressed to keep them under GitHub's 100mb limit -- we will release many more common data formats when we can de-anonymize and use other platforms). The decompressed pickle file is a serialized pandas dataframe that can be loaded in python, as seen in the notebooks in the `analysis/paper_plots` folder.

- `df_all_2016.pickle.xz` is a pandas dataframe of all bot-bot reverts in the languages in our dataset. It is generated by running the Jupyter notebook `analysis/main/0-load-process-data.ipynb`, which also shows the variables in this dataset.

- `df_all_comments_parsed_2016.pickle.xz` extends `df_all_2016.pickle.xz` with classifications of reverts. It is generated by `analysis/main/6-1-comment-parsing.ipynb`, which also shows the variables in this dataset.

- `possible_botfights.pickle.bz2` and `possible_botfights.tsv.bz2` are bzip2-compressed filtered datasets of `df_all_comments_parsed_2016.pickle`, containing reverts from all langauges in our analysis that are possible cases of bot-bot conflict (part of a bot-bot reciprocation, with time to revert under 180 days). It is generated by `analysis/main/6-4-comments-analysis.ipynb`.

## Analyses
### Analyses in the paper
Analyses that are presented in the paper are in the `analysis/main/` folder, with Jupyter notebooks for each paper section (for example, section 4.2 on time to revert is presented in 4-2-time-to-revert.ipynb). Some of these notebooks include more plots, tables, data, and analyses than we were able to fit in the paper, but we kept them because they could be informative.
### Exploratory analyses
We also have various supplemental and exploratory analyses in `analyses/exploratory/`.

## Sample diff tables
These tables are accessible at [here](https://anon-cscw2018-author1.github.io/bots-paper-repo/sample_tables/) and in raw HTML form at `analysis/sample_tables/`. These were generated by `analysis/6-2-comments-sample-diffs.ipynb`.

## Data Dictionary
This is the data dictionary for df_all_comments_parsed_2016.csv/.pickle, which are the final datasets. Intermediate datasets (like df_all_2016.csv/.pickle) have fewer fields, but these descriptions are accurate for fields that appear in those datasets as well.

| field name                      	| description                                                                                                                                           	| created in                        	| example row 1                                 	| example row 2                                     	|
|---------------------------------	|-------------------------------------------------------------------------------------------------------------------------------------------------------	|-----------------------------------	|-----------------------------------------------	|---------------------------------------------------	|
| archived                        	| Has the reverting edit been archived?                                                                                                                 	| Makefile, from the database dumps 	| FALSE                                         	| FALSE                                             	|
| language                        	| two letter country code (*.wikipedia.org subdomain)                                                                                                   	| Makefile, from the database dumps 	| fr                                            	| fr                                                	|
| page_namespace                  	| Integer namespace of the page where the edit was made. Matches page_namespace in the page database table                                              	| Makefile, from the database dumps 	| 0                                             	| 0                                                 	|
| rev_deleted                     	| Has the reverted edit been deleted?                                                                                                                   	| Makefile, from the database dumps 	| FALSE                                         	| FALSE                                             	|
| rev_id                          	| Integer revision ID of the reverted edit, matches rev_id in the revision database table                                                               	| Makefile, from the database dumps 	| 88656915                                      	| 70598552                                          	|
| rev_minor_edit                  	| Was the reverted edit flagged as a minor edit by the user who made it?                                                                                	| Makefile, from the database dumps 	| TRUE                                          	| TRUE                                              	|
| rev_page                        	| Integer page ID of the page where the reverted edit was made, matches rev_page in the revision database table and page_id in the page database table  	| Makefile, from the database dumps 	| 4419903                                       	| 412311                                            	|
| rev_parent_id                   	| The revision ID of the revision immediately prior to the reverted edit                                                                                	| Makefile, from the database dumps 	| 8.86E+07                                      	| 6.75E+07                                          	|
| rev_revert_offset               	| distance of the reverted revision from the reverting revision (1 == the most recent reverted revision)                                                	| Makefile, from the database dumps 	| 1                                             	| 1                                                 	|
| rev_sha1                        	| The SHA1 hash of the page text made by the reverted edit                                                                                              	| Makefile, from the database dumps 	| lgtqatftj6rma9ezkyy56rsqethdoqf               	| 0zw28ur2rlxg207ms6w3krqd4qzozq3                   	|
| rev_timestamp                   	| Timestamp of the reverted edit in UTC (YYYYMMDDHHMM)                                                                                                  	| Makefile, from the database dumps 	| 20130211173947                                	| 20110930180432                                    	|
| rev_user                        	| User ID of the user who made the reverted edit                                                                                                        	| Makefile, from the database dumps 	| 1019240                                       	| 414968                                            	|
| rev_user_text                   	| Username of the user who made the reverted edit                                                                                                       	| Makefile, from the database dumps 	| MerlIwBot                                     	| Luckas-bot                                        	|
| reverted_to_rev_id              	| Revision ID of the revision that the reverting edit reverted back to                                                                                  	| Makefile, from the database dumps 	| 88597754                                      	| 67506906                                          	|
| reverting_archived              	| Has the reverting edit been archived?                                                                                                                 	| Makefile, from the database dumps 	| FALSE                                         	| FALSE                                             	|
| reverting_comment               	| Edit summary of the reverting edit                                                                                                                    	| Makefile, from the database dumps 	| r2.7.2+) (robot Retire : [[cbk-zam:Tortellá]] 	| robot Retire: [[hy:Հակատանկային կառավարվող հրթ... 	|
| reverting_deleted               	| Has the reverting edit been deleted?                                                                                                                  	| Makefile, from the database dumps 	| FALSE                                         	| FALSE                                             	|
| reverting_id                    	| Revision ID of the reverting edit, matches rev_id in the revision database table                                                                      	| Makefile, from the database dumps 	| 89436503                                      	| 70750839                                          	|
| reverting_minor_edit            	| Was the revision ID flagged as a minor edit by the user who made it?                                                                                  	| Makefile, from the database dumps 	| TRUE                                          	| TRUE                                              	|
| reverting_page                  	| Integer page ID of the page where the reverting edit was made, matches rev_page in the revision database table and page_id in the page database table 	| Makefile, from the database dumps 	| 4419903                                       	| 412311                                            	|
| reverting_parent_id             	| The revision ID of the revision immediately prior to the reverting edit                                                                               	| Makefile, from the database dumps 	| 8.87E+07                                      	| 7.06E+07                                          	|
| reverting_sha1                  	| The SHA1 hash of the page text made by the reverted edit                                                                                              	| Makefile, from the database dumps 	| gjz9jni8w2jiccksgid7tbofddevhu0               	| myxsvdiky34vgddnhrclg9237cus7nn                   	|
| reverting_timestamp             	| Timestamp of the reverting edit in UTC (YYYYMMDDHHMM)                                                                                                 	| Makefile, from the database dumps 	| 20130302203329                                	| 20111004215328                                    	|
| reverting_user                  	| User ID of the user who made the reverted edit                                                                                                        	| Makefile, from the database dumps 	| 757129                                        	| 1019240                                           	|
| reverting_user_text             	| Username of the user who made the reverting edit                                                                                                      	| Makefile, from the database dumps 	| EmausBot                                      	| MerlIwBot                                         	|
| revisions_reverted              	| Number of revisions reverted by the reverting edit                                                                                                    	| Makefile, from the database dumps 	| 1                                             	| 1                                                 	|
| namespace_type                  	| Text description of the namespace (0: "article", 14: "category", other odd: "other talk"; other even: "other page")                                   	| 0-load-process-data.ipynb         	| article                                       	| article                                           	|
| reverted_timestamp_dt           	| Datetime64 version of `rev_timestamp`                                                                                                                 	| 0-load-process-data.ipynb         	| 2013-02-11 17:39:47                           	| 2011-09-30 18:04:32                               	|
| reverting_timestamp_dt          	| Datetime64 version of `reverting_timestamp`                                                                                                           	| 0-load-process-data.ipynb         	| 2013-03-02 20:33:29                           	| 2011-10-04 21:53:28                               	|
| time_to_revert                  	| Time between the reverted and reverting revision. Timedelta64 of difference between `reverting_timestamp` and `rev_timestamp`                         	| 0-load-process-data.ipynb         	| 19 days 02:53:42                              	| 4 days 03:48:56                                   	|
| time_to_revert_hrs              	| Float conversion of `time_to_revert` in hours                                                                                                         	| 0-load-process-data.ipynb         	| 458.9                                         	| 99.82                                             	|
| time_to_revert_days             	| Float conversion of `time_to_revert` in hours                                                                                                         	| 0-load-process-data.ipynb         	| 19.12                                         	| 4.159                                             	|
| reverting_year                  	| Integer year of the reverting revision                                                                                                                	| 0-load-process-data.ipynb         	| 2013                                          	| 2011                                              	|
| time_to_revert_days_log10       	| Float log10(time_to_revert_days)                                                                                                                      	| 0-load-process-data.ipynb         	| 1.282                                         	| 0.619                                             	|
| time_to_revert_hrs_log10        	| Float log10(time_to_revert_hours)                                                                                                                     	| 0-load-process-data.ipynb         	| 2.662                                         	| 1.999                                             	|
| reverting_comment_nobracket     	| Reverting comment text with all text inside brackets, parentheses, and braces removed                                                                 	| 0-load-process-data.ipynb         	| r2.7.2+)                                      	| robot Retire:                                     	|
| botpair                         	| String concatenation of `reverting_user_text` + " rv " + `rev_user_text`                                                                              	| 0-load-process-data.ipynb         	| EmausBot rv MerlIwBot                         	| MerlIwBot rv Luckas-bot                           	|
| botpair_sorted                  	| Sorted list of [`reverting_user_text`, `rev_user_text`]                                                                                               	| 0-load-process-data.ipynb         	| ['EmausBot', 'MerlIwBot']                     	| ['Luckas-bot', 'MerlIwBot']                       	|
| reverts_per_page_botpair        	| Total number of reverts in this dataset with the same `botpair` value on this page in this language                                                   	| 0-load-process-data.ipynb         	| 1                                             	| 1                                                 	|
| reverts_per_page_botpair_sorted 	| Total number of reverts in this dataset with the same `botpair_sorted` value on this page in this language                                            	| 0-load-process-data.ipynb         	| 1                                             	| 1                                                 	|
| bottype                         	| Classified type of bot-bot interaction, more granular than `bottype_group`                                                                            	| 7-2-comment-parsing.ipynb         	| interwiki link cleanup -- method2             	| interwiki link cleanup -- method2                 	|
| bottype_group                   	| Classified type of bot-bot interaction, consolidated from `bottype`                                                                                   	| 7-2-comment-parsing.ipynb         	| interwiki link cleanup -- method2             	| interwiki link cleanup -- method2                 	|
