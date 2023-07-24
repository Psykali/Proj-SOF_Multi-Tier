### Docker File SOF app
# Image
FROM phusion/baseimage:0.9.22
ADD file:6d1f2746d5a5f002e9c48795beedb7c616a0b48b8bb2e417db4cd6e2a7b352f8 in /
RUN /bin/sh -c echo '#!/bin/sh' > /build/enable_repos.sh
RUN /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
CMD ["/bin/bash"]
MAINTAINER Phusion <info@phusion.nl>
ENV HOME=/root
ADD dir:eb5c08406c187cf27b65e547f722afcd5b6241538cdc83531611df6d3c481665 in /build
RUN /build/prepare.sh && /build/system_services.sh && /build/cleanup.sh
CMD ["/sbin/my_init"]
EXPOSE 80/tcp
# Update and dependencies
RUN apt-get update && apt-get install -y apache2 mysql-server php5-mysql pwgen php-apc php5-mcrypt php5-gd libssh2-php && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Confs Apache
RUN mkdir /etc/service/mysql && mkdir /etc/service/apache2 && rm -rf /var/www/html
RUN sed -i -e 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
ADD file:3bfa7d1a2a0e6db035a44f764cabcbef8f95e5b3ce8c6bbc6bdc4f8d7711d82c in /etc/my_init.d/setup-project.sh
WORKDIR /
RUN mkdir -p /tmp
WORKDIR /tmp
# Git Clone
RUN git clone https://github.com/amiyasahu/Donut.git
WORKDIR /var/www/html/qa-lang
# Last Update and Clean
RUN apt-get update && apt-get install -y unzip && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD ["/sbin/my_init"]
# Install MySQL client and ODBC driver for SQL Server
RUN apt-get update && apt-get install -y mysql-client unixodbc-dev curl gnupg && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Add script to connect to external Azure SQL Database
ADD connect-to-azure-sql.sh /usr/local/bin/connect-to-azure-sql.sh
RUN chmod +x /usr/local/bin/connect-to-azure-sql.sh
# Run script to connect to external Azure SQL Database
CMD ["/usr/local/bin/connect-to-azure-sql.sh"]
