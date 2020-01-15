RM := rm -rf
MKDIR_P := mkdir -p

# BUILDDIR: Override to change the YAML output directory. This is
# useful if tou make a change and want to diff it to a previous
# version.
BUILDDIR := out

Kustomize := kustomize
Kapp := kapp
Kubectl := kubectl

Targets := \
	knative-contour.yaml \
	contour-internal.yaml \
	contour-external.yaml

YamlTargets := $(patsubst %,$(BUILDDIR)/%,$(Targets))

.PHONY: yaml
yaml: $(YamlTargets)

.PHONY: image
image:
	docker build --tag docker.io/jpeach/net-contour:3 .

$(BUILDDIR)/contour-internal.yaml:
	@$(MKDIR_P) $$(dirname $@)
	$(Kustomize) build -o $@ contour-internal

$(BUILDDIR)/contour-external.yaml:
	@$(MKDIR_P) $$(dirname $@)
	$(Kustomize) build -o $@ contour-external

$(BUILDDIR)/knative-contour.yaml:
	@$(MKDIR_P) $$(dirname $@)
	$(Kustomize) build -o $@ .

# Deploy the YAML with kapp <https://get-kapp.io>. The knative
# deployment works with kapp 0.17, but can fail with some older
# versions (e.g. 1.14).
#
# Note that kapp will puke some ownership errors because we push
# the Contour twice.
.PHONY: apply.kapp
apply.kapp: $(YamlTargets)
	@for y in $^ ; do $(Kapp) deploy --dangerous-ignore-failing-api-services --yes --app $$(basename $$y .yaml) --file $$y ; done

.PHONY: delete.kapp
delete.kapp: $(YamlTargets)
	@for y in $^ ; do $(Kapp) delete --yes --app $$(basename $$y .yaml) ; done

.PHONY: apply.kubectl
apply.kubectl: $(YamlTargets)
	@for y in $^ ; do $(Kubectl) apply --filename $$y ; done

.PHONY: delete.kubectl
delete.kubectl: $(YamlTargets)
	@for y in $^ ; do $(Kubectl) delete --filename $$y ; done

clean:
	$(RM) $(BUILDDIR)
