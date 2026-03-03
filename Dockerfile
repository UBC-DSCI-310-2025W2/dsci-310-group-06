FROM rocker/tidyverse:4.3.1

RUN apt-get update && \
    apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev && \
    apt-get clean

RUN R -e "install.packages(c('tidymodels', 'GGally', 'ranger', 'broom'))"

WORKDIR /project

COPY . /project

CMD ["bash"]
