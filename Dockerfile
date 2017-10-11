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
RUN npm install csv-parse
RUN npm install raw-body
RUN npm install content-type
RUN npm install csv-parse
RUN npm install csv
RUN npm install formidable
RUN npm install st
RUN npm install path
RUN npm install sql.js
RUN npm install uuid
RUN npm install randomstring
RUN npm install date-and-time
RUN npm install time
# RUN npm install csv-parse raw-body content-type csv-parse csv formidable st path sql.js uuid randomstring date-and-time time

ENV appdir /var/lib/mock-echo
ENV logdir /var/logs/mock-echo
ENV fileUploadDir /var/lib/mock-echo/file_upload

RUN mkdir -p ${appdir} ${logdir} ${fileUploadDir} /var/log/supervisor

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.6.0

#RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
#  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
#  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
#  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
#  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
#  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

ADD start_server.sh ${appdir}/start_server.sh
ADD index.js ${appdir}/index.js

RUN chmod +x ${appdir}/start_server.sh

ADD mock-echo.conf /etc/supervisor/conf.d/mock-echo.conf

CMD ["/usr/bin/supervisord"]
