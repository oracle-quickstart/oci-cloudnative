/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
package events

import (
	"os"

	"github.com/oracle/oci-go-sdk/common"
	"github.com/oracle/oci-go-sdk/streaming"
)

// EnvironmentConfigurationProvider uses environment variables to get OCI config
func EnvironmentConfigurationProvider() (common.ConfigurationProvider, error) {
	pass := os.Getenv("PASSPHRASE")
	provider := common.NewRawConfigurationProvider(
		os.Getenv("TENANCY"),
		os.Getenv("USER_ID"),
		os.Getenv("REGION"),
		os.Getenv("FINGERPRINT"),
		os.Getenv("PRIVATE_KEY"),
		&pass,
	)
	_, err := common.IsConfigurationProviderValid(provider)

	return provider, err
}

// GetStreamClient returns a streaming client with the given configuration provider
func GetStreamClient(provider common.ConfigurationProvider) (streaming.StreamClient, error) {
	var endpoint string
	endpoint = os.Getenv("MESSAGES_ENDPOINT")
	if endpoint == "" {
		region, _ := provider.Region()
		endpoint = "https://streaming." + region + ".oci.oraclecloud.com"
	}
	return streaming.NewStreamClientWithConfigurationProvider(provider, endpoint)
}

// GetStreamID returns the events streamId
func GetStreamID() (streamId string) {
	return os.Getenv("STREAM_ID")
}
