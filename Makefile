snmpdate_1.2_amd64.deb: snmpdate snmpdate.1.gz
	gem install fpm
	mkdir -p usr/bin usr/share/man/man1
	cp snmpdate usr/bin
	cp snmpdate.1.gz usr/share/man/man1
	fpm -s dir -t deb -n snmpdate -v 1.2 usr

snmpdate: snmpdate.go
	go get
	go build

snmpdate.1.gz: README.md
	#ls -l `which gem | sed -e 's#\(^.*/\)[^/]*$$#\1gem*#'`
	#gem2.2 install ronn
	rvm install 2.2.2
	rvm 2.2.2 do gem install ronn
	grep -vE '^\[!\[Build Status\]' README.md | rvm 2.2.2 do ronn |gzip -9> snmpdate.1.gz

clean:
	rm -f snmpdate snmpdate_*_amd64.deb
