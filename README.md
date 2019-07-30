Replicated Starter Knative
==================

Example project showcasing how power users can combine several Replicated tools in order to manage
Replicated YAML using a git repository.

[Kubernetes](https://kubernetes.io)
| [Knative](https://knative.dev/)
| [Istio](https://istio.io/)

### Prequisites

- [node](https://nodejs.org/en/download/)
- `make`
- A git repository created to manage your Replicated YAML. We'll use github in this example.

### Get started

This repo is a [GitHub Template Repository](https://help.github.com/en/articles/creating-a-repository-from-a-template). You can create a private copy by using the "Use this Template" link in the repo:

![Template Repo](https://help.github.com/assets/images/help/repository/use-this-template-button.png)

You should use the template to create a new **private** repo in your org, for example `mycompany/replicated` or `mycompany/replicated-starter-knative`.

Once you've created a repository from the template, you'll want to `git clone` your new repo and `cd` into it locally.

#### Configure environment

You'll need to set up two environment variables to interact with vendor.replicated.com:

```
export REPLICATED_APP=...
export REPLICATED_API_TOKEN=...
```

`REPLICATED_APP` should be set to the app slug from the Settings page:

<p align="center"><img src="./doc/REPLICATED_APP.png" width=600></img></p>

Next, create an API token from the [Teams and Tokens](https://vendor.replicated.com/team/tokens) page:

<p align="center"><img src="./doc/REPLICATED_API_TOKEN.png" width=600></img></p>

Ensure the token has "Write" access or you'll be unable create new releases. Once you have the values,
set them in your environment.

```
export REPLICATED_APP=...
export REPLICATED_API_TOKEN=...
```

#### Iterating on your release

You can ensure this is working with the following. The generated file is located at `tmp/final.yaml`

```
make kustomize
```

then you can push a new release to a channel with

```
make release
```

By default the `Unstable` channel will be used. You can override this with `channel`:

```
make release channel=Beta
```

If you have nodejs installated, you can lint your YAML before releasing with

```
make lint
```

### Knative Example

In this example we will only be deploying Knative's Serving component but other components such as Build, Monitoring and Eventing can be added.

A simple Go Function is shown in `base/knative_serve.yaml` that will deploy a simple Knative 'hello world' function. If you add more Knative services or components put them in separate files and list them under `resources` in `base/kustomization.yaml`

```
---
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-samples/helloworld-go # The URL to the image of the app
            env:
              - name: TARGET # The environment variable printed out by the sample app
                value: "Go Sample v1"

``` 
Sample: https://knative.dev/docs/serving/samples/hello-world/helloworld-go/

### Knative Caveats

* Namespaces are not created automatically, use the following yaml file and `kubectl apply -f <file_name>` manually.

Note: when you add other components such as Build, Monitoring and Eventing add the appropriate namespaces.

```
---
# kind: scheduler-kubernetes
apiVersion: v1
kind: Namespace
metadata:
  labels:
    istio-injection: disabled
  name: istio-system
---
# kind: scheduler-kubernetes
apiVersion: v1
kind: Namespace
metadata:
  labels:
    istio-injection: enabled
  name: knative-serving
---
# kind: scheduler-kubernetes
apiVersion: v1
kind: Namespace
metadata:
  labels:
    istio-injection: enabled
  name: replicated-xxxxxxxxxxxxxxxxxxxx
```

* By default only a single Master K8s cluster is launched, hence the `istio-ingressgateway` service type is set to `NodePort`. If you would like to connect multiple nodes with a load balancer please change it to `LoadBalancer`.

### Integrating with CI

Often teams will use one channel per developer, and then keep the `master` branch of this repo in sync with their `Unstable` branch.

The project includes CI configs for [Travis CI](https://travis-ci.org), [CircleCI](https://circleci.com), [Jenkins CI](https://jenkins.io),  and [GitLab CI](https://gitlab.com).

Both configs will:

**On pull requests**:

- Install dependencies
- Lint yaml for syntax and logic errors

**On merges to the github `master` branch**:

- Install dependencies
- Lint yaml for syntax and logic errors
- Create a new release on the `Unstable` channel in Replicated

These behaviors are documented and demonstrated in the [replicated-ci-demo](https://github.com/replicatedhq/replicated-ci-demo) project.

### Tools reference

- [replicated-lint](https://github.com/replicatedhq/replicated-lint)
- [replicated vendor cli](https://github.com/replicatedhq/replicated)

### License

MIT
