version: '2'
services:
  rabbitmq-config:
    image: artifactory.devops.itaas-cloud.com:6553/rabbitmq-config:latest
    environment:
      - rancher=1
      - RABBITMQ_CLUSTER_PARTITION_HANDLING=autoheal
      - RABBITMQ_NET_TICKTIME=60
      - RABBITMQ_DEFAULT_USER=$rabbitmq_user
      - RABBITMQ_DEFAULT_PASS=$rabbitmq_pass
    volumes_from:
      - rabbitmq-data
    external_links:
      - $consul_service:consul
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.pull_image: always


  rabbitmq-data:
    image: rabbitmq:3.6.11-management-alpine
    entrypoint: /bin/true
    network_mode: "none"
    volumes:
      - ${VOLUME_NAME}:/var/lib/rabbitmq
      - /etc/rabbitmq
      - /opt/rancher/bin
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: true
      io.rancher.container.pull_image: always

  rabbitmq:
    image: rabbitmq:3.6.11-management-alpine
    environment:
      - rancher=1
      - RABBITMQ_ERLANG_COOKIE=$erlang_cookie
      - RABBITMQ_DEFAULT_USER=$rabbitmq_user
      - RABBITMQ_DEFAULT_PASS=$rabbitmq_pass
      - SERVICE_IGNORE=true
      - LOCATION_KEY=$location_key
      - GLOBAL=true
    #entrypoint: /opt/rancher/bin/run.sh
    entrypoint: /etc/rabbitmq/run.sh    
    external_links:
      - $consul_service:consul
    expose:
      - 5672
      - 15672
    volumes_from:
      - rabbitmq-data
    restart: always
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: rabbitmq-data, rabbitmq-config
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
