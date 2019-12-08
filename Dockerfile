FROM centos:7

#####EXTRA LABELS#####
LABEL autogen="no" \ 
    software="CESM Libraries" \ 
    version="2" \
    software.version="2.1.1" \ 
    about.summary="Community Earth System Model" \ 
    base_image="debian:buster" \
    about.home="http://www.cesm.ucar.edu/models/simpler-models/fkessler/index.html" \
    about.license="Copyright (c) 2017, University Corporation for Atmospheric Research (UCAR). All rights reserved." 
      
MAINTAINER Anne Fouilloux <annefou@geo.uio.no>

RUN yum group install "Development Tools" -y && \
    yum install wget cmake "perl(XML::LibXML)"  \
    vim csh git subversion -y

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

ENV USER=root
ENV HOME=/root

COPY silent.cfg $HOME/

COPY parallel_studio_xe_2018_update1_cluster_edition.tgz $HOME/

RUN cd $HOME && \
    tar xf parallel_studio_xe_2018_update1_cluster_edition.tgz && \
    cd parallel_studio_xe_2018_update1_cluster_edition  && \
    ./install.sh --silent $HOME/silent.cfg && \
    rm $HOME/parallel_studio_xe_2018_update1_cluster_edition.tgz && \
    rm -rf $HOME/parallel_studio_xe_2018_update1_cluster_edition

RUN cd $HOME && . /opt/intel/parallel_studio_xe_2018.1.038/psxevars.sh \
    && wget https://www.zlib.net/zlib-1.2.11.tar.gz \
    && tar xf zlib-1.2.11.tar.gz \
    && cd zlib-1.2.11 \
    && CC=icc CXX=icpc F77=ifort FC=ifort ./configure --prefix=/usr \
    && make \
    && make install \
    && cd .. \
    && rm -rf zlib-1.2.11.tar.gz zlib-1.2.11

RUN cd $HOME && . /opt/intel/parallel_studio_xe_2018.1.038/psxevars.sh \
    && wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/hdf5-1.10.5.tar.gz \
    && tar xf hdf5-1.10.5.tar.gz \
    && cd hdf5-1.10.5 \
    && CC=mpiicc CXX=mpiicpc FC=mpiifort ./configure --enable-fortran --enable-parallel --with-zlib=/usr --prefix=/usr \
    && make -j$(nproc) \
    && make install  \
    && cd .. \
    && rm -rf hdf5-1.10.5.tar.gz hdf5-1.10.5

RUN cd $HOME && . /opt/intel/parallel_studio_xe_2018.1.038/psxevars.sh \
    && wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-c-4.7.2.tar.gz \
    && tar xf netcdf-c-4.7.2.tar.gz \
    && cd netcdf-c-4.7.2 \
    && CC=mpiicc CXX=mpiicpc FC=mpiifort ./configure --enable-netcdf4 --disable-dap --prefix=/usr \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf netcdf-c-4.7.2.tar.gz netcdf-c-4.7.2

ENV LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH

RUN cd $HOME && . /opt/intel/parallel_studio_xe_2018.1.038/psxevars.sh \
    && wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.5.2.tar.gz \
    && tar xf netcdf-fortran-4.5.2.tar.gz \
    && cd netcdf-fortran-4.5.2 \
    && CC=mpiicc CXX=mpiicpc FC=mpiifort CPPFLAGS=-I/usr/include LDFLAGS=-L/usr/lib ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install \
    && cd .. \

ENV USER=root
ENV HOME=/root

RUN mkdir -p $HOME/.cime \
             $HOME/work \
             $HOME/inputdata \
             $HOME/archive \
             $HOME/cases 

COPY config_files/* $HOME/.cime/

RUN cd $HOME && . /opt/intel/parallel_studio_xe_2018.1.038/psxevars.sh \
    && git clone -b release-cesm2.1.1 https://github.com/ESCOMP/CESM.git \
    && cd CESM \
    && sed -i.bak "s/'checkout'/'checkout', '--trust-server-cert', '--non-interactive'/" ./manage_externals/manic/repository_svn.py \
    && ./manage_externals/checkout_externals

WORKDIR $HOME/cases

COPY run_b1850case1 $HOME/cases
COPY run_b1850case2 $HOME/cases
COPY run_b1850case3 $HOME/cases
COPY run_b1850case4 $HOME/cases
COPY run_b1850case5 $HOME/cases
COPY run_b1850case6 $HOME/cases

CMD ["/bin/bash"]

