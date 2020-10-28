---
title: "Observability Scenario"
date: 2020-10-26 T16:04:15-06:00
draft: false
weight: 500
showChildren: true
---

## Introduction

In this section we will try to understand Observability on Oracle Cloud Infrastructure(OCI) by simulating a failure scenario using MuShop application.

![Failure-scenario](../../images/observability-scenario.png)

## Scenario
- User logs in to MuShop and Orders items more than 115.
- User notices the Order processing failure.
- User gets notified on the Payment failures. Note: In a production setup, application operations team would get paged.
- User analyzes the failure using Oracle Cloud Infrastructure(OCI) Observability Services.
- User delivers the fix. 
