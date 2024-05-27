VERSION=`git describe --tags`
BUILD_TIME=`date +%FT%T%z`
LDFLAGS=-ldflags "-X main.Version=$(V) -X main.BuildTime=${BUILD_TIME}"
NAME=oosa-gw

run: gen-conf
	docker run -p "8080:8080" -v $$PWD:/etc/krakend/ --platform linux/amd64 devopsfaith/krakend:2.1.4 run -c krakend_pretty.json

build-docker-img:
	docker build --platform linux/amd64 -t ${NAME}:dev .
	docker rmi -f $$(docker images --filter "dangling=true" -q --no-trunc)

push-docker:
	docker tag ${NAME}:dev  94peter/${NAME}:$(V)
	docker push 94peter/${NAME}:$(V)

gen-conf:
	docker run -it \
	-e FC_ENABLE=1 -e FC_PARTIALS="./partials" \
	-e FC_SETTINGS="./settings" -e FC_OUT=krakend_pretty.json \
	-v $$PWD:/etc/krakend/ devopsfaith/krakend:2.1.4 check -d -t -c ./krakend.tmpl
	docker run -i stedolan/jq --compact-output <krakend_pretty.json '.' > krakend.json


