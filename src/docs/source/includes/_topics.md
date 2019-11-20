## Cloud Native

The MuShop application highlights many topics related to [Cloud Native](https://www.oracle.com/cloud/cloud-native/) application
development with Oracle Cloud Infrastructure.

| Cloud Service | Description |
|--|--|
| [Container Engine for Kubernetes](https://www.oracle.com/cloud/compute/container-engine-kubernetes.html) | Enterprise-grade Kubernetes on Oracle Cloud |
| [Container Registry](https://www.oracle.com/cloud/compute/container-registry.html) | Highly available service to distribute container images |
| [Resource Manager](https://www.oracle.com/cloud/systems-management/resource-manager/) | Infrastructure as code with Terraform |
| [Streaming](https://www.oracle.com/big-data/streaming/) | Large scale data collection and processing |
| [Monitoring](https://www.oracle.com/cloud/systems-management/monitoring/) | Integrated metrics from all resources and services |
| [Kubernetes Service Broker](https://github.com/oracle/oci-service-broker) | Provisioning cloud resources within Kubernetes |
| _Others coming soon_ | - |
| [Events](https://www.oracle.com/cloud-native/events-service/) | Trigger actions in response to infrastructure changes |
| [Functions](https://www.oracle.com/cloud-native/functions/) | Scalable, multitenant serverless functions |
| [Notifications](https://www.oracle.com/cloud/systems-management/notifications/) | Broadcast messages to distributed systems |
| [API Gateway](https://www.oracle.com/cloud/integration/api-platform-cloud/) | Fully managed gateway for governed HTTP/S interfaces |
| [Logging](https://go.oracle.com/LP=78019?elqCampaignId=179851) | Single pane of glass for resources and applications |

In addition to these Cloud Native topics, MuShop demonstrates the use of several
**_backing services_**  available on Oracle Cloud Infrastructure.

- [Autonomous Transaction Processing Database](https://www.oracle.com/database/autonomous-transaction-processing.html)
- [Object Storage](https://www.oracle.com/cloud/storage/object-storage.html)
- [Web Application Firewall](https://www.oracle.com/cloud/security/cloud-services/web-application-firewall.html)

<!-- - [Health Checks](https://www.oracle.com/cloud/networking/health-checks.html) -->
<!-- - [Email Delivery](https://www.oracle.com/cloud/networking/email-delivery.html) -->

### MuShop Services

| Service | Technology  | Cloud Services | Description |
| --- | --- | --- | --- |
| `src/api` | Node.js   | | Storefront API |
| `src/carts` | Java | Autonomous DB (ATP) | Shopping cart |
| `src/catalogue` | Go | Autonomous DB (ATP) | Product catalogue |
| `src/orders` | Java | Autonomous DB (ATP)   | Customer orders |
| `src/payments` | Go | | Payment processing |
| `src/router` | traefik  |  | Request routing |
| `src/shipping` | Java | Streaming | Shipping producer |
| `src/stream` | Java | Streaming | Shipping fulfillment |
| `src/storefront` | JavaScript  |  | Store UI |
| `src/user` | TypeScript | Autonomous DB (ATP)  | Customer accounts, AuthN |
