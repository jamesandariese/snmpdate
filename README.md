snmpdate(1) -- SNMP date getter/comparator
===

[![Build Status](https://travis-ci.org/jamesandariese/snmpdate.svg?branch=master)](https://travis-ci.org/jamesandariese/snmpdate)

## SYNOPSIS 

    `snmpdate`
    [-community="public"]                     ; SNMPv2c community
    [
        [-nagios | -critical=0 | -warning=0]  ; nagios mode
      | [-floatoffset | -offset]              ; offset mode
      | [-unix | -nano]                       ; epoch mode
      | [-format="2006-01-02 15:04:05 -0700"] ; standard date fetch mode (default)
    ]
    hostname | IP                             ; destination host

## DESCRIPTION

* Get a date from a remote host
* Print it with format
* Print it in seconds since epoch
* Offset mode for checking drift generically
* Nagios mode for checking drift nagiosically

## OPTIONS
  * `-community="public"`:
    SNMP community to chat with
  * `-critical=0`:
    if > 0, change output to Nagios format; critical level is >= critical
  * `-floatoffset=false`:
    instead of displaying the time, display the offset in fractional seconds between localhost and the remote server.
  * `-format="2006-01-02 15:04:05 -0700"`:
    format for time output; uses golang magic time format: http://golang.org/pkg/time
  * `-nagios=false`:
    if set, change output to Nagios format; this will always return as OK or UNKNOWN -- use warning and/or critical for error states
  * `-nano=false`:
    output number of nanoseconds since Jan 1 1970 UTC (decisecond precision)
  * `-offset=false`:
    instead of displaying the time, display the offset in seconds between localhost and the remote server.
  * `-unix=false`:
    output number of seconds since Jan 1, 1970 UTC
  * `-warning=0`:
    if > 0, change output to Nagios format; warning level is >= warning

## AUTHOR

    James Andariese <james@strudelline.net>



## COPYRIGHT

Copyright (c) 2015, James Andariese

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
