# Load / Integration Tests

These tests simulate actual end user usage of the application. They are used to
validate the overall functionality and can also be used to put simulated load on
the system. The tests are written using [locust.io](http://locust.io)

## Parameters

* `[host]` - The hostname (and port if applicable) where the application is exposed. (Required)
* `[number of clients]` - The nuber of concurrent end users to simulate. (Optional: Default is 2)
* `[total run time]` - The total time to run before terminating the tests. (Optional: Default is 10)

## Deploy to K8S

1. Start the locust pods

```text
kubectl apply -f load-dep.yaml
```

2. Watch pods/hpa

```text
kubectl get hpa --watch
```

3. Teardown

```text
kubectl delete -f load-dep.yaml
```

## Running locally

### Requirements

* locust `pip install locustio`

`./runLocust.sh -h [host] -c [number of clients] -r [total run time]`

## Running in Docker Container

* Build `docker build -t mushop/load .`
* Run `docker run mushop/load -h [host] -c [number of clients] -r [total run time]`
