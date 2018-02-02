version: '2'
services:

  registrator:
    image: gliderlabs/registrator:master
    volumes:
     - /var/run/docker.sock:/tmp/docker.sock
    command:
     - -internal=false
     - -useIpFromLabel=io.rancher.container.ip
     - consul://consul:8500

    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.scheduler.global: true
      io.rancher.container.pull_image: always

  consul:
    image: artifactory.devops.itaas-cloud.com:6553/consul-base:latest
    environment:
      - rancher=1
      - SERVICE_8500_IGNORE=true
      - SERVICE_8300_IGNORE=true
      - SERVICE_8301_IGNORE=true
      - SERVICE_8302_IGNORE=true
      - SERVICE_8600_IGNORE=true
    volumes:
      - ${VOLUME_NAME}:/consul/data
    expose:
      - 8300
      - 8301
      - 8301/udp
      - 8302
      - 8302/udp
      - 8500
      - 8600
      - 8600/udp
    ports:
      - 8300:8300
      - 8301:8301
      - 8301:8301/udp
      - 8302:8302
      - 8302:8302/udp
      - 8500:8500
      - 8600:8600
      - 8600:8600/udp
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.pull_image: always

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

  