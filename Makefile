.PHONY: build
build:
	docker build -t lambda-docs-mkdocs .

.PHONY: serve
serve: build
	docker run --rm -it -p 8000:8000 -v ${PWD}:/docs lambda-docs-mkdocs serve
