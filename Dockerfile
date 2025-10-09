FROM node:lts AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm run postbuild

FROM httpd:2.4 AS runtime
COPY --from=build /app/dist /usr/local/apache2/htdocs/

# Configure Apache to write logs to both files AND stdout/stderr
RUN sed -i \
    -e 's/CustomLog \/proc\/self\/fd\/1 common/CustomLog \/proc\/self\/fd\/1 common\n    CustomLog \/usr\/local\/apache2\/logs\/access_log common/' \
    -e 's/ErrorLog \/proc\/self\/fd\/2/ErrorLog \/proc\/self\/fd\/2\n    ErrorLog \/usr\/local\/apache2\/logs\/error_log/' \
    -e 's/TransferLog \/proc\/self\/fd\/1/TransferLog \/proc\/self\/fd\/1\n    TransferLog \/usr\/local\/apache2\/logs\/transfer_log/' \
    /usr/local/apache2/conf/httpd.conf

EXPOSE 80
