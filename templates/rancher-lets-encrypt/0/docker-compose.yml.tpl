version: '2'
services:
  letsencrypt-nginx:
    image: nginx:alpine
    environment:
      - SERVICE_IGNORE=true
    ports:
      - ${HOST_CHECK_PORT}:80
    volumes:
      - letsencrypt-verify:/usr/share/nginx/html/
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: rancher-lets-encrypt

  rancher-lets-encrypt:
    image: tozny/rancher-lets-encrypt
    environment:
      - SERVICE_IGNORE=true
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
    external: {{.Values.EXTERNAL_VOLUME}}
    {{- if .Values.STORAGE_DRIVER_OPT}}
    driver_opts:
      {{.Values.STORAGE_DRIVER_OPT}}
    {{- end }}
    {{- end }}