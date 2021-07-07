FROM quay.io/openshift-pipeline/golang:1.15-alpine AS builder

# Install dependencies

RUN apk add --no-cache git bash curl zip

# Install yq
RUN curl -sL -O https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_linux_amd64 -o /usr/local/bin/yq && mv ./yq_linux_amd64 /usr/local/bin/yq && chmod +x /usr/local/bin/yq

COPY . /registry

# Download the registry build tools
RUN git clone https://github.com/devfile/registry-support.git /registry-support

# Run the registry build tools
RUN /registry-support/build-tools/build.sh /registry /build

FROM quay.io/devfile/devfile-index-base:next

COPY --from=builder /build /registry