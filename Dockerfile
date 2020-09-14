
FROM amazonlinux:latest

RUN yum -y install unzip aws-cli git tar
RUN yum install -y gcc-c++ make
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -
RUN yum install -y nodejs
WORKDIR /tmp
RUN git clone https://host.com.br/diretorio/script_migracao.git
RUN cd script_migracao && npm install
ADD .env script_migracao/
ADD carga.sh . 

ENTRYPOINT ["/tmp/carga.sh"]

