# Build

- Clone MuShop
- From the root of the repo exeucte the command:
 `docker build -t micro-mushop -f deploy/micro/Dockerfile .`

# [Docker] Run

- `docker run --rm -it -p 80:80 -p 3000:3000 -p 3005:3005 micro-mushop:latest`

# [Docker] Run with the wallet extracted locally

- `docker run --rm -it -v $PWD/Wallet_Creds:/usr/lib/oracle/19.3/client64/lib/network/admin/ -e "OADB_USER=catalogue_user" -e "OADB_PW=default_Password1" -e "OADB_SERVICE=mcatalogue_tp" -p 80:80 -p 3000:3000 -p 3005:3005 micro-mushop:latest`

# [Monolith] Generate App Zip Package for VM

- `docker run -v $PWD:/transfer --rm --entrypoint cp micro-mushop:latest /app/microMuShop.zip /transfer/microMuShop.zip`

## Monolith VM requirements:

- Base EL7
- oracle-instantclient19.3-basiclite
- node 10.x
- httpd
- extract microMuShop.zip (/app)
- OADB Wallet to /usr/lib/oracle/19.3/client64/lib/network/admin/
- set to run entrypoint.sh on the VM start
- variables: OADB_USER, OADB_PW and OADB_SERVICE

