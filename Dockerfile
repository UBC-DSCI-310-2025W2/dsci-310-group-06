FROM rocker/tidyverse:4.3.1

RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libwebp-dev && \
    apt-get clean

WORKDIR /project
COPY . /project

RUN R -e "install.packages('renv')"
RUN R -e "renv::consent(provided = TRUE); renv::restore()"

CMD ["bash"]
