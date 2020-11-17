---
title: "Use Case"
date: 2020-03-10T13:29:23-06:00
draft: false
tags:
  - observability
  - Monitoring
  - Metrics Explorer
  - Custom Logging
  - Logging
  - Alarms
  - Notifications
---

### Prerequisites

- Complete the [Setup]({{< ref "setup.md" >}})

### Payment Failures

Navigate to MuShop application at [http://localhost:8000](http://localhost:8000) if using `kubectl port-forward` as discussed under [Setup]({{< ref "setup.md" >}}) and add items to cart to exceed the amount greater than $105 and `PLACE ORDER`.
The request will be denied with HTTP 406 "Request Not Acceptable"

Click on `PLACE ORDER` 9-10 times just to create some additional failure log data.

### Observe

Navigate to OCI Console ``Monitoring -> Metrics Explorer``

    Compartment: <Your_Compartment_Name>
    Metric Namespace: <Your_MetricNamespace>
    Metric Name: <Your_MetricName>  
    Dimension Name: <Optional_DimensionName>
    Dimension Value: <Optional_DimensionValue>

Note: The custom metric namespace is create during [Setup]({{< ref "setup.md" >}}) and it should be visible here. Else, wait for some time, send some more HTTP Status 406 requests (By placing orders above $105 as discussed) and check back again.

Click on "Update Chart" with the above fields selected to see the metrics.

![metric-explorer](../../images/metric-explorer.png)

### Setting Alarms

In Metric Explorer once you have chosen the metric namespace and all its attributes, select create alarm

    Alarm Name: <Name_Of_Your_Alarm>
    Metric Namespace: <Your_MetricNamespace>
    Trigger rule: <value equal to 1 with trigger delay 0 minutes>
    Destination: <Select your notifications topic>

Send some more HTTP Status 406 requests (By placing orders above $105 as discussed) and you will start receiving emails like this

![alarm-mail](../../images/alarm-mail.png)

### Analyze the logs

Navigate to ```Agent Configurations -> <your_agent_config> -> Explore log```

![agent-logs](../../images/agent-logs.png)

You will see a failure in the logs as below:
```Payment declined: amount exceeds 105.00```

![json-log-details](../../images/json-log-details.png)

Note: Notice the logContent.data which are nicely formatted based on our regex expression we provided during agent configuration (Advanced parser).

### Summary

We performed the following actions:
- Setup the OCI logging agents on the OKE worker nodes to send pod logs on to OCI logging.
- Setup service connector between OCI logging and OCI monitoring with a new custom monitoring namespace.
- Simulated the payment failures on MuShop application. 

The orders service logs the payment failure details and the agent config filters the specific message that we setup as part of OCI logging agent setup (fluentd regexp parser).

Service connector helps to send the payment failures onto OCI Monitoring which then helped us to view the metrics on a dashboard. We then set alarm for that metric to get alerts on our email. 
We also, analyzed the logs to root cause the issue which was "Payment above 105 were getting declined".
