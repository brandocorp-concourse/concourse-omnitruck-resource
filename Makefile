VERSION="latest"

all: test

check:
	(docker --version 2>&1 >/dev/null) || exit "Docker must be installed, and accessible via PATH"

image: check
	docker build $(PWD) -f Dockerfile -t brandocorp/concourse-omnitruck-resource:$(VERSION)

test: check image
	test/local.sh

publish: image test
	docker push brandocorp/concourse-omnitruck-resource:$(VERSION)
