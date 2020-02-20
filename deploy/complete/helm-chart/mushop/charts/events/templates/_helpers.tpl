{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "events.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "events.fullname" -}}
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
{{- define "events.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "events.labels" -}}
app.kubernetes.io/name: {{ include "events.name" . }}
helm.sh/chart: {{ include "events.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* OSS Configurations */}}
{{- define "events.env.stream" -}}
{{- if ne .Values.global.mock.service "all" }}
{{- $globalOsb := index (.Values.global | default .) "osb" -}}
{{- $usesOsb := (index .Values.global "osb").oss  -}}
{{- $bindingSecret := printf "%s-oss-binding" ($globalOsb.instanceName | default "mushop") -}}
{{- $streamSecret := (and $usesOsb $bindingSecret) | default .Values.global.ossStreamSecret | default (printf "%s-oss-connection" .Release.Name) -}}
{{- $credentialSecret := required "Value .ociAuthSecret is required!" (.Values.ociAuthSecret | default .Values.global.ociAuthSecret) -}}
# API credentials
- name: TENANCY
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: tenancy
- name: REGION
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: region
      optional: true
- name: USER_ID
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: user
- name: PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: privatekey
- name: FINGERPRINT
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: fingerprint
- name: PASSPHRASE
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: passphrase
      optional: true
# Stream connection
- name: STREAM_ID
  valueFrom:
    secretKeyRef:
      name: {{ $streamSecret }}
      key: streamId
- name: MESSAGES_ENDPOINT
  valueFrom:
    secretKeyRef:
      name: {{ $streamSecret }}
      key: messageEndpoint
      optional: true
{{- end -}}
{{- end -}}