#!/bin/bash
sleep 10
RESPONSECODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8084/customers)
if [ $RESPONSECODE != 200 ]
	then
		echo Error: bad response code from user service $RESPONSECODE
		exit 1
fi
echo Successful response from container $RESPONSECODE
