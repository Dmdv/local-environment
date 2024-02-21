FROM --platform=linux/amd64 mcr.microsoft.com/mssql-tools:latest

ARG MSSQL_SA_PASSWORD
ENV MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD

WORKDIR /opt/migration
COPY ./migration .
COPY .env .

RUN ls -lah
RUN chmod +x ./run.sh

CMD ["./run.sh"]