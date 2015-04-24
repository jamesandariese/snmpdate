// Connect to 192.168.0.1 with timeout of 5 seconds
package main

import (
	"github.com/alouca/gosnmp"
	"os"
	"log"
	"time"
	"fmt"
	"flag"
)

var community = flag.String("community", "public", "SNMP community to chat with")

var offset = flag.Bool("offset", false, "instead of displaying the time, display the offset in seconds between localhost and the remote server.")
var floatoffset = flag.Bool("floatoffset", false, "instead of displaying the time, display the offset in fractional seconds between localhost and the remote server.")

var nagiosCritical = flag.Duration("critical", 0, "if > 0, change output to Nagios format; critical level is >= critical")
var nagiosWarning = flag.Duration("warning", 0, "if > 0, change output to Nagios format; warning level is >= warning")
var nagios = flag.Bool("nagios", false, "if set, change output to Nagios format; this will always return as OK or UNKNOWN -- use warning and/or critical for error states")

var format = flag.String("format", "2006-01-02 15:04:05 -0700", "format for time output; uses golang magic time format: http://golang.org/pkg/time")

var unix = flag.Bool("unix", false, "output number of seconds since Jan 1, 1970 UTC")
var unixNano = flag.Bool("nano", false, "output number of nanoseconds since Jan 1 1970 UTC (decisecond precision)")

func nagiosMode(t *time.Time) bool {
	if *nagiosCritical == 0 && *nagiosWarning == 0 && !*nagios {
		return false
	}
	
	if t == nil {
		fmt.Printf("UNKNOWN - timeout requesting time\n")
		os.Exit(3)
}

	since := time.Since(*t)
	
	if *nagiosCritical > 0 && (since >= *nagiosCritical || -since >= *nagiosCritical) {
		fmt.Printf("CRITICAL - time diff: %f\n", since.Seconds())
		os.Exit(2)
	}

	if *nagiosWarning > 0 && (since >= *nagiosWarning || -since >= *nagiosWarning) {
		fmt.Printf("WARNING - time diff: %f\n", since.Seconds())
		os.Exit(1)
	}

	fmt.Printf("OK - time diff: %f\n", since.Seconds())
	os.Exit(0)
	return true
}

func unixMode(t *time.Time) bool {
	if *unixNano {
		fmt.Println(t.UnixNano())
		os.Exit(0)
	}

	if *unix {
		fmt.Println(t.Unix())
		os.Exit(0)
	}

	return false
}

func displayTime(t *time.Time) {
	if nagiosMode(t) {
		// nagiosMode never returns true, actually.
		return
	}

	if t == nil {
		fmt.Println("FAIL")
		os.Exit(1)
	}

	if unixMode(t) {
		// neither does this
		return
	}

	if *floatoffset {
 		since := time.Since(*t)
		fmt.Println(since.Seconds())
		os.Exit(0)
	}

	if *offset {
 		since := time.Since(*t)
		fmt.Println(since/time.Second)
		os.Exit(0)
	}

	fmt.Println(t.Format(*format))
	os.Exit(0)
}


func main() {
	flag.Parse()

	args := flag.Args()
	if len(args) != 1 {
		flag.Usage()
		os.Exit(1)
	}

	s, err := gosnmp.NewGoSNMP(args[0], *community, gosnmp.Version2c, 5)
	if err != nil {
		log.Fatal(err)
	}
	resp, err := s.Get(".1.3.6.1.2.1.25.1.2.0")
	if err == nil {
		for _, v := range resp.Variables {
			switch v.Type {
			case gosnmp.OctetString:
				bytes := []byte(v.Value.(string))

				var loc *time.Location
				secondsFromUTC := 60*60*int(bytes[9]) + int(bytes[10])*60
				if bytes[8] == 0x2d {
					loc = time.FixedZone("", -secondsFromUTC)
				} else {
					loc = time.FixedZone("", secondsFromUTC)
				}
					
				t := time.Date(
					int(bytes[0])*0x100 + int(bytes[1]), //year
					time.Month(int(bytes[2])), //month
					int(bytes[3]), //day
					int(bytes[4]), //hour
					int(bytes[5]), //minute
					int(bytes[6]), //second
					1000000000 * int(bytes[7]), //decisecond
				loc)
				t = t.UTC()
				displayTime(&t)
				return
			}
		}
	}
	fmt.Println(err)
	displayTime(nil)
}
