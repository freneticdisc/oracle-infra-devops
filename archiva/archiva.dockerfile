################################################################################
# archiva.dockerfile
#
# Copyright (C) 2017 Justin Paul <justinpaulthekkan@gmail.com>
#
# @author: Justin Paul
#
# This program is free software: you can redistribute it and/or modify
# it as long as you retain the name of the original author and under
# the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################
FROM ubuntu
MAINTAINER Justin Paul <justinpaulthekkan@gmail.com>

ENV SCRATCH=/tmp/scratch ARCHIVA_URL=http://www.gtlib.gatech.edu/pub/apache/archiva/2.2.1/binaries/apache-archiva-2.2.1-bin.tar.gz APACHE_HOME=/u01/app/apache ARCHIVA_HOME=/u01/app/apache/archiva ARCHIVA_GROUP=apache ARCHIVA_USER=archiva

CMD /bin/su - -c "${ARCHIVA_HOME}/bin/archiva start" ${ARCHIVA_USER} && /bin/bash

RUN apt-get update -y && \
    apt-get install software-properties-common python-software-properties -y && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update -y && apt-get upgrade -y && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    apt-get install oracle-java8-installer -y && \
    groupadd -g 1000 ${ARCHIVA_GROUP} && useradd -u 1000 -g 1000 -m ${ARCHIVA_USER} && \
    mkdir -p ${SCRATCH} && mkdir -p ${ARCHIVA_HOME} && \
    chown -R ${ARCHIVA_USER}:${ARCHIVA_GROUP} ${SCRATCH} && \
    chown -R ${ARCHIVA_USER}:${ARCHIVA_GROUP} ${APACHE_HOME} && \
    su - -c "wget -P ${SCRATCH} ${ARCHIVA_URL}" ${ARCHIVA_USER} && \
    su - -c "tar xzf ${SCRATCH}/${ARCHIVA_URL##*/} -C ${ARCHIVA_HOME} --strip-components=1" ${ARCHIVA_USER} && \
    rm -rf ${SCRATCH}
