# B1850_docker
Docker container for CESM compset B1850 resolution f09_g17


CESM docker container for F1850 compset and resolution f09_g17 using [bioconda cesm docker](https://bioconda.github.io/recipes/cesm/README.html) as a base image.

- Input dataset is stored and available in zenodo.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3526181.svg)](https://doi.org/10.5281/zenodo.3526181)


## Compiling with intel compilers

You need to pass `parallel_studio_xe_2018_update1_cluster_edition.tgz` for being able to compile with intel compilers.

We are using a trial license for this test (see `silent.cfg`). However, you should update `silent.cfg` to pass a proper license for running on your platform.


## Running B1850 with docker

Make sure inputdata is available (it won't download it as we suppose it is already on disk). 
- The location of the inputdata is `/opt/uio/inputdata` 

```
mkdir /opt/uio
wget https://zenodo.org/record/3526181/files/inputdata_B1850.tar.gz
tar zxf inputdata_B1850.tar.gz
mv inputdata_container inputdata
```

- Model outputs are stored in `/opt/uio/archive` along with the `case` folder (it can be interesting to check timing).

```
docker pull nordicesmhub/cesm_b1850:latest
docker run -i -v /opt/uio/inputdata:/home/cesm/inputdata -v /opt/uio/archive:/home/cesm/archive  -t nordicesmhub/cesm_b1850:latest
```

Once you start your container, use `run_b1850` or any available sub-cases (`run_b1850case1` to `run_b1850_case6`), depending on the number of processors you wish to use.

Update `CESM_PES` in `run_b1850` to change the number of processors per node. We ran this test on [PiZ-Dain] on GPU partitions (12 processors per node).


