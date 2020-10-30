/**
 * Copyright (c) 2016, 2020, Oracle and/or its affiliates.  All rights reserved.
 * This software is dual-licensed to you under the Universal Permissive License (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose either license.
 */
package  mushop.orders.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;


import com.oracle.bmc.Region;
import com.oracle.bmc.auth.AuthenticationDetailsProvider;
import com.oracle.bmc.auth.SimpleAuthenticationDetailsProvider;
import com.oracle.bmc.auth.StringPrivateKeySupplier;

import com.oracle.bmc.ConfigFileReader;
import com.oracle.bmc.ConfigFileReader.ConfigFile;
import com.oracle.bmc.auth.ConfigFileAuthenticationDetailsProvider;
import com.oracle.bmc.monitoring.MonitoringClient;
import com.oracle.bmc.monitoring.model.Datapoint;
import com.oracle.bmc.monitoring.model.MetricDataDetails;
import com.oracle.bmc.monitoring.model.PostMetricDataDetails;
import com.oracle.bmc.monitoring.requests.PostMetricDataRequest;
import com.oracle.bmc.monitoring.responses.PostMetricDataResponse;

import java.io.IOException;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class MonitoringConfiguration {

    @Autowired
    private Environment env;
    
    private MonitoringClient monitoringClient = null;
    private String compartmentId = null;
    private String namespace = null;
    private String region = null;

    public MonitoringClient getMonitoringClient() {
	return monitoringClient;
    }

    public String getRegion() {
	return region;
    }

    public String getNamespace() {
	return namespace;
    }

    public String getCompartmentId() {
	return compartmentId;
    }
    
    public MonitoringClient initConnection() throws Exception {

        final String tenantId = env.getProperty("OCI_TENANT_ID");
        final String userId = env.getProperty("OCI_USER_ID");
        final String fingerprint = env.getProperty("OCI_FINGERPRINT");
        final String privateKey = env.getProperty("OCI_API_KEY");
        final String passPhrase = env.getProperty("OCI_PASSPHRASE");
        final String monitoringEndPoint = env.getProperty("OCI_MONITORING_ENDPOINT");
        compartmentId = env.getProperty("OCI_COMPARTMENT_ID");
        namespace = "mushopnamespace";
        region = env.getProperty("OCI_REGION");
    
        System.out.println("Started Initializing the Monitoring Service...\nDetails below \n");
        System.out.printf("%s,%s,%s,%s,%s,%s",tenantId,userId,fingerprint,privateKey,monitoringEndPoint,compartmentId);
        
        if (tenantId == null || userId == null || fingerprint == null || privateKey == null){
                System.out.printf("Cannot send metrics to OCI Monitoring, Ensure you have set the required ENV variables tenantId, userId etc ..");
                return null;
        }

        AuthenticationDetailsProvider provider = null;
                
        if (privateKey.contains("Proc-Type: 4,ENCRYPTED")) {
                provider = SimpleAuthenticationDetailsProvider.builder()
                .tenantId(tenantId)
                .userId(userId)
                .fingerprint(fingerprint)
                .privateKeySupplier(new StringPrivateKeySupplier(privateKey))
                .region(Region.fromRegionId(region))
                .passPhrase(passPhrase)
                .build();
        } else {
                provider = SimpleAuthenticationDetailsProvider.builder()
                .tenantId(tenantId)
                .userId(userId)
                .fingerprint(fingerprint)
                .privateKeySupplier(new StringPrivateKeySupplier(privateKey))
                .region(Region.fromRegionId(region))
                .build();
        }
                
        monitoringClient = new MonitoringClient(provider);

        if (monitoringEndPoint != null){
                monitoringClient.setEndpoint(monitoringEndPoint);
        } else {
                monitoringClient.setEndpoint("https://telemetry-ingestion.us-phoenix-1.oraclecloud.com");
        }
        return monitoringClient;
    }

    public static void post(
            MonitoringClient monitoringClient,
            String compartment,
            String namespace,
            String metricName,
            String region) {
        final PostMetricDataRequest request =
                PostMetricDataRequest.builder()
                        .postMetricDataDetails(
                                PostMetricDataDetails.builder()
                                        .metricData(
                                                Arrays.asList(
                                                        MetricDataDetails.builder()
                                                                .compartmentId(compartment)
                                                                .namespace(namespace)
                                                                .name(metricName)
                                                                .datapoints(
                                                                        Arrays.asList(
                                                                                Datapoint.builder()
                                                                                        .timestamp(
                                                                                                new Date())
                                                                                        .count(1)
                                                                                        .value(
                                                                                                406.0)
                                                                                        .build()))
                                                                .dimensions(
                                                                        makeMap(
                                                                                "region",
                                                                                    region,
                                                                                "pod-name",
                                                                                  "mushop-orders"))
                                                                .build()))
                                        .build())
                        .build();

        System.out.printf("Request constructed:\n%s\n\n", request.getPostMetricDataDetails());

        System.out.println("Posting the request to OCI Monitoring...");
        final PostMetricDataResponse response = monitoringClient.postMetricData(request);

        System.out.printf(
                "\n\nReceived response [opc-request-id: %s]\n", response.getOpcRequestId());
        System.out.printf("%s\n\n", response.getPostMetricDataResponseDetails());
    }
    
    private static Map<String, String> makeMap(String... data) {
        Map<String, String> map = new HashMap<>();
        for (int i = 0; i < data.length; i += 2) {
            map.put(data[i], data[i + 1]);
        }
        return map;
    }
}