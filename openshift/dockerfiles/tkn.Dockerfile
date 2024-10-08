ARG GO_BUILDER=brew.registry.redhat.io/rh-osbs/openshift-golang-builder:v1.22
ARG RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:c0e70387664f30cd9cf2795b547e4a9a51002c44a4a86aa9335ab030134bf392

FROM $GO_BUILDER AS builder

ARG REMOTE_SOURCE=/go/src/github.com/tektoncd/cli

ARG TKN_VERSION=0.38.1
ARG TKN_PAC_VERSION=0.28.0

WORKDIR $REMOTE_SOURCE
COPY upstream .
COPY patches patches/
RUN set -e; for f in patches/*.patch; do echo ${f}; [[ -f ${f} ]] || continue; git apply ${f}; done
COPY head-tkn HEAD_TKN
ENV GODEBUG="http2server=0"
RUN go build -ldflags="-X 'knative.dev/pkg/changeset.rev=$(cat HEAD_TKN)'" -mod=vendor -tags disable_gcp -v \
       -ldflags "-X github.com/tektoncd/cli/pkg/cmd/version.clientVersion=${TKN_VERSION}" \
       -o /tmp/tkn ./cli/cmd/tkn

COPY head-tkn-pac HEAD_TKN_PAC
RUN go build -ldflags="-X 'knative.dev/pkg/changeset.rev=$(cat HEAD_TKN_PAC)'" -mod=vendor -tags disable_gcp -v \
       -ldflags "-X github.com/openshift-pipelines/pipelines-as-code/pkg/params/version.Version=${TKN_PAC_VERSION}" \
       -o /tmp/tkn-pac ./tkn-pac/cmd/tkn-pac

FROM $RUNTIME
ARG VERSION=tkn-main

COPY --from=builder /tmp/tkn /usr/bin
COPY --from=builder /tmp/tkn-pac /usr/bin

LABEL \
      com.redhat.component="openshift-pipelines-cli-tkn-container" \
      name="openshift-pipelines/pipelines-cli-tkn-rhel8" \
      version=$VERSION \
      summary="Red Hat OpenShift pipelines tkn CLI" \
      description="CLI client 'tkn' for managing openshift pipelines" \
      io.k8s.display-name="Red Hat OpenShift Pipelines tkn CLI" \
      maintainer="pipelines-extcomm@redhat.com"
      io.k8s.description="Red Hat OpenShift Pipelines tkn CLI" \
      io.openshift.tags="pipelines,tekton,openshift"

RUN microdnf install -y shadow-utils
RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -r -u 65532 -g nonroot nonroot
USER 65532
