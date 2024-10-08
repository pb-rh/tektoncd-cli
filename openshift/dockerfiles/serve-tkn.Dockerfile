ARG BUILDER=registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:c0e70387664f30cd9cf2795b547e4a9a51002c44a4a86aa9335ab030134bf392
ARG RUNTIME=registry.redhat.io/rhel8/httpd-24:latest

FROM $BUILDER AS builder

WORKDIR /tmp/tkn
ARG TKN_ARTIFACTS_URL="https://download.eng.bos.redhat.com/etera/openshift-pipelines-client/1/1.16/1.16.0-11647/signed/"
RUN microdnf install -y wget shadow-utils

RUN wget -P /tmp/tkn ${TKN_ARTIFACTS_URL}/x86_64/linux/tkn-linux-amd64.tar.gz --no-check-certificate

RUN wget -P /tmp/tkn ${TKN_ARTIFACTS_URL}/arm64/linux/tkn-linux-arm64.tar.gz --no-check-certificate

RUN wget -P /tmp/tkn ${TKN_ARTIFACTS_URL}/ppc64le/linux/tkn-linux-ppc64le.tar.gz --no-check-certificate

RUN wget -P /tmp/tkn ${TKN_ARTIFACTS_URL}/s390x/linux/tkn-linux-s390x.tar.gz --no-check-certificate

RUN wget -P /tmp/tkn ${TKN_ARTIFACTS_URL}/x86_64/windows/tkn-windows-amd64.zip --no-check-certificate

RUN wget -P /tmp/tkn ${TKN_ARTIFACTS_URL}/arm64/windows/tkn-windows-arm64.zip --no-check-certificate

RUN wget -P /tmp/tkn ${TKN_ARTIFACTS_URL}/x86_64/macos/tkn-macos-amd64.tar.gz --no-check-certificate

RUN wget -P /tmp/tkn ${TKN_ARTIFACTS_URL}/arm64/macos/tkn-macos-arm64.tar.gz --no-check-certificate

FROM $RUNTIME

RUN mkdir -p /var/www/html/tkn
COPY --from=builder /tmp/tkn/tkn-linux-amd64.tar.gz \
      /tmp/tkn/tkn-linux-arm64.tar.gz \
      /tmp/tkn/tkn-linux-ppc64le.tar.gz \
      /tmp/tkn/tkn-linux-s390x.tar.gz \
      /tmp/tkn/tkn-windows-amd64.zip \
      /tmp/tkn/tkn-windows-arm64.zip \
      /tmp/tkn/tkn-macos-amd64.tar.gz \
      /tmp/tkn/tkn-macos-arm64.tar.gz \
      /var/www/html/tkn/

CMD run-httpd

LABEL \
      com.redhat.component="openshift-pipelines-serve-tkn-cli-container" \
      name="openshift-pipelines/pipelines-serve-tkn-cli-rhel8" \
      version="${CI_CONTAINER_VERSION}" \
      summary="Red Hat OpenShift pipelines serves tkn CLI binaries" \
      description="Serves tkn CLI binaries from server" \
      io.k8s.display-name="Red Hat OpenShift Pipelines tkn CLI serve" \
      maintainer="pipelines-extcomm@redhat.com"
      io.k8s.description="Red Hat OpenShift Pipelines tkn CLI serve" \
      io.openshift.tags="pipelines,tekton,openshift"
