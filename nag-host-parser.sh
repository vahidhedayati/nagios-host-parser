#!/bin/bash


file=$1;
pattern=$2
stype=$3;

if [ $# -lt 2 ];then
  echo $0 file pattern {include/exclude}
	echo $0 host.cfg uat include
	exit 1;
fi

if [ "$stype" == "" ]; then
	stype="include";
fi



function runawk() { 
awk -v pattern=$pattern -v stype=$stype 'BEGIN { memberlist=""; hostlist="";  go=0; rhost=""; } 
/^[[:space:]]*define host[[:space:]]*{[[:space:]]*$/ { codeblock="hostgroup"; }
		/^[[:space:]]*use[[:space:]]/ {huse=$2;}
		/^[[:space:]]*host_name[[:space:]]/ { hname=$2; }
		/^[[:space:]]*alias[[:space:]]/ { halias=$2; }
		/^[[:space:]]*address[[:space:]]/ {hadd=$2; }
		/^[[:space:]]*}[[:space:]]*$/ {
	  		if  ( (codeblock=="hostgroup") && (hname ~ pattern) && (stype == "include" )  )   {  print "define host {\n\tuse\t\t"huse"\n\thost_name\t"hname"\n\talias\t\t"halias"\n\taddress\t\t"hadd"\n}\n"; }
	  		if  ( (codeblock=="hostgroup") && (hname !~ pattern) && (stype == "exclude" )  )   { print "define host {\n\tuse\t\t"huse"\n\thost_name\t"hname"\n\talias\t\t"halias"\n\taddress\t\t"hadd"\n}\n"; }
			if (codeblock != "hostgroup" ) { print; }
}'
}



cat $file|runawk;
