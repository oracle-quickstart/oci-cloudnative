# newsletter-subscription function

The purpose of the `newsletter-subscription` function is simple: it takes an email address as an input and sends an email to the receipent, informing them that they are subscribed to a newsletter. Note that the subscription is not tracked nor stored anywhere, the idea is just to showcase how to invoke a function through an API gateway and how to send emails using Oracle Email Delivery feature.


## Prerequisites

The first step you need to do is to ensure your tenancy is configured for function development. You can follow the [Configuring Your Tenancy for Function Development](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionsconfiguringtenancies.htm) documentation.

As a next step you will need to install the [Fn CLI](https://github.com/fnproject/cli). If on a Mac and you're using [Brew](https://brew.sh), you can run:

```
brew install fn
```

Finally, you will need configure the Fn CLI - you can follow [these instructions](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionscreatefncontext.htm) that will guide you through creating a context file and configuring it with an image registry.

## Set up email delivery (SMTP credentails) and the approved sender

The function will need to send an email messaged to the provided address. In order to send the email using OCI Email Delivery you need to configure an approved sender first.

1. From the OCI console, click **Email Delivery** -> **Email Approved Sender**
1. Click the **Create Approved Sender**
1. Enter the email address, for example: `mushop@example.com`
1. Click **Create Approved Sender**

>Note: if you have your own domain, you can enter a different address (e.g.`mushop@[yourdomain.com]`) and also configure SPF record for the sender. This involves adding a DNS record to your domain. You can follow [these](https://docs.cloud.oracle.com/iaas/Content/Email/Tasks/configurespf.htm) instructions to set up SPF.

Next, you need to generate the SMTP credentials that will allow you to log in to the SMTP server and send the email. Follow the [Generate SMTP Credentails for a User](https://docs.cloud.oracle.com/iaas/Content/Email/Tasks/generatesmtpcredentials.htm) to get the SMTP host, port, username and password.

The SMTP credentails (host, port, username and password) and the approved sender email address (e.g. `mushop@example.com`) will be provided to the function as configuration values later, so make sure you save these values somewhere.

## Create the application

Each function needs to live inside of an application. You can create a new application either through the console, API or the Fn CLI. An application has a name (e.g. `mushop-app`) and the VCN and a subnet in which to run the functions. The one guideline here is to pick the subnets that are in the same region as the Docker registry you specified in your context YAML earlier - check these [docs](https://docs.cloud.oracle.com/iaas/Content/Functions/Tasks/functionscreatingapps.htm) for more information.

To create an application using Fn CLI, run:

```
 fn create app [APP_NAME] --annotation oracle.com/oci/subnetIds='["ocid1.subnet.oc1.iad...."]'
```

>Note: make sure you replace `APP_NAME` and the `ocid1.subnet` with actual values

## Deploy the function

To deploy a function to an app, you can run the following command within the function folder (`newsletter-subscription`):

```
fn deploy --app [APP_NAME]
```
>Note: use `fn -v deploy --app [APP_NAME]` to get verbose output in case you're running into issues.

In the remainder of the document, we will use `mushop-app` for the application name.

## Configure the function

You need to provide additional configuration (SMTP credentails) for the function to work properly and be able to send emails.

Once you've successfully deployed the function, you can use the Fn CLI to add configuration values (note that you can also do the same through the Console UI).

Run the following commands to configure SMTP settings and the approved sender (replace the values):

```
fn config function mushop-app newsletter-subscription SMTP_USER <smtp_username>
fn config function mushop-app newsletter-subscription SMTP_PASSWORD <smtp_password>
fn config function mushop-app newsletter-subscription SMTP_HOST <smtp_host>
fn config function mushop-app newsletter-subscription SMTP_PORT <smtp_port>
fn config function mushop-app newsletter-subscription APPROVED_SENDER_EMAIL <approved_sender_email>
```

## Create the API gateway

You will be using an [API Gateway](https://docs.cloud.oracle.com/iaas/Content/APIGateway/Concepts/apigatewayoverview.htm) to access the functions. To prepare your tenancy for using the gateway, check the [Preparing for API Gateway](https://docs.cloud.oracle.com/iaas/Content/APIGateway/Concepts/apigatewayprerequisites.htm) documentation.

The quickest way to create a gateway is through the OCI console:

1. Click **Developer Services** -> **API Gateway** from the sidebar on the left
1. Click the **Create Gateway** button
1. Enter the following values (you can use a different name if you'd like):
    - Name: **mushop-gateway**
    - Type: **Public**
    - Virtual Cloud Network: *Pick one from the dropdown*
    - Subnet: *Pick the subnet from the dropdown*
1. Click **Create**
1. When gateway is created, click the **Deployments** link from the sidebar on the left
1. Under the **Deployments**, click the **Create Deployment** button
1. Make sure **From Scratch** option is selected at the top and enter the following values (you can leave the other values as they are - i.e. no need to enable CORS, Authentication or Rate Limiting):
    - Name: **newsletter-subscription**
    - Path prefix: **/newsletter**
    - Compartment: <Pick your compartment>
    - Execution log: **Enabled**
    - Log level: **Error**
1. Click **Next** to define the route
1. Enter the following values for **Route 1**:
    - Path: **/subscribe**
    - Methods: **POST**
    - Type: **Oracle Functions**
    - Application: **mushop-app** (or other, if you used a different name)
    - Function name: **newsletter-subscription**
1. Click the **Show Route Logging Policies** link and enable **Execution Log**
1. Click **Next** and review the deployment
1. Click **Create** to create the gateway deployment

When deployment completes, navigate to it to get the URL for the gateway. Click the **Show** link next to the **Endpoint** label to reveal the full URL for the deployment. It should look like this:

```
https://aaaaaaaaa.apigateway.us-ashburn-1.oci.customer-oci.com/newsletter
```

To test the function through the gateway, use the command below. Make sure to replace the email with your own email (i.e. where you want the message to be sent to) and replace the correct API gateway URL:

```
curl -X POST -d '{"email": "youremail@example.com"}'  https://aaaaaaaaa.apigateway.us-ashburn-1.oci.customer-oci.com/newsletter/subscribe
```

If everything worked fine, the function will respond with a message similar to this one: 

```
{"messageId":"<0cc76573-2b9b-5a22-6032-8b7e7fec8378@example.com>"}
```