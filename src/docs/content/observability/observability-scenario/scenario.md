---
title: "Scenario"
date: 2020-03-10T13:29:23-06:00
draft: false
tags:
  - observability in action
---

### Pre-Requisites

- Deploy [Mushop]({{< ref "pre-requisites/setup.md" >}})
- Setup Oracle Cloud Infrastructure (OCI) Logging [OCI Logging]({{< ref "pre-requisites/oci-logging.md" >}})
- Setup Oracle Cloud Infrastructure (OCI) Notifications [OCI Notifications]({{< ref "pre-requisites/oci-notifications.md" >}})
- Setup Oracle Cloud Infrastructure (OCI) Service Connector Hub [OCI Service Connector Hub]({{< ref "pre-requisites/oci-service-connector.md" >}})

### Payment Failures

Navigate to MuShop application at [http://localhost:8000](http://localhost:8000) if using ```kubectl port-forward``` as discussed under [Mushop]({{< ref "pre-requisites/setup.md" >}}) and add items to cart to exceed the amount greater than $105.
The request will be denied with HTTP 406 "Request Not Acceptable"

Click on "place order" 4-5 times just to create some additional failure log data.

### Observe

Navigate to OCI Console ``Monitoring -> Metrics Explorer``

    Compartment: <Your_Compartment_Name>
    Metric Namespace: <Your_mushopnamespace>
    Metric Name: Payment-Failure    
    Dimension Name: pod-name
    Dimension Value: mushop-orders

Note: The metric namespace "<your_mushopnamespace>" should be visible. Else, wait for some time, send some more HTTP Status 406 requests and check back again.

Click on "Update Chart" with the above fields selected to see the metrics.

![Metric Explorer](../../images/metric-explorer.png)

### Setting Alarms

In Metric Explorer once you have chosen mushopnamespace and all its attributes, select create alarm

    Alarm Name: <Name_Of_Your_Alarm>
    Metric Namespace: mushopnamespace
    Trigger rule: <value equal to 406 with trigger delay 0 minutes>
    Destination: <Select your notifications topic>

Send some more HTTP Status 406 requests and you will start receiving emails like this

![Alarms notification](../../images/alarm-mail.png)

### Analyze the logs

Navigate to ```Agent Configurations -> <your_agent_config> -> Explore log```

![logs](../../images/agent-logs.png)

You will see a failure in the logs as below:
```Payment declined: amount exceeds 105.00```

![Detailed logs](../../images/json-log-details.png)

Note: Notice the logContent.data which are nicely formatted based on our regex expression we provided during agent configuration.

### Summary

We setup the OCI logging agents on the OKE worker nodes to send pod logs on to OCI logging.
We setup service connector between OCI logging and OCI monitoring with a new monitoring namespace.
Simulated the payment failures on MuShop application. 

The orders service logs the payment failure details and the agent config filters the specific message that we setup as part of OCI logging agent setup (fluentd regexp parser).

Service connector helped to send the payment failures onto OCI Monitoring which helped us view the metrics on a dashboard. We then set alarm for that metric to get alerts. 
We also, analyzed the logs to find out what the issue was "Payment above 105 were getting declined".
