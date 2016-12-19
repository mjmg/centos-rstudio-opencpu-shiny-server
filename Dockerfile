FROM mjmg/centos-r-base:latest

RUN \
  yum install -y yum-utils \
                 rpmdevtools \
                 make \
                 R-devel \
                 httpd-devel \
                 libapreq2-devel \
                 libcurl-devel \
                 protobuf-devel \
                 openssl-devel \
                 libpng-devel \
                 libtiff-devel \
                 libjpeg-turbo-devel \
                 fftw-devel \
                 mesa-libGLU-devel \
                 netcdf-devel && \
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/rapache-1.2.7-2.1.src.rpm && \
  wget http://download.opensuse.org/repositories/home:/jeroenooms:/opencpu-1.6/Fedora_23/src/opencpu-1.6.2-7.1.src.rpm && \
  yum-builddep -y --nogpgcheck rapache-1.2.7-2.1.src.rpm && \
  yum-builddep -y --nogpgcheck opencpu-1.6.2-7.1.src.rpm

RUN \
  useradd -ms /bin/bash builder && \
  chmod o+r rapache-1.2.7-2.1.src.rpm && \
  chmod o+r opencpu-1.6.2-7.1.src.rpm && \
  mv rapache-1.2.7-2.1.src.rpm /home/builder/ && \
  mv opencpu-1.6.2-7.1.src.rpm /home/builder/

USER builder

RUN \
  rpmdev-setuptree

RUN \
  cd ~ && \
  rpm -ivh rapache-1.2.7-2.1.src.rpm && \
  rpmbuild -ba ~/rpmbuild/SPECS/rapache.spec

RUN \
  cd ~ && \
  rpm -ivh opencpu-1.6.2-7.1.src.rpm && \
  rpmbuild -ba ~/rpmbuild/SPECS/opencpu.spec 

RUN \
  cd ~ && \
  wget https://download2.rstudio.org/rstudio-server-rhel-1.0.44-x86_64.rpm && \
  wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.5.1.834-rh5-x86_64.rpm

USER root

RUN \
  yum install -y MTA mod_ssl /usr/sbin/semanage && \
  cd /home/builder/rpmbuild/RPMS/x86_64/ && \
  rpm -ivh rapache-*.rpm && \
  rpm -ivh opencpu-lib-*.rpm && \
  rpm -ivh opencpu-server-*.rpm

RUN \
  yum install -y --nogpgcheck /home/builder/rstudio-server-rhel-1.0.44-x86_64.rpm 

RUN \
  echo "Installing shiny from CRAN" && \
  Rscript -e "install.packages('shiny')" && \
  echo "Installing rmarkdown from CRAN" && \
  Rscript -e "install.packages('rmarkdown')"

RUN \
  yum install -y --nogpgcheck /home/builder/shiny-server-1.5.1.834-rh5-x86_64.rpm

# Cleanup
RUN \
  rm -rf /home/builder/* && \
  userdel builder && \
  yum autoremove -y

RUN mkdir -p /var/log/shiny-server && \
  chown shiny:shiny /var/log/shiny-server && \
  chown shiny:shiny -R /srv/shiny-server && \
  chmod 777 -R /srv/shiny-server && \
  chown shiny:shiny -R /opt/shiny-server/samples/sample-apps && \
  chmod 777 -R /opt/shiny-server/samples/sample-apps

# Add default root password with password r00tpassw0rd
RUN \
  echo "root:r00tpassw0rd" | chpasswd

# Configure default shiny user with password shiny
RUN \
  #useradd rstudio && \
  echo "shiny:shiny" | chpasswd
  #chmod -R +r /home/shiny

# Server ports
EXPOSE 443 9001

# Add supervisor conf files
ADD \
  ./etc/supervisor/conf.d/rstudio-server.conf /etc/supervisor/conf.d/rstudio-server.conf
ADD \
  ./etc/supervisor/conf.d/opencpu.conf /etc/supervisor/conf.d/opencpu.conf
ADD \
  ./etc/supervisor/conf.d/shiny-server.conf /etc/supervisor/conf.d/shiny-server.conf

# Use SSL and password protect shiny-server with shiny:shiny
ADD \
  ./etc/httpd/conf.d/shiny-httpd.conf /etc/httpd/conf.d/shiny-httpd.conf
ADD \
  ./etc/httpd/conf.d/htpasswd /etc/httpd/conf.d/htpasswd

# Force SSL for everything
ADD \
  ./etc/httpd/conf.d/force-ssl.conf /etc/httpd/conf.d/force-ssl.conf

# install additional packages
ADD \
  installRpackages.sh /usr/local/bin/installRpackages.sh
RUN \
  chmod +x /usr/local/bin/installRpackages.sh && \
  /usr/local/bin/installRpackages.sh

# Define default command.
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
