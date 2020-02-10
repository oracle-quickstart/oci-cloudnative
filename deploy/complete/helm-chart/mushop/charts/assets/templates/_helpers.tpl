{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "assets.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "assets.fullname" -}}
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
{{- define "assets.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "assets.labels" -}}
app.kubernetes.io/name: {{ include "assets.name" . }}
helm.sh/chart: {{ include "assets.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* OOS BUCKET PAR */}}
{{- define "assets.env.par" -}}
{{- $globalOsb := index (.Values.global | default .) "osb" -}}
{{- $usesOsbBucket := (index .Values.global "osb").objectstorage  -}}
{{- $bindingSecret := printf "%s-bucket-par-binding" ($globalOsb.instanceName | default "mushop") -}}
{{- $bucketSecret := .Values.global.oosBucketSecret | default (printf "%s-bucket" .Release.Name) -}}
{{- $credentialSecret := .Values.ociAuthSecret | default .Values.global.ociAuthSecret }}
{{- if $credentialSecret -}}
- name: REGION
  valueFrom:
    secretKeyRef:
      name: {{ $credentialSecret }}
      key: region
      optional: true
{{ end }}
- name: BUCKET_PAR
  valueFrom:
    secretKeyRef:
      {{- if $usesOsbBucket }}
      name: {{ $bindingSecret }}
      key: preAuthAccessUri
      {{- else }}
      name: {{ $bucketSecret }}
      key: parUrl
      optional: true
      {{- end -}}
{{- end -}}