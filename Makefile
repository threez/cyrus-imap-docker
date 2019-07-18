.PHONY: build run

build:
	docker build . -t threez/cyrus-imap

run:
	docker run --rm -ti -p 80:80 -p 143:143 -p 110:110 -p 2000:2000 -p 24:24 threez/cyrus-imap:latest

push:
	docker push threez/cyrus-imap:latest
