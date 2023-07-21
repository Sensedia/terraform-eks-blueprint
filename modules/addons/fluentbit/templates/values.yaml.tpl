image:
  repository: public.ecr.aws/aws-observability/aws-for-fluent-bit
  tag: ${image_tag}
  pullPolicy: Always


service:
  extraService: |
    Flush                     5
    Grace                     30
    Log_Level                 info
    Daemon                    off
    Parsers_File              parsers.conf
    HTTP_Server               $${HTTP_SERVER}
    HTTP_Listen               0.0.0.0
    HTTP_Port                 $${HTTP_PORT}
    storage.path              /var/fluent-bit/state/flb-storage/
    storage.sync              normal
    storage.checksum          off
    storage.backlog.mem_limit 5M
  parsersFiles: []
  extraParsers: |
    [PARSER]
        Name                docker
        Format              json
        Time_Key            time
        Time_Format         %Y-%m-%dT%H:%M:%S.%LZ

    [PARSER]
        Name                syslog
        Format              regex
        Regex               ^(?<time>[^ ]* {1,2}[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$
        Time_Key            time
        Time_Format         %b %d %H:%M:%S

    [PARSER]
        Name                container_firstline
        Format              regex
        Regex               (?<log>(?<="log":")\S(?!\.).*?)(?<!\\)".*(?<stream>(?<="stream":").*?)".*(?<time>\d{4}-\d{1,2}-\d{1,2}T\d{2}:\d{2}:\d{2}\.\w*).*(?=})
        Time_Key            time
        Time_Format         %Y-%m-%dT%H:%M:%S.%LZ

    [PARSER]
        Name                cwagent_firstline
        Format              regex
        Regex               (?<log>(?<="log":")\d{4}[\/-]\d{1,2}[\/-]\d{1,2}[ T]\d{2}:\d{2}:\d{2}(?!\.).*?)(?<!\\)".*(?<stream>(?<="stream":").*?)".*(?<time>\d{4}-\d{1,2}-\d{1,2}T\d{2}:\d{2}:\d{2}\.\w*).*(?=})
        Time_Key            time
        Time_Format         %Y-%m-%dT%H:%M:%S.%LZ

# Disable default input
input:
  enabled: false
additionalInputs: |
  [INPUT]
      Name                tail
      Tag                 application.*
      Exclude_Path        /var/log/containers/cloudwatch-agent*, /var/log/containers/fluent-bit*
      Path                /var/log/containers/*.log
      Docker_Mode         On
      Docker_Mode_Flush   5
      Docker_Mode_Parser  container_firstline
      Parser              docker
      DB                  /var/fluent-bit/state/flb_container.db
      Mem_Buf_Limit       50MB
      Skip_Long_Lines     On
      Refresh_Interval    10
      Rotate_Wait         30
      storage.type        filesystem
      Read_from_Head      $${READ_FROM_HEAD}

  [INPUT]
      Name                tail
      Tag                 application.*
      Path                /var/log/containers/fluent-bit*
      Parser              docker
      DB                  /var/fluent-bit/state/flb_log.db
      Mem_Buf_Limit       5MB
      Skip_Long_Lines     On
      Refresh_Interval    10
      Read_from_Head      $${READ_FROM_HEAD}

  [INPUT]
      Name                tail
      Tag                 application.*
      Path                /var/log/containers/cloudwatch-agent*
      Docker_Mode         On
      Docker_Mode_Flush   5
      Docker_Mode_Parser  cwagent_firstline
      Parser              docker
      DB                  /var/fluent-bit/state/flb_cwagent.db
      Mem_Buf_Limit       5MB
      Skip_Long_Lines     On
      Refresh_Interval    10
      Read_from_Head      $${READ_FROM_HEAD}

  [INPUT]
      Name                systemd
      Tag                 dataplane.systemd.*
      Systemd_Filter      _SYSTEMD_UNIT=docker.service
      Systemd_Filter      _SYSTEMD_UNIT=kubelet.service
      DB                  /var/fluent-bit/state/systemd.db
      Path                /var/log/journal
      Read_From_Tail      $${READ_FROM_TAIL}

  [INPUT]
      Name                tail
      Tag                 host.dmesg
      Path                /var/log/dmesg
      Parser              syslog
      DB                  /var/fluent-bit/state/flb_dmesg.db
      Mem_Buf_Limit       5MB
      Skip_Long_Lines     On
      Refresh_Interval    10
      Read_from_Head      $${READ_FROM_HEAD}

  [INPUT]
      Name                tail
      Tag                 host.messages
      Path                /var/log/messages
      Parser              syslog
      DB                  /var/fluent-bit/state/flb_messages.db
      Mem_Buf_Limit       5MB
      Skip_Long_Lines     On
      Refresh_Interval    10
      Read_from_Head      $${READ_FROM_HEAD}

  [INPUT]
      Name                tail
      Tag                 host.secure
      Path                /var/log/secure
      Parser              syslog
      DB                  /var/fluent-bit/state/flb_secure.db
      Mem_Buf_Limit       5MB
      Skip_Long_Lines     On
      Refresh_Interval    10
      Read_from_Head      $${READ_FROM_HEAD}

# Disable default filters
filter:
  enabled: false
additionalFilters: |
  [FILTER]
      Name                kubernetes
      Match               application.*
      Kube_URL            https://kubernetes.default.svc:443
      Kube_Tag_Prefix     application.var.log.containers.
      Merge_Log           On
      Merge_Log_Key       log_processed
      K8S-Logging.Parser  On
      K8S-Logging.Exclude Off
      Annotations         Off

  [FILTER]
      Name                  multiline
      Match                 application.*
      multiline.key_content log
      multiline.parser      java

  [FILTER]
      Name                nest
      Match               application.*
      Operation           lift
      Nested_under        kubernetes
      Add_prefix          Nested.

  [FILTER]
      Name                modify
      Match               application.*
      Rename              Nested.docker_id            Docker.container_id
  
  [FILTER]
      Name                nest
      Match               application.*
      Operation           nest
      Wildcard            Nested.*
      Nested_under        kubernetes
      Remove_prefix       Nested.
  
  [FILTER]
      Name                nest
      Match               application.*
      Operation           nest
      Wildcard            Docker.*
      Nested_under        docker
      Remove_prefix       Docker.

  [FILTER]
      Name                grep
      Match               *
      Exclude             log java.net.UnknownHostException: ENVIRONMENT
      Exclude             log java.lang.NullPointerException
      Exclude             log Cannot execute custom interceptor 
      Exclude             log Access denied for this environment
      Exclude             log org.mozilla.javascript.JavaScriptException
      Exclude             log app.jar
      Exclude             log GenericCustom
      Exclude             log Thread.java 
      Exclude             log org.apache.catalina
      Exclude             log oFilter
      Exclude             log Dispatch
      Exclude             log nvoke
      Exclude             log org.springframework.web
      Exclude             log service
      Exclude             log org.apache.tomcat.util.net
      Exclude             log org.apache.coyote
      Exclude             log processCookies
      Exclude             log WARNING: Invalid cookie
      Exclude             log empty Sensedia Key

  [FILTER]
      Name                modify
      Match               dataplane.systemd.*
      Rename              _HOSTNAME                   hostname
      Rename              _SYSTEMD_UNIT               systemd_unit
      Rename              MESSAGE                     message
      Remove_regex        ^((?!hostname|systemd_unit|message).)*$

  [FILTER]
      Name                aws
      Match               dataplane.*
      imds_version        v2

  [FILTER]
      Name                aws
      Match               host.*
      imds_version        v2


# Disable default outputs
cloudWatch:
  enabled: false
cloudWatchLogs:
  enabled: false
firehose:
  enabled: false
kinesis:
  enabled: false
elasticsearch:
  enabled: false
s3:
  enabled: false
opensearch:
  enabled: false
additionalOutputs: |
  [OUTPUT]
      Name                cloudwatch
      Match               application.*
      region              $${AWS_REGION}
      log_group_name      /aws/containerinsights/$${CLUSTER_NAME}/application
      log_stream_name     $(tag[4])
      auto_create_group   true
      extra_user_agent    container-insights
      log_retention_days  ${cw_retention_in_days}
      new_log_group_tags  ${tags}

  [OUTPUT]
      Name                cloudwatch
      Match               dataplane.systemd.*
      region              $${AWS_REGION}
      log_group_name      /aws/containerinsights/$${CLUSTER_NAME}/dataplane
      log_stream_name     $(tag[2]).$(tag[3])-$(hostname)
      auto_create_group   true
      extra_user_agent    container-insight
      log_retention_days  ${cw_retention_in_days}
      new_log_group_tags  ${tags}

  [OUTPUT]
      Name                cloudwatch
      Match               host.*
      region              $${AWS_REGION}
      log_group_name      /aws/containerinsights/$${CLUSTER_NAME}/host
      log_stream_name     $(tag)-$(host)
      auto_create_group   true
      extra_user_agent    container-insights
      log_retention_days  ${cw_retention_in_days}
      new_log_group_tags  ${tags}

serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: ${irsa_iam_role_arn}

tolerations: 
  - key: node-role.kubernetes.io/master
    operator: Exists
    effect: NoSchedule
  - operator: "Exists"
    effect: "NoExecute"
  - operator: "Exists"
    effect: "NoSchedule"

affinity: 
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: eks.amazonaws.com/compute-type
          operator: NotIn
          values:
          - fargate

env: 
  - name: AWS_REGION
    value: ${region}
  - name: CI_VERSION
    value: "k8s/1.3.14"
  - name: CLUSTER_NAME
    value: ${cluster_name}
  - name: HOST_NAME
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
  - name: HTTP_SERVER
    value: "On"
  - name: HTTP_PORT
    value: "2020"
  - name: READ_FROM_HEAD
    value: "Off"
  - name: READ_FROM_TAIL
    value: "On"


volumes:
  - name: fluentbitstate
    hostPath:
      path: /var/fluent-bit/state
  - name: varlog
    hostPath:
      path: /var/log
  - name: varlibdockercontainers
    hostPath:
      path: /var/lib/docker/containers
  - name: runlogjournal
    hostPath:
      path: /run/log/journal
  - name: dmesg
    hostPath:
      path: /var/log/dmesg

volumeMounts:
  - name: fluentbitstate
    mountPath: /var/fluent-bit/state
  - name: varlog
    mountPath: /var/log
    readOnly: true
  - name: varlibdockercontainers
    mountPath: /var/lib/docker/containers
    readOnly: true
  - name: runlogjournal
    mountPath: /run/log/journal
    readOnly: true
  - name: dmesg
    mountPath: /var/log/dmesg
    readOnly: true
