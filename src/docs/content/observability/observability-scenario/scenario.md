---
title: "Scenario"
date: 2020-03-10T13:29:23-06:00
draft: false
tags:
  - observability in action
---

### Pre-Requisites

Deploy [Mushop]({{< ref "pre-requisites/setup.md" >}})
Setup Oracle Cloud Infrastructure (OCI) Logging [OCI Logging]({{< ref "pre-requisites/oci-logging.md" >}})
Setup Oracle Cloud Infrastructure (OCI) Notifications [OCI Notifications]({{< ref "pre-requisites/oci-notifications.md" >}})

### Scenario Details

Navigate to MuShop and add items to cart to exceed the amount greater than 105.
The request will be denied with HTTP 406 Request Not Acceptable.

### Observe

Navigate to OCI Console ``Monitoring -> Metrics Explorer``

Select 
    Compartment: <Your_Compartment_Name>
    Metric Namespace: mushopnamespace
    Metric Name: Payment-Failure    
    Dimension Name: pod-name
    Dimension Value: mushop-orders

Note: The metric namespace "mushopnamespace" should be visible. Else, wait for some more time, send some more 406 requests and check back again.

Click on "Update Chart" with the above fields selected to see the metrics.

![Metric Explorer](../../images/metric-explorer.png)

### Setting Alarms

In Metric Explorer once you have chosen mushopnamespace and all its attributes, select create alarm

    Alarm Name: <Name_Of_Your_Alarm>
    Metric Namespace: mushopnamespace
    Trigger rule: <value equal to 406 with trigger delay 0 minutes>
    Destination: <Select your notifications topic>

#### send some more 406 requests and you will receive an email like this

![Alarms notification](../../images/alarm-mail.png)

### Analyze the logs

Navigate to ```Logging -> Search```

You will see a failure message on mushop-orders-xxxx pod :

```Received payment response: PaymentResponse{authorised=false, message=Payment declined: amount exceeds 105.00}```

### Summary

We saw the payment failures on MuShop. The orders service within MuShop sends the custom business metrics out to Oracle Cloud Infrastructure (OCI) Monitoring which helped us view the metrics on a dashboard. We then set alarm for that metric to get alerts. Finally, analyzed the logs to find out what the issue was "Payment above 105 were getting declined".

Delivering the fix will not be covered, but it would simply involve raising the payment limits within the payment service which is responsible for payment processing. 