version: '2'
services:
  letsencrypt-nginx:
    image: nginx:alpine
    volumes:
      - letsencrypt-verify:/usr/share/nginx/html/
    labels:
      io.rancher.sidekicks: rancher-lets-encrypt

  rancher-lets-encrypt:
    image: tozny/rancher-lets-encrypt
    # If there is only a key, Rancher Compose will resolve to the values
    # on the machine or the file passed in using --env-file.
    # If the values are set using Rancher's UI, they will override the values from the .env file
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
      {{- if .Values.VOLUME_NAME}}
      - {{.Values.VOLUME_NAME}}:/etc/letsencrypt
      {{- end }}
    labels:
      # if we add the container as a rancher agent, we get magical things like Rancher server URL, and access keys for F-R-E-E!
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: environment
{{- if .Values.VOLUME_NAME}}
volumes:
  {{.Values.VOLUME_NAME}}:
    {{- if .Values.STORAGE_DRIVER}}
    driver: {{.Values.STORAGE_DRIVER}}
    {{- if .Values.STORAGE_DRIVER_OPT}}
    driver_opts:
      {{.Values.STORAGE_DRIVER_OPT}}
    {{- end }}
    {{- end }}
{{- end }}
