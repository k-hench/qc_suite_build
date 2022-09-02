FROM docker.io/debian:11.3
LABEL authors="Kosmas Hench" \
      description="Container containing qc software"

# setting up conda
RUN apt update && apt install -y wget procps
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh && \
    bash Miniconda3-py39_4.12.0-Linux-x86_64.sh -b -p /miniconda

ENV PATH ${PATH}:/miniconda/bin

# install mamba for fast installation and set up channels
RUN conda install mamba -y -n base -c conda-forge
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge

# install packages available via conda
COPY env.yml /
RUN mamba env create -f /env.yml && conda clean -a
ENV PATH ${PATH}:/miniconda/envs/qc_suite-0.2/bin

# manual install of bamcov and ART-detectCores
RUN apt install -y git gcc make libz-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev
RUN mkdir -p /manual_install/bin && \
    cd /manual_install && \
    git clone --recurse-submodules https://github.com/fbreitwieser/bamcov && \
    cd bamcov && \
    make && \
    mv ./bamcov /manual_install/bin/

# install R dependencies
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common

# install R
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' && \
    add-apt-repository 'deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/'
RUN apt install -y r-base-dev
ENV LC_ALL=C.UTF-8
# restrict R libs to the container (when using singularity) and fix system timezone
RUN sed 's/^R_LIBS_USER/# R_LIBS_USER/' /etc/R/Renviron > /etc/R/Renviron.control && \
    mv /etc/R/Renviron.control /etc/R/Renviron && \
    echo 'TZ="UTC"' >> /etc/R/Renviron

RUN cd /manual_install && \
    wget https://master.dl.sourceforge.net/project/ngs-art-deco/ART-DeCo.tar.gz && \
    tar -zxvf ART-DeCo.tar.gz && \
    echo '#!/bin/bash' > ART-DeCo/artdeco && \
    echo 'perl /manual_install/ART-DeCo/scripts/ART-DeCo.pl "$@"' >> ART-DeCo/artdeco && \
    chmod 755 ART-DeCo/artdeco
ENV PATH ${PATH}:/manual_install/bin:/manual_install/ART-DeCo