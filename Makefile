.DEFAULT_GOAL:=help
.PHONY: build_ansible_image build_nginx_image deploy help save_nginx_image check_release_env

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check_release_env:
ifndef RELEASE
	$(error Environment variable [RELEASE] is undefined!)
endif

build_nginx_image: check_release_env ## Build nginx docker image
	@docker build -f docker/nginx/Dockerfile -t aweng-cdn-nginx:$${RELEASE} .

save_nginx_image: check_release_env ## Save nginx docker image as tar.gz file
	@docker save aweng-cdn-nginx:$${RELEASE} | gzip > aweng-cdn-nginx.tar.gz

build_ansible_image: ## Build ansible docker image
	@docker build -t aweng-cdn-ansible docker/ansible

deploy: check_release_env ## Deploy application
	@docker run --rm -v $$(pwd):/app -e RELEASE=$${RELEASE} aweng-cdn-ansible ansible-playbook ansible/playbook.yml