# default some travis stuff

openparen=(

PROJECT_NAME=$(shell head -1 README.md | grep -o "^[^$(openparen)]*" )

FPM_URL=$(shell git remote -v show origin | grep Fetch\ URL |cut -d: -f 2-|grep -o '[^ ].*'|sed -e 's/\.git$$//')
ifeq (${FPM_URL},)
FPM_URL=http://nourl
endif

ifeq (${TRAVIS_REPO_SLUG},)
FPM_DEFAULT_DESCRIPTION=$(basename ${PWD})
else
FPM_DEFAULT_DESCRIPTION=${TRAVIS_REPO_SLUG}
endif

FPM_DESCRIPTION=$(shell head -1 README.md | grep -oE ' -- .*' | cut -c 5- | awk '/[^ \t]/{print;x=1} END {if (!x) print "${FPM_DEFAULT_DESCRIPTION}"}')





ifeq (${TRAVIS_BUILD_NUMBER},)
TRAVIS_BUILD_NUMBER=0
endif

PACKAGE_VERSION=$(shell echo "${TRAVIS_TAG}" | grep -oE '^v[0-9.]+$$' | cut -c 2-)
ifeq (${PACKAGE_VERSION},)
PACKAGE_TYPE=-dev
PACKAGE_VERSION=${TRAVIS_BUILD_NUMBER}
FPM_CONFLICTS=--conflicts ${PROJECT_NAME} --provides ${PROJECT_NAME}
else
PACKAGE_TYPE=
endif


ALL: 	${PROJECT_NAME}.1.gz \
	${PROJECT_NAME}.darwin_amd64 \
	${PROJECT_NAME}${PACKAGE_TYPE}_${PACKAGE_VERSION}_amd64.deb \
	${PROJECT_NAME}${PACKAGE_TYPE}-${PACKAGE_VERSION}-1.x86_64.rpm

${PROJECT_NAME}${PACKAGE_TYPE}_${PACKAGE_VERSION}_amd64.deb: ${PROJECT_NAME} ${PROJECT_NAME}.1.gz
	gem install fpm
	mkdir -p build-deb/usr/bin build-deb/usr/share/man/man1
	cp ${PROJECT_NAME} build-deb/usr/bin
	cp ${PROJECT_NAME}.1.gz build-deb/usr/share/man/man1
	fpm ${FPM_CONFLICTS} --description "${FPM_DESCRIPTION}" --url "${FPM_URL}" -s dir -t deb -n ${PROJECT_NAME}${PACKAGE_TYPE} -v ${PACKAGE_VERSION} -C build-deb .

${PROJECT_NAME}${PACKAGE_TYPE}-${PACKAGE_VERSION}-1.x86_64.rpm: ${PROJECT_NAME} ${PROJECT_NAME}.1.gz
	gem install fpm
	mkdir -p build-rpm/usr/bin build-rpm/usr/share/man/man1
	cp ${PROJECT_NAME} build-rpm/usr/bin
	cp ${PROJECT_NAME}.1.gz build-rpm/usr/share/man/man1
	fpm ${FPM_CONFLICTS} --description "${FPM_DESCRIPTION}" --epoch 0 --url "${FPM_URL}" -s dir -t rpm -n ${PROJECT_NAME}${PACKAGE_TYPE} -v ${PACKAGE_VERSION} -C build-rpm .

${PROJECT_NAME}: ${PROJECT_NAME}.go
	go get
	go build

${PROJECT_NAME}.darwin_amd64.gz: ${PROJECT_NAME}.darwin_amd64
	gzip -9c < ${PROJECT_NAME}.darwin_amd64 > ${PROJECT_NAME}.darwin_amd64.gz

${PROJECT_NAME}.darwin_amd64: ${PROJECT_NAME}.go
	wget http://www.strudelline.net/goccdarwin-1.4.1.tar.gz
	tar zxf goccdarwin-1.4.1.tar.gz
	GOOS=darwin GOARCH=amd64 GOROOT=${PWD}/gosrc gosrc/bin/go get
	GOOS=darwin GOARCH=amd64 GOROOT=${PWD}/gosrc gosrc/bin/go build -o ${PROJECT_NAME}.darwin_amd64

${PROJECT_NAME}.1.gz: README.md
	rvm install 2.2.2
	rvm 2.2.2 do gem install ronn
	grep -vE '^\[!\[Build Status\]' README.md | rvm 2.2.2 do ronn |gzip -9> ${PROJECT_NAME}.1.gz
	grep -vE '^\[!\[Build Status\]' README.md | rvm 2.2.2 do ronn -m | cat

clean:
	rm -rf ${PROJECT_NAME} ${PROJECT_NAME}.1.gz ${PROJECT_NAME}*.deb ${PROJECT_NAME}*.rpm build-deb build-rpm rm -rf gosrc goccdarwin-1.4.1.tar.gz ${PROJECT_NAME}.darwin_amd64 ${PROJECT_NAME}.darwin_amd64.gz
