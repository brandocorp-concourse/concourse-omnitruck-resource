# concourse-omnitruck-resource

A Concourse CI resource for the Chef Omnitruck API

## Example

### Making the resource available

```
resource_types:
- name: omnitruck
  type: docker-image
  source:
    repository: brandocorp/concourse-omnitruck-resource
    tag: latest
```

### Using the resource

```
resources:
- name: ubnutu-stable-chefdk-release
  type: omnitruck
  source:
    product: chefdk
    channel: stable
    platform: ubuntu
    platform_version: 16.04
    architecture: x86_64
  version:
    release: latest
- name: centos-automate-chefdk-release
  type: omnitruck
  source:
    product: automate
    channel: stable
    platform: centos
    platform_version: 7.1
    architecture: x86_64
  version:
    release: latest
```
