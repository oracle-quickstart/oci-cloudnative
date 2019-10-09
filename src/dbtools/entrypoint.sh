#!/bin/bash
#
# Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 
echo Executing SQL...
echo Service: $OADB_SERVICE
echo Schema User: $OADB_USER
sqlplus ADMIN/\"$( echo "$OADB_ADMIN_PW" | jq -r 'keys[0] as $k | "\(.[$k])"' )\"@$OADB_SERVICE @service.sql $OADB_USER $OADB_PW