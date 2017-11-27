version: '2'
services:
  jenkins-primary:
    image: "jenkins:2.60.3"
    ports:
      - "${PORT}:8080"
    labels:
      io.rancher.sidekicks: jenkins-plugins, jenkins-config, jenkins-data
      io.rancher.container.hostname_override: container_name
    volumes_from:
      - jenkins-plugins
      - jenkins-data
    entrypoint: /usr/share/jenkins/rancher/jenkins.sh
  jenkins-plugins:
    image: rancher/jenkins-plugins:v0.1.1
  jenkins-config:
    image: artifactory.devops.itaas-cloud.com:6553/jenkins-config:latest
    environment:
      - Jenkins_User=${Jenkins_User}
      - Jenkins_Pass=${Jenkins_Pass}
      - Jenkins_Port=${PORT}
    depends_on:
      - jenkins-primary
    volumes:
      - ${VOLUME_NAME}:/var/jenkins_home
      - ${VOLUME_NAME}:/opt/chefdk
    labels:
      io.rancher.container.start_once: true
      io.rancher.container.pull_image: always
  jenkins-data:
    image: busybox
    volumes:
      - ${VOLUME_NAME}:/var/jenkins_home
      - ${VOLUME_NAME}:/opt/chefdk
    entrypoint: ["chown", "-R", "1000:1000", "/var/jenkins_home"]
    labels:
      io.rancher.container.start_once: true
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
