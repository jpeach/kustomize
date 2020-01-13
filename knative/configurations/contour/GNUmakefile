RM := rm -rf
MKDIR_P := mkdir -p

Kustomize := kustomize
Kapp := kapp
Kubectl := kubectl

Targets := \
	knative.yaml \
	contour-internal.yaml \
	contour-external.yaml

YamlTargets := $(patsubst %,out/%,$(Targets))

.PHONY: yaml
yaml: $(YamlTargets)

.PHONY: image
image:
	docker build --tag docker.io/jpeach/net-contour:3 .

out/contour-internal.yaml:
	@$(MKDIR_P) $$(dirname $@)
	$(Kustomize) build -o $@ contour-internal

out/contour-external.yaml:
	@$(MKDIR_P) $$(dirname $@)
	$(Kustomize) build -o $@ contour-external

out/knative.yaml:
	@$(MKDIR_P) $$(dirname $@)
	$(Kustomize) build -o $@ .

# Deploy the YAML with kapp <https://get-kapp.io>. The knative
# deployment works with kapp 0.17, but can fail with some older
# versions (e.g. 1.14).
#
# Note that kapp will puke some ownership errors because we push
# the Contour twice.
.PHONY: deploy.kapp
deploy.kapp: $(YamlTargets)
	@for y in $^ ; do $(Kapp) deploy --dangerous-ignore-failing-api-services --yes --app $$(basename $$y .yaml) --file $$y ; done

.PHONY: delete.kapp
delete.kapp: $(YamlTargets)
	@for y in $^ ; do $(Kapp) delete --yes --app $$(basename $$y .yaml) ; done

.PHONY: deploy.kubectl
deploy.kubectl: $(YamlTargets)
	@for y in $^ ; do $(Kubectl) apply --filename $$y ; done

.PHONY: delete.kubectl
delete.kubectl: $(YamlTargets)
	@for y in $^ ; do $(Kubectl) delete --filename $$y ; done

clean:
	$(RM) out
