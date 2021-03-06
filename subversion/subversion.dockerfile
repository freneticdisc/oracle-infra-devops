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

ENV REPO_HOME=/u01/app/apache/subversion SUBVERSION_GROUP=apache SUBVERSION_USER=subversion

CMD /etc/init.d/apache2 start && /bin/bash

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install apache2 libapache2-svn subversion subversion-tools -y && \
    groupadd -g 1000 ${SUBVERSION_GROUP} && useradd -u 1000 -g 1000 -m ${SUBVERSION_USER} && \
    mkdir -p ${REPO_HOME} && \
    chown -R ${SUBVERSION_USER}:${SUBVERSION_GROUP} ${REPO_HOME} && \
    touch /etc/subversion/.passwd && \
    chown -R ${SUBVERSION_USER}:${SUBVERSION_GROUP} /etc/subversion/.passwd && \
    sed -i "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=${SUBVERSION_USER}/" /etc/apache2/envvars && \
    sed -i "s/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=${SUBVERSION_GROUP}/" /etc/apache2/envvars && \
    echo "<Location /subversion>" > /etc/apache2/sites-available/001-subversion.conf && \
    echo "    DAV svn" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "    SVNParentPath ${REPO_HOME}" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "    SVNListParentPath on" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "    AuthType Basic" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "    AuthName \"Subversion Authorization Realm\"" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "    AuthUserFile /etc/subversion/.passwd" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "    AuthzSVNReposRelativeAccessFile authz" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "    Satisfy any" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "    Require valid-user" >> /etc/apache2/sites-available/001-subversion.conf && \
    echo "</Location>" >> /etc/apache2/sites-available/001-subversion.conf && \
    ln -s /etc/apache2/sites-available/001-subversion.conf /etc/apache2/sites-enabled/001-subversion.conf && \
    /etc/init.d/apache2 stop
