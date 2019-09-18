![MuShop Logo](../../images/logo.png)

---

## Frequently asked questions

1. **I get an error stating** `shape VM.Standard.E2.1.Micro not found` **when I try to apply the terraform configuration.**

     Your Always Free tier eligible compute resources are in a different availability domain than the one selected when the stack (the `.zip` file) was imported. Currently, in regions with multiple availability domains, Always Free compute resources are limited to only one of the availability domains. To find where your Always Free compute resources are, navigate to `Home > Governance > Limits, Quotas and Usage`. Select Compute as the service and cycle through the availability domains in the scope drop-down. The service limit column shows the limits for each resource type. Always Free compute resources are VMs of shape `VM.Standard.E2.1.Micro`. Check for this shape, and you will see one AD where you were allocated capacity. Note that paid services are always available in all availability domains where applicable.

    [Learn more](https://docs.cloud.oracle.com/iaas/Content/FreeTier/resourceref.htm) about Oracle Cloud Infrastructure's Always Free resources.

2. **I get an error stating** `Permissions granted to the object storage service in this region are insufficient to execute this policy` **when I try to apply the terraform configuration.**

    This is an edge case we are addressing and in the meantime, simply retrying the `Terraform Actions > Apply` on the stack details page should resolve it.

3. How do I delete the sample application and free up my resources ?

   On Stack details page, click on `Terraform Actions > Destroy`. This will delete and free up all the resources that were created by the application.

If you see something issue that is not listed here or have a question for us, please [open an issue](https://github.com/oracle/oci-quickstart-cloudnative/issues/new) and we will get back to you.
