set -euxo pipefail

source ./config.sh

BUILD_MODE=${1:-build}

BUILD_AUTO_TAG=$(git rev-parse --abbrev-ref HEAD)-$(git rev-list --count HEAD)
BUILD_TAG=${BUILD_TAG:-${BUILD_AUTO_TAG}}
BUILD_DOCKER_BUILDER=${BUILD_DOCKER_BUILDER:-container}

echo "Building catlair/qqnt:${BUILD_TAG} using builder: ${BUILD_DOCKER_BUILDER}\n\n"

BUILD_ARCH_LIST=(
  amd64
  arm64
)

BUILD_QQNT_DATA_VERSION_LATEST=${BUILD_QQNT_DATA_LIST%,*}

for BUILD_QQNT_DATA in ${BUILD_QQNT_DATA_LIST[@]};
do
  BUILD_QQNT_VERSION=${BUILD_QQNT_DATA%,*}
  BUILD_QQNT_LINK=${BUILD_QQNT_DATA#*,}

  for BUILD_ARCH in ${BUILD_ARCH_LIST[@]};
  do
    BUILD_PLATFORM=linux/${BUILD_ARCH}

    BUILD_IMAGE_TAG=${BUILD_TAG}-linux-up${BUILD_QQNT_VERSION}
    BUILD_IMAGE_ARCH_TAG=${BUILD_TAG}-linux-${BUILD_ARCH}-up${BUILD_QQNT_VERSION}

    case ${BUILD_MODE} in
      "push")
        docker buildx build \
          --push \
          --builder=${BUILD_DOCKER_BUILDER} \
          --build-arg BUILD_QQNT_LINK=${BUILD_QQNT_LINK} \
          --build-arg BUILD_ARCH=${BUILD_ARCH} \
          --platform ${BUILD_PLATFORM} \
          -t ghcr.io/catlair/docker-qqnt:${BUILD_IMAGE_ARCH_TAG} \
          -t catlair/qqnt:${BUILD_IMAGE_ARCH_TAG} \
          .
        ;;
      *)
        docker buildx build \
          --builder=${BUILD_DOCKER_BUILDER} \
          --build-arg BUILD_QQNT_LINK=${BUILD_QQNT_LINK} \
          --build-arg BUILD_ARCH=${BUILD_ARCH} \
          --platform ${BUILD_PLATFORM} \
          -t ghcr.io/catlair/docker-qqnt:${BUILD_IMAGE_ARCH_TAG} \
          -t catlair/qqnt:${BUILD_IMAGE_ARCH_TAG} \
          .
        ;;
    esac
  done

  # https://github.com/docker/cli/issues/2396
  #
  # case ${BUILD_MODE} in
  #   "push")
  #     # Wait for manifest update
  #     sleep 60

  #     BUILD_MANIFEST_AMD64_DIGEST=$(docker buildx imagetools inspect --raw catlair/qqnt:${BUILD_TAG}-linux-amd64-up${BUILD_QQNT_VERSION} | jq --raw-output '.manifests | map(select(.platform.architecture == "amd64")) | .[0].digest')
  #     BUILD_MANIFEST_ARM64_DIGEST=$(docker buildx imagetools inspect --raw catlair/qqnt:${BUILD_TAG}-linux-arm64-up${BUILD_QQNT_VERSION} | jq --raw-output '.manifests | map(select(.platform.architecture == "arm64")) | .[0].digest')

  #     docker manifest create ghcr.io/catlair/docker-qqnt:${BUILD_TAG}-linux-up${BUILD_QQNT_VERSION} \
  #       ghcr.io/catlair/docker-qqnt@${BUILD_MANIFEST_AMD64_DIGEST} \
  #       ghcr.io/catlair/docker-qqnt@${BUILD_MANIFEST_ARM64_DIGEST}
  #     docker manifest push ghcr.io/catlair/docker-qqnt:${BUILD_TAG}-linux-up${BUILD_QQNT_VERSION}

  #     docker manifest create catlair/qqnt:${BUILD_TAG}-linux-up${BUILD_QQNT_VERSION} \
  #       catlair/qqnt@${BUILD_MANIFEST_AMD64_DIGEST} \
  #       catlair/qqnt@${BUILD_MANIFEST_ARM64_DIGEST}
  #     docker manifest push catlair/qqnt:${BUILD_TAG}-linux-up${BUILD_QQNT_VERSION}

  #     if [ "$BUILD_TAG" != "$BUILD_AUTO_TAG" -a $BUILD_QQNT_VERSION = $BUILD_QQNT_DATA_VERSION_LATEST ]
  #     then
  #       docker manifest create ghcr.io/catlair/docker-qqnt:latest \
  #         ghcr.io/catlair/docker-qqnt@${BUILD_MANIFEST_AMD64_DIGEST} \
  #         ghcr.io/catlair/docker-qqnt@${BUILD_MANIFEST_ARM64_DIGEST}
  #       docker manifest push ghcr.io/catlair/docker-qqnt:latest

  #       docker manifest create catlair/qqnt:latest \
  #         catlair/qqnt@${BUILD_MANIFEST_AMD64_DIGEST} \
  #         catlair/qqnt@${BUILD_MANIFEST_ARM64_DIGEST}
  #       docker manifest push catlair/qqnt:latest
  #     fi
  #     ;;
  #   *)
  #     ;;
  # esac
done
