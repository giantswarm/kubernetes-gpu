#!/bin/bash

set -eu -o pipefail

NEW_VERSION="${1:-440.33}"

update_circleci() {
  echo "Updating circleci"
  sed -i.bak -E "s/(image_tag)(.+)/\1: \"$NEW_VERSION\"/" .circleci/config.yml
  rm -f .circleci/config.yml.bak
}

update_default_chart_value() {
  echo "Updating default chart value"
  cat helm/kubernetes-gpu-app/values.yaml | yq --arg version $NEW_VERSION '.driver.image.tag=$version' -y > helm/kubernetes-gpu-app/values.yaml_new
  mv helm/kubernetes-gpu-app/values.yaml_new helm/kubernetes-gpu-app/values.yaml
}

update_chart_app_version() {
  echo "Updating app version in Chart yaml"
  sed -i.bak -E "s/(appVersion)(.+)/\1: $NEW_VERSION/" helm/kubernetes-gpu-app/Chart.yaml
  rm -f helm/kubernetes-gpu-app/Chart.yaml.bak
}

update_dockerfile() {
  echo "Updating dockerfile"
  sed -i.bak -E "s/(NVIDIA_DRIVER_VERSION)(.+)/\1=\"$NEW_VERSION\"/" Dockerfile
  rm -f Dockerfile.bak
}

main() {
  update_circleci
  update_default_chart_value
  update_chart_app_version
  update_dockerfile
}

main "$@"
