FROM centos:centos7
MAINTAINER Andrew Lau <andrew@andrewklau.com>

# Install varioius utilities
RUN yum -y install curl wget unzip git vim nano \
iproute python-setuptools hostname inotify-tools yum-utils which \
epel-release

# Install Python and Supervisor
RUN yum -y install python-setuptools \
&& mkdir -p /var/log/supervisor \
&& easy_install supervisor

# Install Apache
RUN yum -y install nginx
EXPOSE 80
EXPOSE 443

# Install Remi Updated PHP 7
RUN wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
&& rpm -Uvh remi-release-7.rpm \
&& yum-config-manager --enable remi-php70 \
&& yum -y install php70-php php70-php-common php70-php-devel php70-php-gd php70-php-pdo php70-php-soap php70-php-xml php70-php-xmlrpc php70-php-fpm


# Install phpMyAdmin
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/g' /etc/php.ini \
&& sed -i 's/post_max_size = 8M/post_max_size = 512M/g' /etc/php.ini \
&& sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Install Redis
RUN yum -y install redis;
EXPOSE 3000


# UTC Timezone & Networking
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

COPY supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]
