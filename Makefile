snmpdate_1.1_amd64.deb: snmpdate snmpdate.1.gz
	gem install fpm
	mkdir -p usr/bin usr/share/man/man1
	cp snmpdate usr/bin
	cp snmpdate.1.gz usr/share/man/man1
	fpm -s dir -t deb -n snmpdate -v 1.1 usr

snmpdate: snmpdate.go
	go get
	go build

snmpdate.1.gz: README.md
	gem2.2 install ronn
	grep -vE '^\[!\[Build Status\]' README.md | ronn |gzip -9> snmpdate.1.gz

clean:
	rm -f snmpdate snmpdate_*_amd64.deb
