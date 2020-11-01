---
title: "OCI Logging"
date: 2020-03-10T13:29:23-06:00
draft: false
weight: 3
tags:
  - oci logging
---

### Introduction

The Oracle Cloud Infrastructure Logging service is a highly scalable and fully managed single pane of glass for all the logs in a tenancy. 

In this section we will be enabling OCI logging for OKE worker nodes. 

All the OKE pod logs (stdout and stderr) are written to /var/log/containers in a JSON format by default.

Example:  
```
Log File Name Format: <Pod>_<NameSpace>_<ContainerName>-<ContainerID>.log
Log File Content Format:  {"log":"<message>","stream":"<stdout|stderr>","time":"<timestamp>"}
```

{{% alert style="warning" icon="warning" %}}
Ensure that the worker nodes are running OL 7.6 and above.
{{% /alert %}}

### Pre-Requisites

Deploy [Mushop]({{< ref "setup.md" >}})

### Create a Dynamic Group

Create a dynamic group and add your worker nodes.
Navigate to ```Identity -> Dynamic Groups -> Create Dynamic Group``` 

    Name: <DynamicGroupName>
    Description: <DynamicGroupDescription>
    Matching Rules: any {instance.compartment.id = 'CompartmentOCID'}

### Create a  IAM Policy

Navigate to ```Identity -> Policies -> Create Policy``` 

    Name: <PolicyName>
    Description: <PolicyDescription>
    Policy Versioning: Keep version current
    Statement: allow dynamic-group <DynamicGroupName> to use log-content in tenancy

### Enable Logging

To enable Logging on OKE, perform the following actions:

- Create a Log Group - This is a logical container for organizing logs, Identity and Access Management (IAM) policies can control who has access to a Log Group.
- Create a Custom Log - The Custom Log will contain all information that is uploaded by the Agent Configuration.
- Create an Agent Configuration - Defines the Source Log location and relevant Parsers along with the Dynamic Group containing all the Instance to which the configuration should apply.

### Create a Log Group

Navigate to ``` Logging -> Log Groups -> Create Log Group```

    Compartment: <SelectCompartment
    Name: <LogGroupName>
    Description:  <LogGroupDescription>

### Create a Custom Log

Navigate to ```Logging -> Logs -> Create Custom Log```

    Custom Log Name: <CustomLogName>
    Compartment: <SelectCompartment>
    Log Group: <SelectLogGroup>
    Show Additional Option:
    Select Log Retention: 1, 2, 3, 4, 5 or 6 months

### Create Agent Configuration

Navigate to ```Logging -> Agent Configurations -> Create Agent Config```

    Configuration Name: <ConfigurationName>
    Compartment: <SelectCompartment>
    Group Type: Dynamic Group
    Group: <SelectDynamicGroup>
    Configure Log Inputs:
        Input Type: Log Path
        Input Name: <InputName>
        File Paths: /var/log/containers/*.log
    Advanced Parser Options:
        Parser: JSON
        Time Type: String
          Time Format: %Y-%m-%dT%H:%M:%S.%NZ
    Select Log Destination:
        Compartment: <SelectCompartment>
        Log Group: <SelectLogGroup>
        Log Name: <SelectLogName>

{{% alert style="warning" icon="warning" %}}
In production we could have 2 log groups (mushop-service and mushop-utilities) and create 2 Agent configurations with files paths /var/log/containers/\*\_mushop\_\* for mushop-service to collect all container logs from mushop namespace. Similarly, /var/log/containers/\*\_mushop-utilities\_\* to collect all container logs from mushop-utilities namespace.
{{% /alert %}}

### Explore the logs

Access the mushop application using either the Ingress controller or kubernetes port forwarding as mentioned under [setup]({{< ref "setup.md" >}}). 
Perform some actions, Add items to ```Cart -> Place Order```

Navigate to ```Logging -> Search``` and start exploring the logs.