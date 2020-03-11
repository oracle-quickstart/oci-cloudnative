#!make

# Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0

THEME=themes/redwood

dev: theme up

build: theme hugo

theme:
	cd $(THEME) && npm install

hugo:
	@hugo -D

up:
	@hugo server -D --disableFastRender
