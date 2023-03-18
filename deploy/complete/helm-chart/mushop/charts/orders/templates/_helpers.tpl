{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "orders.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "orders.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "orders.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "orders.labels" -}}
app.kubernetes.io/name: {{ include "orders.name" . }}
helm.sh/chart: {{ include "orders.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}


{{/* OADB Connection environment */}}
{{- define "orders.oadb.connection" -}}
{{- $globalOsb := index (.Values.global | default .) "osb" -}}
{{- $usesOsbDb := (index (.Values.global | default .Values) "osb").atp | default .Values.osb.atp -}}
{{- $secretPrefix := (and .Values.osb.atp .Chart.Name) | default (and $globalOsb.atp ($globalOsb.instanceName | default "mushop")) | default .Chart.Name -}}
{{- $connectionSecret := (and $usesOsbDb (printf "%s-oadb-connection" $secretPrefix)) | default .Values.oadbConnectionSecret | default (.Values.global.oadbConnectionSecret | default (printf "%s-oadb-connection" $secretPrefix)) -}}
{{- $credentialSecret := (and $usesOsbDb (printf "%s-oadb-credentials" $secretPrefix)) | default .Values.oadbUserSecret | default (printf "%s-oadb-credentials" $secretPrefix) -}}
- name: OADB_USER
  {{- if $globalOsb.atp }}
  value: {{ printf "mu_%s_user" .Chart.Name }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: oadb_user
  {{- end }}
- name: OADB_PW
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: oadb_pw
- name: OADB_SERVICE
  valueFrom:
    secretKeyRef:
      name: {{ $connectionSecret }}
      key: oadb_service
{{- end -}}

{{/* OADB ADMIN environment */}}
{{- define "orders.oadb.admin" -}}
{{- $globalOsb := index (.Values.global | default .) "osb" -}}
{{- $usesOsbDb := (index (.Values.global | default .Values) "osb").atp | default .Values.osb.atp -}}
{{- $secretPrefix := (and .Values.osb.atp .Chart.Name) | default (and $globalOsb.atp ($globalOsb.instanceName | default "mushop")) | default .Chart.Name -}}
{{- $adminSecret := (and $usesOsbDb (printf "%s-oadb-admin" $secretPrefix)) | default .Values.oadbAdminSecret | default .Values.global.oadbAdminSecret | default (printf "%s-oadb-admin" $secretPrefix) -}}
- name: OADB_ADMIN_PW
  valueFrom:
    secretKeyRef:
      name: {{ $adminSecret }}
      key: oadb_admin_pw
{{- end -}}

{{/* OADB Wallet mount */}}
{{- define "orders.mount.wallet" -}}
# for init container
- name: wallet
  mountPath: /wallet/
  readOnly: true
{{- end -}}

{{- define "orders.mount.init.wallet" -}}
# for init container
- name: wallet
  mountPath: /usr/lib/oracle/19.3/client64/lib/network/admin/
  readOnly: true
{{- end -}}

{{/* OADB Wallet BINDING initContainer */}}
{{- define "orders.init.wallet" -}}
{{- $usesOsb := (index (.Values.global | default .Values) "osb").atp | default .Values.osb.atp -}}
{{- if $usesOsb }}
# OSB Wallet Binding decoder
- name: decode-binding
  image: oraclelinux:7-slim
  command: ["/bin/sh","-c"]
  args: 
  - for i in `ls -1 /tmp/wallet | grep -v user_name`; do cat /tmp/wallet/$i | base64 --decode > /wallet/$i; done; ls -l /wallet/*;
  volumeMounts:
    - name: wallet-binding
      mountPath: /tmp/wallet
      readOnly: true
    - name: wallet
      mountPath: /wallet
      readOnly: false
{{- end -}}
{{- end -}}

{{/* OADB dbtools mount template */}}
{{- define "orders.mount.initdb" -}}
- name: initdb
  mountPath: /work/
{{- end -}}

{{/* CONTAINER VOLUME TEMPLATE */}}
{{- define "orders.volumes" -}}
{{- $globalOsb := index (.Values.global | default .) "osb" -}}
{{- $wallet := .Values.oadbWalletSecret | default (.Values.global.oadbWalletSecret | default (printf "%s-oadb-wallet" .Chart.Name)) -}}
{{- $walletBinding :=  printf "%s-oadb-wallet-binding" ((and .Values.osb.atp .Chart.Name) | default $globalOsb.instanceName | default "mushop") -}}
{{- if or .Values.osb.atp $globalOsb.atp }}
# OSB wallet binding
- name: wallet-binding
  secret:
    secretName: {{ $walletBinding }}
- name: wallet
  emptyDir: {}
{{- else }}
# local wallet
- name: wallet
  secret:
    secretName: {{ $wallet }}
{{- if ne .Values.global.mock.service "all" }}
    defaultMode: 256
{{- end }}
{{- end }}
# service init configMap
- name: initdb
  configMap:
    name: {{ include (printf "%s.fullname" .Chart.Name) . }}-init
    items:
    - key: atp.init.sql
      path: service.sql
{{- end -}}