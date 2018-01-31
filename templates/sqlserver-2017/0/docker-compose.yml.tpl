version: '2'
services:
  sql:
    image: microsoft/mssql-server-linux:2017-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=${SA_PASSWORD} 
      - VAULT_REDIRECT_INTERFACE=eth0
      - SERVICE_IGNORE=true
    external_links:
      - $consul_service:consul
    ports:
      - 1433
    volumes:
      - $VOLUME_NAME:/var/opt/mssql
    labels:
      io.rancher.sidekicks: sqlscripts
      io.rancher.container.hostname_override: container_name
      io.rancher.container.pull_image: always
  
  sqlscripts:
    image: artifactory.devops.itaas-cloud.com:6553/sql-init:latest
    environment:
      - rancher=1
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
    external: true
    {{- end }}