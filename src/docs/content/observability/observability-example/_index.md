---
title: "Observability Example"
date: 2020-10-26 T16:04:15-06:00
draft: false
weight: 110
showChildren: true
---

## Introduction

In this section we will try to understand Observability on Oracle Cloud Infrastructure (OCI) by simulating a failure scenario on MuShop application.

![observability-scenario](../images/observability-scenario.png)

## Scenario Details
- User logs in to MuShop and orders items with value more than $105. Currently, payment service is configured to decline all the orders above $105.
- User notices the order processing failure.
- User gets notified on the payment failure. 
- User analyzes the failure using Oracle Cloud Infrastructure(OCI) Observability Services.

## Next