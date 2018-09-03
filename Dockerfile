FROM python:3.5-slim

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

ARG INCUBATOR_AIRFLOW_HOME=/usr/local/src

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        python3-pip \
        python3-requests \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

#RUN apt-get update -yqq
#RUN apt-get install -y python3-dev
RUN apt-get install -y default-libmysqlclient-dev

COPY .github ${INCUBATOR_AIRFLOW_HOME}/.github/
COPY airflow ${INCUBATOR_AIRFLOW_HOME}/airflow/
COPY dags ${INCUBATOR_AIRFLOW_HOME}/dags/
COPY dev ${INCUBATOR_AIRFLOW_HOME}/dev/
COPY docs ${INCUBATOR_AIRFLOW_HOME}/docs/
COPY licenses ${INCUBATOR_AIRFLOW_HOME}/licenses/
COPY scripts ${INCUBATOR_AIRFLOW_HOME}/scripts/
COPY tests ${INCUBATOR_AIRFLOW_HOME}/tests/

COPY .codecov.yml ${INCUBATOR_AIRFLOW_HOME}/
COPY .coveragerc ${INCUBATOR_AIRFLOW_HOME}/
COPY .editorconfig ${INCUBATOR_AIRFLOW_HOME}/
COPY .rat-excludes ${INCUBATOR_AIRFLOW_HOME}/
COPY .readthedocs.yml ${INCUBATOR_AIRFLOW_HOME}/
COPY .travis.yml ${INCUBATOR_AIRFLOW_HOME}/
COPY .editorconfig ${INCUBATOR_AIRFLOW_HOME}/

COPY init.sh ${INCUBATOR_AIRFLOW_HOME}/
COPY INSTALL ${INCUBATOR_AIRFLOW_HOME}/
COPY LICENSE ${INCUBATOR_AIRFLOW_HOME}/
COPY MANIFEST.in ${INCUBATOR_AIRFLOW_HOME}/
COPY NOTICE ${INCUBATOR_AIRFLOW_HOME}/
COPY README.md ${INCUBATOR_AIRFLOW_HOME}/
COPY run_tox.sh ${INCUBATOR_AIRFLOW_HOME}/
COPY run_unit_tests.sh ${INCUBATOR_AIRFLOW_HOME}/
COPY setup.cfg ${INCUBATOR_AIRFLOW_HOME}/
COPY setup.py ${INCUBATOR_AIRFLOW_HOME}/
COPY TODO.md ${INCUBATOR_AIRFLOW_HOME}/
COPY tox.ini ${INCUBATOR_AIRFLOW_HOME}/
COPY UPDATING.md ${INCUBATOR_AIRFLOW_HOME}/

RUN pip install tox
RUN pip install codecov

# Setup required for dist
COPY .pypirc /root/

WORKDIR ${INCUBATOR_AIRFLOW_HOME}
# The -e means editable when you import it in to another project,
# so this is probably not needed here
RUN pip install -e .[all]

#ENTRYPOINT ["python", "setup.py", "install"]
#ENTRYPOINT ["python", "setup.py", "develop"]
ENTRYPOINT ["python","setup.py","sdist","upload","-v","-r","elanpypi"]
#ENTRYPOINT ["./run_unit_tests.sh"]
