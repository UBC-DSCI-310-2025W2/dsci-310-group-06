FROM rocker/rstudio:4.4.2

RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libglpk-dev \
    libpng-dev \
    libx11-dev \
    libzmq3-dev \
    build-essential && \
    apt-get clean

WORKDIR /home/rstudio/project

COPY . /home/rstudio/project

RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')"

ENV CFLAGS="-Wno-error=format-security"

RUN R -e "renv::restore()"

EXPOSE 8787
