Contour := contour
Kapp := kapp
Kubectl := kubectl
Kustomize := kustomize

DESTDIR := out
OS := $(shell uname -s)

MKDIR_P := mkdir -p
RM_F := rm -rf

IPADDR.Darwin = $(shell networksetup -listallhardwareports | \
	awk '/Device/{print $$2}' | \
	xargs -n1 ipconfig getifaddr | \
	head -1)

IPADDR.Linux = $(shell ip --json addr show up primary scope global primary permanent | \
	jq -r '.[].addr_info | .[] | select(.local) | .local' | \
	head -1)

xDS_Address := $(IPADDR.$(OS))
xDS_Port := 8001

Targets := configs/envoy.json $(DESTDIR)/contour.yaml

yaml: $(Targets)

configs/envoy.json:
	@$(MKDIR_P) $$(dirname $@)
	@$(Contour) bootstrap \
		--xds-address=$(xDS_Address) \
		--xds-port=$(xDS_Port) \
		-- - | jq . > $@

$(DESTDIR)/contour.yaml:
	@$(MKDIR_P) $$(dirname $@)
	@$(Kustomize) build -o $@ .

.PHONY: apply.kapp
apply.kapp: $(Targets)
	@$(Kapp) deploy --yes --app contour --file $(DESTDIR)/contour.yaml

.PHONY: delete.kapp
delete.kapp: $(Targets)
	@$(Kapp) delete --yes --app contour

.PHONY: apply.kubectl
apply.kubectl: $(Targets)
	@$(Kubectl) apply --filename $(DESTDIR)/contour.yaml

.PHONY: delete.kubectl
delete.kubectl: $(Targets)
	@$(Kubectl) delete --filename $(DESTDIR)/contour.yaml

.PHONY: clean
clean:
	@$(RM_F) $(DESTDIR)
	@$(RM_F) configs/envoy.json

.PHONY: kind
kind: $(DESTDIR)/contour.yaml
	@echo 1/2 Creating Kind cluster ...
	@../../../hack/kind-make-cluster.sh
	@echo 2/2 Loading container images ...
	@for img in $$(awk '/image:/{print $$2}' $(DESTDIR)/*.yaml) ; do \
		docker pull $$img ; \
		kind load docker-image --name contour $$img ; \
	done
