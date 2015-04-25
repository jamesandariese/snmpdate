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
else
PACKAGE_TYPE=
endif

${PROJECT_NAME}${PACKAGE_TYPE}_${PACKAGE_VERSION}_amd64.deb: ${PROJECT_NAME} ${PROJECT_NAME}.1.gz
	gem install fpm
	mkdir -p usr/bin usr/share/man/man1
	cp ${PROJECT_NAME} usr/bin
	cp ${PROJECT_NAME}.1.gz usr/share/man/man1
	fpm --description "${FPM_DESCRIPTION}" --url "${FPM_URL}" -s dir -t deb -n ${PROJECT_NAME}${PACKAGE_TYPE} -v ${PACKAGE_VERSION} usr

${PROJECT_NAME}: ${PROJECT_NAME}.go
	go get
	go build

${PROJECT_NAME}.1.gz: README.md
	rvm install 2.2.2
	rvm 2.2.2 do gem install ronn
	grep -vE '^\[!\[Build Status\]' README.md | rvm 2.2.2 do ronn |gzip -9> ${PROJECT_NAME}.1.gz
	grep -vE '^\[!\[Build Status\]' README.md | rvm 2.2.2 do ronn -m | cat

clean:
	rm -f ${PROJECT_NAME} ${PROJECT_NAME}.1.gz ${PROJECT_NAME}*.deb
