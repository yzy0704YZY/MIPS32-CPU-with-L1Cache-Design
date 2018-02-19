#! /bin/csh -f

setenv RC_HOME /icd/rc/rc121/latest.RED

# Note: you must specify the right platform (tools.sun4v, .sol86, or .lnx86)
setenv IUS ${CDSROOT}/tools.lnx86

set path = (${RC_HOME}/bin ${IUS}/bin $path)

setenv CDS_LIC_FILE 5280@sjflex2.cadence.com:5280@sjflex3.cadence.com
chmod +w .
