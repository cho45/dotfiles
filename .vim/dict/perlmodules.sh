#!/bin/sh

GET http://www.cpan.org/modules/02packages.details.txt.gz | gzip -d | cut -d " " -f 1 >> perl.dict

