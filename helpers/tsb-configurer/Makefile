.PHONY: build push-images

app: build push-images

build: check-imagerepo
	docker build . --tag $(image-repo)/tsb-configurer:1.0

push-images: check-imagerepo
	docker push $(image-repo)/tsb-configurer:1.0

check-imagerepo:
ifndef image-repo
	$(error image-repo is undefined)
endif
