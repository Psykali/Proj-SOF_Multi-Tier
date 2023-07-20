FROM phusion/baseimage:latest

MAINTAINER Phusion <info@phusion.nl>

ENV HOME /root

# Add build scripts
ADD /build /build

# Run build scripts
RUN /build/prepare.sh && \
    /build/system_services.sh

# Set default command
CMD ["/sbin/my_init"]

# Expose port 80
EXPOSE 80

# Install packages
RUN apt-get update && \
    apt-get install -y mysql-server apache2

# Create service directories
RUN mkdir /etc/service/mysql && \
    mkdir /etc/service/apache2

# Remove default web content
RUN rm -rf /var/www/html

# Modify Apache configuration
RUN sed -i -e 's/KeepAlive On/KeepAlive Off/g' /etc/apache2/apache2.conf

# Add setup script
ADD setup-project.sh /etc/my_init.d/setup-project.sh

# Set working directory
WORKDIR /

# Create temporary directory
RUN mkdir -p /tmp

# Set working directory
WORKDIR /tmp

# Clone repository
RUN git clone https://github.com/amiyasahu/Donut.git

# Set working directory
WORKDIR /var/www/html/qa-lang

# Update packages
RUN apt-get update