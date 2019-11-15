kubectl create secret generic streams-secret \
--from-literal=compartment_id="<your compartment_id>" \
--from-literal=tenant_id="<your tenancy_id>" \
--from-literal=user_id="<your user_id>" \
--from-literal=fingerprint="<your fingerprint>" \
--from-literal=region="<your region>" \
--from-file=oci_api_key=<your oci_api_key.pem>
