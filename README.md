# dataharvesting
Material for the course 'Data Harvesting' for the [masters in computational social science - UC3M](https://www.uc3m.es/master/computational-social-science#home).

## Introduction:

Every day millions of gigabytes of data are shared across the internet. The standard way for most internet users to download this data is by manually clicking and downloading files in formats such as Excel files, CSV files, and Word files. However, this process of downloading  files by clicking works well for downloading one or two files. What if you needed to download 500 CSV files? Or what happens when you need to download data that is refreshed every 20 seconds? The process of manually clicking each file is simply not a feasible solution when downloading data at scale or at frequent intervals. That’s why with the increasing amount of data on the internet, there’s also been an increase in the tools that allow you to access that data programmatically. This course will focus on exploring these technologies. 

Throughout the course, we’ll describe and create upon the basic formats for data transfer such as JSON, HTML and XML. We will learn how to subset, manipulate and transform these formats for suitable data analysis tasks. Most of these data formats can be accessed by scraping a website: programmatically accessing the data in a website and asking the program to download as much data as we need and as frequently as needed. An integral part of the course will focus on how to perform ethical web scrapping, how to scale your web scrapping to download massive amounts of data as well as to program your scraper to access data in frequent intervals.

The course will also focus on an emerging technology for websites to share data: Application Programming Interfaces (API). We will touch upon the basic formats for data sharing through APIs as well as how to make thousands of data requests in just seconds. Special emphasis will be made on security and ethical guidelines when speaking to APIs. 

A big part of the course will emphasize automation, as a way for the student to create robust and scalable data acquisition pipelines. At each step of the process, we will focus on the practical applications of these techniques and exercise active participation by the students through hands-on challenges on data acquisition. The course will make heavy use of Github where students will need to share their homework as well as explore the immense repository of data acquisition technology already available as open source software.

The goal of the course is to empower students with the right toolset and ideas to be able to create data acquisition programs, automate their data extraction pipeline and quickly transform that data into formats suitable for analysis. The course will place all these contents in light of the legal and ethical consequences that data acquisition can entail, always informing the students of best practices when grabbing data from the internet. The contents of the course will be as follows:


## Curriculum:

- An introduction to Web Scraping
  - What is Web Scraping?
  - Types of Web Scraping
  - Data formats: XML and HTML
  - Practical access to XML and HTML
  - Automation for Web Scraping programs
  - Selenium and JavaScript based scraping
  - Ethical issues with Web Scraping
  - Practical exercises
  
- Data APIs
  - What is an API
  - Fundamentals of API communication
  - An introduction to the JSON format
  - Create your own API (and share it)
  - REST architecture
  - APIs as a way to share and obtain data (any kind)
  - Automation of API requests
  - Talking with Databases
  - Authentication and ethical access to APIs
  - Practical exercises
  
- Automation of Data Acquisition
  - Why do we need automation?
  - Accessing servers
  - Technologies for automating programs
  - Automating cron jobs
  - Logging tasks
  - Practical exercises

The course assumes students will be familiar with the R programming language, transforming and manipulating datasets as well as saving their work with Git and Github. No prior knowledge on software development nor data acquisition techniques is needed.

# Material

## APIs

Tutorials
  - https://sicss.io/2020/materials/day2-digital-trace-data/apis/rmarkdown/Application_Programming_interfaces.html (these two are together)
  - https://www.youtube.com/watch?v=jde_c7pB5U8 (these two are together)
  - https://cfss.uchicago.edu/notes/application-program-interface/

Papers
  - https://journals.sagepub.com/doi/abs/10.1177/1940161220964767?journalCode=hijb&
  - https://methods.sagepub.com/book/research-methods-in-political-science-and-international-relations/i3919.xml
  - https://www.tandfonline.com/doi/abs/10.1080/10584609.2018.1477506?journalCode=upcp20
  - https://osf.io/preprints/socarxiv/pf7n6/

Resources
  - https://github.com/toddmotto/public-apis
  - https://apilist.fun/
  - https://ropensci.org/packages/
  - https://httr2.r-lib.org/articles/wrapping-apis.html


## Web scraping

Tutorials
  - https://www.youtube.com/watch?v=LjTZNmBjC5Q
  - https://codingclubuc3m.rbind.io/post/2020-02-11/
  - https://cbail.github.io/ids704/screenscraping/rmarkdown/Screenscraping_in_R.html

Papers
  
Resources
  - https://cbail.github.io/ids704/Home.html
