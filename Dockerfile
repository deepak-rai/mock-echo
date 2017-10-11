FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y curl elinks wget supervisor
RUN apt-get update
RUN apt-get install --yes nodejs
RUN apt-get install --yes build-essential
RUN apt-get update
RUN apt-get install -y npm
RUN apt-get update
RUN update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10
RUN npm install csv-parse raw-body content-type csv-parse csv formidable st path sql.js uuid randomstring date-and-time time

ENV appdir /var/lib/mock-echo
ENV logdir /var/logs/mock-echo
ENV fileUploadDir /var/lib/mock-echo/file_upload

RUN mkdir -p ${appdir} ${logdir} ${fileUploadDir} /var/log/supervisor

ADD start_server.sh ${appdir}/start_server.sh
ADD index.js ${appdir}/index.js
ADD mock-echo.conf /etc/supervisor/conf.d/mock-echo.conf

RUN chmod +x ${appdir}/start_server.sh

CMD ["/usr/bin/supervisord"]
