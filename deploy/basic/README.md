# Build

- Clone https://github.com/oracle/oci-quickstart-cloudnative
- From the root of the repo exeucte the command:
 `docker build -t mushop-lite-mono -f deploy/monolith-lite/Dockerfile .`

# [Docker] Run

- `docker run --rm -it -p 80:80 -p 3000:3000 -p 3005:3005 mushop-lite-mono:latest`

# [Docker] Run with the wallet extracted locally

- `docker run --rm -it -v $PWD/Wallet_Creds:/usr/lib/oracle/19.3/client64/lib/network/admin/ -e "OADB_USER=catalogue_user" -e "OADB_PW=default_Password1" -e "OADB_SERVICE=mcatalogue_tp" -p 80:80 -p 3000:3000 -p 3005:3005 mushop-lite-mono:latest`

# [Monolith] Copy generated App Zip Package for VM

- `docker run -v $PWD:/transfer --rm --entrypoint cp mushop-lite-mono:latest /package/mushop-lite-mono.tar.gz /transfer/mushop-lite-mono.tar.gz`

# [Monolith] Copy generated Generate Stack Zip Package for the ORM

- `docker run -v $PWD:/transfer --rm --entrypoint cp mushop-lite-mono:latest /package/mushop-lite-mono-stack.zip /transfer/mushop-lite-mono-stack.zip`


## Monolith VM requirements:

- Base EL7
- oracle-instantclient19.3-basiclite
- node 10.x
- httpd
- extract mushop-lite-mono.tar.gz (/app)
- OADB Wallet to /usr/lib/oracle/19.3/client64/lib/network/admin/
- set to run entrypoint.sh on the VM start
- variables: OADB_USER, OADB_PW and OADB_SERVICE

# Deploy MuShop Lite Monolith to OCI Free Tier Compute Shape using the cli

`oci compute instance launch --availability-domain mmXc:PHX-AD-1 --compartment-id ocid1.compartment.oc1..aaa... --shape VM.Standard.E2.1.Micro --image-id ocid1.image.oc1.phx.aaaaaaaadtmpmfm77czi5ghi5zh7uvkguu6dsecsg7kuo3eigc5663und4za --subnet-id ocid1.subnet.oc1.phx.aaa... --user-data-file micro-mushop-mono.cloud-config --display-name mushop-lite-mono-0`