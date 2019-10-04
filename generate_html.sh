#!/bin/bash
mkdir html
for a in maxref/fluid.*.xml
do
  destfile=${a#maxref/}
  destfile=${destfile%.maxref.xml}
  xsltproc --stringparam compliant 1 xslt/_c74_ref.xsl $a >  html/${destfile}.html
done
cp xslt/_c74_common.css html/
