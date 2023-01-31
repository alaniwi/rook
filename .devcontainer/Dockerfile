FROM mcr.microsoft.com/devcontainers/anaconda:0-3

# # [Optional] Uncomment this section to install additional OS packages.
# # RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
# #     && apt-get -y install --no-install-recommends <your-package-list-here>

#============================================================
####----------------------------------------
#### attempt to use existing conda, installing mamba
#### (update pyopenssl helped, but still failed to install mamba)
####----------------------------------------
####  # fix broken pyopenssl that prevents all other conda commands
####  RUN . /opt/conda/bin/activate && pip install --upgrade pyopenssl
####  
####  # Install mamba
####  RUN . /opt/conda/bin/activate && conda install -c conda-forge -y mamba
#============================================================
#----------------------------------------
# instead just use mambaforge (delete useless conda installation)
#----------------------------------------
RUN rm -fr /opt/conda
RUN curl -s -L -o mamba.sh -O https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-pypy3-Linux-x86_64.sh \
    && bash mamba.sh -b -p /opt/conda && rm mamba.sh && chmod -R g+w /opt/conda && chgrp -R conda /opt/conda
#============================================================

# COPY project
RUN mkdir /workspaces

#------------------------------------------------------
# copy contents - vscode doesn't like using cache if COPY is used,
#  so clone the repo instead (should we checkout a different branch?)
#
#COPY . /workspaces/rook
RUN cd /workspaces \
      && git clone https://github.com/roocs/rook.git
#------------------------------------------------------

# Create conda environment
# (use the list of URLs, but the token @EXPLICIT not understood by mamba)
RUN perl -p -i -e 'print "#" if /\@EXPLICIT/' /workspaces/rook/spec-list.txt \
      &&  . /opt/conda/bin/activate && mamba env create -n roocs_env -f /workspaces/rook/spec-list.txt

# Update the environment
# (Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.)
COPY environment.yml* .devcontainer/noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && . /opt/conda/bin/activate && mamba env update -n roocs_env -f /tmp/conda-tmp/environment.yml; fi \
      && rm -rf /tmp/conda-tmp

# updates - uncommented if needed - but seems okay with the mamba-forge env
# RUN . /opt/conda/bin/activate && conda activate roocs_env \
#        && pip install --upgrade pip \
#        && pip install --upgrade pyopenssl

#--------------
# Install rooki + deps
#--------------
RUN cd /workspaces \
       && git clone https://github.com/roocs/rooki.git && cd rooki \
       && . /opt/conda/bin/activate && conda activate roocs_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install -e .

#--------------
# Install roocs-utils + deps
#--------------
RUN cd /workspaces \
       && git clone https://github.com/roocs/roocs-utils.git && cd roocs-utils \
       && . /opt/conda/bin/activate && conda activate roocs_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install -e .

#--------------
# Install clisops + deps (except roocs deps)
#--------------
RUN cd /workspaces \
       && git clone https://github.com/roocs/clisops && cd clisops \
       && perl -p -i -e 'print "#" if /roocs-utils/' requirements.txt \
       && . /opt/conda/bin/activate && conda activate roocs_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install -e .

#--------------
# Install daops + deps (except roocs deps)
#--------------
RUN cd /workspaces \
       && git clone https://github.com/roocs/daops && cd daops \
       && perl -p -i -e 'print "#" if /(clisops|roocs-utils)/' requirements.txt \
       && . /opt/conda/bin/activate && conda activate roocs_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install -e .

#--------------
# Install roocs itself + deps (except roocs deps)
#--------------
RUN cd /workspaces/rook \
       && perl -p -i -e 'print "#" if /(daops|clisops|roocs-utils)/' requirements.txt \
       && . /opt/conda/bin/activate && conda activate roocs_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install -e .

# Start WPS service on port 5000 on 0.0.0.0
EXPOSE 5000
ENTRYPOINT ["/bin/bash", "-c"]
CMD [". /opt/conda/bin/activate && conda activate roocs_env && exec rook start -b 0.0.0.0"]
