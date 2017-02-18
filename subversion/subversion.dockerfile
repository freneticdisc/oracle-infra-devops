################################################################################
# subversion.dockerfile
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

ENV APACHE_HOME=/u01/app/apache SUBVERSION_HOME=/u01/app/apache/subversion SUBVERSION_GROUP=apache SUBVERSION_USER=subversion

CMD /etc/init.d/apache2 start && /bin/bash

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install apache2 libapache2-svn subversion subversion-tools -y && \
    groupadd -g 1000 ${SUBVERSION_GROUP} && useradd -u 1000 -g 1000 -m ${SUBVERSION_USER} && \
    mkdir -p ${SUBVERSION_HOME} && \
    chown -R ${SUBVERSION_USER}:${SUBVERSION_GROUP} ${APACHE_HOME} && \
    su - -c "touch ${SUBVERSION_HOME}/.passwd" ${SUBVERSION_USER} && \
    su - -c "touch ${SUBVERSION_HOME}/.authz" ${SUBVERSION_USER} && \
    sed -i "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=${SUBVERSION_USER}/" /etc/apache2/envvars && \
    sed -i "s/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=${SUBVERSION_GROUP}/" /etc/apache2/envvars && \
    echo -e "<Location /subversion>" > /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "\tDAV svn" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "\tSVNParentPath ${SUBVERSION_HOME}" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "\tAuthType Basic" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "\tAuthName \"Subversion Authorization Realm\"" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "\tAuthUserFile ${SUBVERSION_HOME}/.passwd" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "\tAuthzSVNAccessFile ${SUBVERSION_HOME}/.authz" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "\tSatisfy any" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "\tRequire valid-user" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo -e "</Location>" >> /etc/apache2/sites-available/001-subversion.conf && \
    ln -s /etc/apache2/sites-available/001-subversion.conf /etc/apache2/sites-enabled/001-subversion.conf && \
    /etc/init.d/apache2 stop
