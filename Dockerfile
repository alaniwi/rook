# vim:set ft=dockerfile:

ARG CONDA_BASE_IMAGE
FROM $CONDA_BASE_IMAGE

## Update centos system
RUN yum -y update

# Setup env
ENV CONDA_HOME /opt/conda
ENV PATH $CONDA_HOME/bin:$PATH

# Undo pinning of conda version in the conda base image
ENV PINNED $CONDA_HOME/conda-meta/pinned
RUN egrep -v "^conda " $PINNED > $PINNED.tmp
RUN mv $PINNED.tmp $PINNED

# Install mamba
RUN conda install -y mamba

# Copy WPS project
COPY . /opt/wps

WORKDIR /opt/wps

# Create conda environment with PyWPS
RUN mamba env create -n wps -f environment.yml

# Install WPS
RUN ["/bin/bash", "-c", "source $CONDA_HOME/bin/activate && conda activate wps && pip install -e ."]

# Start WPS service on port 5000 on 0.0.0.0
EXPOSE 5000
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["source $CONDA_HOME/bin/activate && conda activate wps && exec rook start -b 0.0.0.0 -c /opt/wps/etc/demo.cfg"]

# docker build --build-arg CONDA_BASE_IMAGE=....... -t roocs/rook .
# docker run -p 5000:5000 roocs/rook
# http://localhost:5000/wps?request=GetCapabilities&service=WPS
# http://localhost:5000/wps?request=DescribeProcess&service=WPS&identifier=all&version=1.0.0
