kubectl create secret generic streams-secret \
--from-literal=compartment_id="ocid1.compartment.oc1..aaaaaaaa4vxl6yyvfcumwutejntiu3tzcwacbpgdqndh3kct5i65ahvz7oma" \
--from-literal=tenant_id="ocid1.tenancy.oc1..aaaaaaaawpqblfemtluwxipipubxhioptheej2r32gvf7em7iftkr3vd2r3a" \
--from-literal=user_id="ocid1.user.oc1..aaaaaaaapzqkxjlgfc5ucp3cjtwxtj2lul4uqwpkg2zfj4d2i6cc3dtr3mwq" \
--from-literal=fingerprint="4e:6d:68:30:a9:60:73:88:d6:7c:52:27:1c:e2:40:cf" \
--from-literal=region="us-phoenix-1" \
--from-file=oci_api_key=oci_api_key.pem
