snmpdate_1.0_amd64.deb: snmpdate
	gem install fpm
	fpm -s dir -t deb -n snmpdate --prefix /usr/bin -v 1.0 snmpdate

snmpdate: snmpdate.go
	go get
	go build

clean:
	rm -f snmpdate snmpdate_*_amd64.deb
