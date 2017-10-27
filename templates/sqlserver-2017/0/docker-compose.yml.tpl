version: '2'
services:
  sql:
    image: microsoft/mssql-server-linux:2017-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=${SA_PASSWORD} 
      - VAULT_REDIRECT_INTERFACE=eth0
      - SERVICE_1433_NAME=SQL
      - SERVICE_1433_TAGS=tcp-proxy
      - SERVICE_1433_ID=SQL:8200
    external_links:
      - $consul_service:consul
    expose:
      - 1433
    labels:
      io.rancher.sidekicks: sqlscripts
      io.rancher.container.hostname_override: container_name
      io.rancher.container.pull_image: always
  
  sqlscripts:
    image: artifactory.devops.itaas-cloud.com:6553/sql-init:latest
    environment:
      - SERVICE_IGNORE=true
      - Location_Key=${Location_Key}
      - Global=${Global}
    external_links:
      - $consul_service:consul
    entrypoint: ./run.sh sql ${SA_PASSWORD}
    depends_on:
      - sql
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: true
      io.rancher.container.pull_image: always
volumes:
  {{.Values.VOLUME_NAME}}:
    {{- if .Values.STORAGE_DRIVER}}
    driver: {{.Values.STORAGE_DRIVER}}
    {{- if .Values.STORAGE_DRIVER_OPT}}
    driver_opts:
      {{.Values.STORAGE_DRIVER_OPT}}
    {{- end }}
    {{- end }}