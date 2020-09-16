#!/bin/bash -x
# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#
# Description: Sets up Mushop Basic a.k.a. "Monolite".
# Return codes: 0 =
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

bash -x /root/setup.sh 2>&1 | tee -a /root/setup.log
bash -x /root/deploy.sh 2>&1 | tee -a /root/deploy.log
echo "Finished preflight"