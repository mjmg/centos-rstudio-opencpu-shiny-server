FROM mjmg/centos-r-base:latest

RUN \ 
  yum install -y yum-utils rpmdevtools make R-devel httpd-devel libapreq2-devel libcurl-devel protobuf-devel openssl-devel libpng-devel libtiff-devel libjpeg-turbo-devel fftw-devel netcdf-devel && \
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
  #R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')"
  echo "Installing shiny from CRAN" && \
  Rscript -e "install.packages('shiny')"


RUN \
  yum install -y --nogpgcheck /home/builder/shiny-server-1.5.1.834-rh5-x86_64.rpm
  
RUN mkdir -p /var/log/shiny-server \
	&& chown shiny:shiny /var/log/shiny-server \
	&& chown shiny:shiny -R /srv/shiny-server \
	&& chmod 777 -R /srv/shiny-server \
	&& chown shiny:shiny -R /opt/shiny-server/samples/sample-apps \
	&& chmod 777 -R /opt/shiny-server/samples/sample-apps 


# Cleanup
RUN \
  rm -rf /home/builder/* && \
  userdel builder && \
  yum autoremove -y

# Add default root password with password r00tpassw0rd
RUN \
  echo "root:r00tpassw0rd" | chpasswd  

# Add default rstudio user with pass rstudio
RUN \
  useradd rstudio && \
  echo "rstudio:rstudio" | chpasswd && \ 
  chmod -R +r /home/rstudio
  
# Apache ports
EXPOSE 80
EXPOSE 443
EXPOSE 8004
EXPOSE 9001
EXPOSE 3838

USER root

# Add supervisor conf files
ADD \
  rstudio-server.conf /etc/supervisor/conf.d/rstudio-server.conf
ADD \
  opencpu.conf /etc/supervisor/conf.d/opencpu.conf 
ADD \
  shiny-server.conf /etc/supervisor/conf.d/shiny-server.conf

# install additional packages
ADD \ 
  installpackages.sh /usr/local/bin/installpackages.sh
RUN \
  chmod +x /usr/local/bin/installpackages.sh && \
  /usr/local/bin/installpackages.sh
  
# Define default command.
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
