#!/bin/sh


# This installs R packages from github
#echo "Installing hadley/dplyr from github"
#Rscript -e "library(devtools); install_github('hadley/dplyr')"
#echo "Installing hadley/purrr from github"
#Rscript -e "library(devtools); install_github('hadley/purrr')"


# This installs opencpu webapps from github
#echo "Installing appdemo, gitstats, tvscore and qitools/charts opencpu webapp"
#Rscript -e "library(devtools); install_github('mjmg/appdemo')"
#Rscript -e "library(devtools); install_github('mjmg/gitstats')"
#Rscript -e "library(devtools); install_github('mjmg/tvscore')"
#Rscript -e "library(devtools); install_github('qitools/charts')"


# This installs R packages under Bioconductor
#echo "Installing Bioconductor packages Biobase, BiocStyle, EBImage"
#Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('Biobase')"
#Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('BiocStyle')"
#Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('EBImage')"


# This installs R packages in CRAN
#echo "Installing ggplot2 from CRAN"
#Rscript -e "install.packages('ggplot2')"
echo "Installing rmarkdown from CRAN"
Rscript -e "install.packages('rmarkdown')"
echo "Installing htmlwidgets from CRAN"
Rscript -e "install.packages('htmlwidgets')"
#echo "Installing plotly from CRAN"
#Rscript -e "install.packages('plotly')"
#echo "Installing e1071 from CRAN"
#Rscript -e "install.packages('e1071')"
#echo "Installing rphast from CRAN"
#Rscript -e "install.packages('rphast')"
#echo "Installing data.table from CRAN"
#Rscript -e "install.packages('data.table')"
#echo "Installing SparseM from CRAN"
#Rscript -e "install.packages('SparseM')"
#echo "Installing caret from CRAN"
#Rscript -e "install.packages('caret')"
#echo "Installing lazyeval from CRAN"
#Rscript -e "install.packages('lazyeval')"
#echo "Installing ROCR from CRAN"
#Rscript -e "install.packages('ROCR')"
#echo "Installing kernlab from CRAN"
#Rscript -e "install.packages('kernlab')"

echo "Installing VPdtw from CRAN"
Rscript -e "install.packages('VPdtw')"
echo "Installing kernlab from CRAN"
Rscript -e "install.packages('mdatools')"

echo "Installing mjmg/bluQplantQPEPBB from github"
Rscript -e "library(devtools); install_github('mjmg/bluQplantQPEPBB')"




