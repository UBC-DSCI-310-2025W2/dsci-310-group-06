FROM rocker/rstudio:4.4.2

RUN apt-get update && \
    apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev && \
    apt-get clean

WORKDIR /project

COPY . /project

RUN R -e "install.packages('renv')"

CMD ["bash"]
