FROM jupyter/datascience-notebook

USER root

ADD requirements.txt requirements.txt
RUN pip install --upgrade pip && \
    pip install -r requirements.txt
    
USER main
WORKDIR $HOME/notebooks
