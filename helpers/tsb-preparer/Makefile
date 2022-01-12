.PHONY: build push-images

app: build push-images

build: check-imagerepo
	docker build . --tag $(image-repo)/tsb-preparer:1.4.4 

push-images: check-imagerepo
	docker push $(image-repo)/tsb-preparer:1.4.4

check-imagerepo:
ifndef image-repo
	$(error image-repo is undefined)
endif
