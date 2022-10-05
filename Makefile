

# -----------------------------------------
# BUILD
# -----------------------------------------
build:
	docker build -t devenv:latest .

run:
	docker run -it --rm --name devenv -v $(PWD):/home/vscode devenv:latest
