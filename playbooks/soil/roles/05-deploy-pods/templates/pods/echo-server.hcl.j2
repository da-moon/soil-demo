#-*-mode:hcl;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: ft=hcl tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
pod "echo-server-pod" {
  runtime = true
  target = "default.target"
  provider "range" "port" {
    min = 3000
    max = 4000
  }
  resource "echo-server-pod.port" "listener" {}
  unit "http-echo.service" {
    permanent = false
    create = "start"
    update = "restart"
    destroy = "stop"
    source = <<EOF
      [Unit]
      [Service]
      SyslogIdentifier=%p
      Restart=on-failure
      RestartSec=30
      ExecStartPre=/usr/bin/docker pull fjolsvin/http-echo-rs:latest
      ExecStart=/usr/bin/docker run \
        --publish ${resource.echo-server-pod.listener.value}:5678 \
        --rm fjolsvin/http-echo-rs:latest \
        --text="Soil Deployment Example"
      ExecReload=/usr/bin/docker kill -s HUP %p
      [Install]
      WantedBy=multi-user.target
    EOF
  }
}
