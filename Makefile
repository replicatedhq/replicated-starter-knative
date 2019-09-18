SHELL := /bin/bash -o pipefail

lint_reporter := console

CHANNEL := Unstable

VERSION_TAG := "0.1.0-dev-${USER}"
RELEASE_NOTES := "Automated release by ${USER} on $(shell date)"

.PHONY: deps-lint
deps-lint:
	@[ -x `npm bin`/replicated-lint ] || npm install --no-save replicated-lint

.PHONY: deps-vendor-cli
deps-vendor-cli:
	@if [[ -x deps/replicated ]]; then exit 0; else \
	echo '-> Downloading Replicated CLI... '; \
	mkdir -p deps/; \
	if [[ "`uname`" == "Linux" ]]; then curl -fsSL https://github.com/replicatedhq/replicated/releases/download/v0.13.0/replicated_0.13.0_linux_amd64.tar.gz | tar xvz -C deps; exit 0; fi; \
	if [[ "`uname`" == "Darwin" ]]; then curl -fsSL https://github.com/replicatedhq/replicated/releases/download/v0.13.0/replicated_0.13.0_darwin_amd64.tar.gz | tar xvz -C deps; exit 0; fi; fi;


.PHONY: lint
lint: deps-lint
	`npm bin`/replicated-lint validate -f replicated.yaml --reporter $(lint_reporter)


.PHONY: kustomize
kustomize: deps-vendor-cli
	mkdir -p tmp
	kustomize build base | awk '/^---/{print;print "# kind: scheduler-kubernetes";next}1' > tmp/k8s.yaml
	cat replicated.yaml tmp/k8s.yaml > tmp/final.yaml


.PHONY: release
release: deps-vendor-cli
	mkdir -p tmp
	kustomize build base | awk '/^---/{print;print "# kind: scheduler-kubernetes";next}1' > tmp/k8s.yaml
	cat replicated.yaml tmp/k8s.yaml | deps/replicated release create \
		--yaml - \
		--promote $(CHANNEL) \
	        --version $(VERSION_TAG) \
	        --release-notes $(RELEASE_NOTES)
