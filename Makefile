# default some travis stuff

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

snmpdate${PACKAGE_TYPE}_${PACKAGE_VERSION}_amd64.deb: snmpdate snmpdate.1.gz
	gem install fpm
	mkdir -p usr/bin usr/share/man/man1
	cp snmpdate usr/bin
	cp snmpdate.1.gz usr/share/man/man1
	fpm --description "`head -1 README.md | grep -oE ' -- .*' | cut -c 5- |awk '/[^ \t]/{print;x=1} END {if (!x) print "${TRAVIS_REPO_SLUG}"}'`" --url "https://github.com/jamesandariese/snmpdate" -s dir -t deb -n snmpdate${PACKAGE_TYPE} -v ${PACKAGE_VERSION} usr

snmpdate: snmpdate.go
	go get
	go build

snmpdate.1.gz: README.md
	rvm install 2.2.2
	rvm 2.2.2 do gem install ronn
	grep -vE '^\[!\[Build Status\]' README.md | rvm 2.2.2 do ronn |gzip -9> snmpdate.1.gz
	grep -vE '^\[!\[Build Status\]' README.md | rvm 2.2.2 do ronn -m | cat

clean:
	rm -f snmpdate snmpdate.1.gz snmpdate_*.deb
