version: '2'
services:
  nginx-config:
    image: artifactory.devops.itaas-cloud.com:6553/nginx-config:latest
    volumes:
      - /etc/nginx/config
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: true
      io.rancher.container.pull_image: always

  nginx-log:
    image: alpine:latest
    entrypoint:
      - /bin/true
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: true
      io.rancher.container.pull_image: always
    volumes:
      - /var/log/nginx

  nginx:
    image: artifactory.devops.itaas-cloud.com:6553/nginx-consultemplate:latest
    environment:
      - CONSUL_PORT_8500_TCP_ADDR=consul
      - CERT_NAME=${CERT_NAME}
      - TCP_SSL=${TCP_SSL}
      - HTTP_SSL=${HTTP_SSL}
      - LOG_LEVEL=debug
      - SERVICE_IGNORE=true
    volumes_from:
      - nginx-config
      - nginx-log
    volumes:
      - ${CERT_VOLUME}:/etc/letsencrypt
    ports:
      - 443:443
      - 8080:5672
    external_links:
     - $consul_service:consul
     extra_hosts:
     - $extra_host
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: nginx-config,nginx-log
      io.rancher.container.pull_image: always
  
volumes:
  {{.Values.CERT_VOLUME}}:
    {{- if .Values.STORAGE_DRIVER}}
    driver: {{.Values.STORAGE_DRIVER}}
    external: true
    {{- end }}