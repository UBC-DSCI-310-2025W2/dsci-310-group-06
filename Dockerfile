FROM rocker/rstudio:4.4.2

RUN apt-get update && \
    apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev && \
    apt-get clean

WORKDIR /home/rstudio/project

COPY . /home/rstudio/project

RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')"
RUN R -e "renv::restore()"

EXPOSE 8787
