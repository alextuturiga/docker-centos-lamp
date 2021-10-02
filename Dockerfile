FROM centos:centos7
MAINTAINER Andrew Lau <andrew@andrewklau.com>

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install varioius utilities
RUN yum -y install systemd curl wget unzip git vim nano \
iproute python-setuptools hostname inotify-tools yum-utils which \
epel-release beanstalkd

RUN systemctl enable beanstalkd
RUN systemctl start beanstalkd

# Install Python and Supervisor
RUN yum -y install python-setuptools

# Install Apache
RUN yum -y install nginx
RUN systemctl enable nginx
RUN systemctl start nginx
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

CMD ["/usr/sbin/init"]
