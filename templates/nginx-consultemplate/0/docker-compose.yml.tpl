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
      - LOG_LEVEL=debug
      - SERVICE_IGNORE=true
    volumes_from:
      - nginx-config
      - nginx-log
    expose:
      - 80
      - 5672
    external_links:
     - $consul_service:consul
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: nginx-config,nginx-log
      io.rancher.container.pull_image: always

  lb:
      image: rancher/lb-service-haproxy:v0.7.9
      environment:
      - SERVICE_IGNORE=true
      labels:
        io.rancher.container.hostname_override: container_name
        io.rancher.container.agent.role: environmentAdmin
        io.rancher.container.create_agent: 'true'
        io.rancher.lb_service.cert_dir: /certs/live
        io.rancher.lb_service.default_cert_dir: /certs/live/${PUBLIC_DNS_HOSTNAME}
      volumes:
        - ${VOLUME_NAME}:/certs

  letsencrypt-nginx:
    image: nginx:alpine
    volumes:
      - letsencrypt-verify:/usr/share/nginx/html/
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: rancher-lets-encrypt

  rancher-lets-encrypt:
    image: tozny/rancher-lets-encrypt
    environment:
      - DOMAINS=${DOMAINS}
      - CERTBOT_WEBROOT=${CERTBOT_WEBROOT}
      - CERTBOT_EMAIL=${CERTBOT_EMAIL}
      - RENEW_BEFORE_DAYS=${RENEW_BEFORE_DAYS}
      - LOOP_TIME=${LOOP_TIME}
      - STAGING=${STAGING}
      - HOST_CHECK_PORT=${HOST_CHECK_PORT}
      - HOST_CHECK_LOOP_TIME=${HOST_CHECK_LOOP_TIME}
    volumes:
      - letsencrypt-verify:${CERTBOT_WEBROOT}
      - ${VOLUME_NAME}:/etc/letsencrypt
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: environment
volumes:
  {{.Values.VOLUME_NAME}}:
    {{- if .Values.STORAGE_DRIVER}}
    driver: {{.Values.STORAGE_DRIVER}}
    {{- if .Values.STORAGE_DRIVER_OPT}}
    driver_opts:
      {{.Values.STORAGE_DRIVER_OPT}}
    {{- end }}
    {{- end }}