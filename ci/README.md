# MuShop CI

## Wercker Setup

When setting up a new Wercker workflow, keep in mind the following environment variables and pipelines that need to be configured beforehand.

The following global variables need to be set on the Wercker application (the Environment tab):

| Environment variable name | Description | Example |
| --- | --- | --- |
| DOCKER_REPOSITORY | Docker repository name | `phx.ocir.io/{tenancyName}/mushop` |

### Build (`build`)

Build pipeline uses the `internal/docker-build` step to build Docker images for all services.

### Push to Registry (`push-to-registry`)

This pipeline pushes the build Docker images to the registry. The following environment variables need to be set on the pipeline.

| Environment variable name | Description | Example |
| --- | --- | --- |
| DOCKER_USERNAME | Docker registry username | `{tenancyName}/{myUserName}` |
| DOCKER_PASSWORD | Docker registry password | `{myUserPassword}` |

### Testing

Because we have services in multiple languages, we had to separate the pipelines per-language (each pipeline uses a language specific box (e.g. `node`, `golang`)). Another reason we had to do this is because Wercker isn't really set up for a multi-repo - it would work better if we had a separate repo for each component.

We have the following pipelines to run tests - these could be run in parallel after build pipeline completes.

- `test-node-services` - runs unit tests for all NodeJS services
- `test-go-services` - runs unit tests for all Go services
- `test-java-services` - runs unit tests for all Java services

The test pipelines don't require any additional environment variables.

### Deployments

There are two deployment (upgrade) pipelines defined in Wercker

- Test Deployment (`upgrade-test-deployment`)
- Production Deployment (`upgrade-production-deployment`)

Both deployment pipelines are equivalent, the difference is in the environment variables that are set on the pipelines. The variables define which cluster is used for deployment as well as the Helm release name.

| Environment variable name | Description | Example |
| --- | --- | --- |
| HELM_RELEASE_NAME | Helm release name to be upgraded | `mymushop` |
| HELM_TIMEOUT | Helm timeout value | `600` |
| KUBERNETES_SERVER | URL of the Kubernetes server | `https://mykubernetescluster.com:6443` |
| KUBERNETES_TOKEN | User token for the Kubernetes cluster (from `.kube/config`) | `eyJoZWFkZXIiOnsiQXV0a...` |
