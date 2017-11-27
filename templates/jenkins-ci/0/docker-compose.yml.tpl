version: '2'
services:
  jenkins-primary:
    image: "jenkins:2.60.3"
    ports:
      - "${PORT}:8080"
    labels:
      io.rancher.sidekicks: jenkins-plugins,jenkins-datavolume
      io.rancher.container.hostname_override: container_name
    volumes_from:
      - jenkins-plugins
      - jenkins-datavolume
    entrypoint: /usr/share/jenkins/rancher/jenkins.sh
  jenkins-plugins:
    image: rancher/jenkins-plugins:v0.1.1
  jenkins-datavolume:
    image: artifactory.devops.itaas-cloud.com:6553/jenkins-terraform:latest
    volumes:
      - ${VOLUME_NAME}:/var/jenkins_home
    labels:
      io.rancher.container.start_once: true
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
