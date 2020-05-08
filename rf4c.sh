#!/bin/bash -
#===============================================================================
#rf4c v0.2 - Copyright 2020 James Slaughter,
#This file is part of rf4c v0.2.

#rf4c v0.2 is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#rf4c v0.2 is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with rf4c v0.2.  If not, see <http://www.gnu.org/licenses/>.
#===============================================================================
#------------------------------------------------------------------------------
#
# Execute rf4c on top of an Ubuntu-based Linux distribution.
# This is my take on a recon script.  Heavily inspired by Nahamsec's LazyRecon
# It can be found here: https://github.com/nahamsec/lazyrecon
#
#------------------------------------------------------------------------------

__ScriptVersion="rf4c-v0.2"
LOGFILE="<Your Dir>/rf4c.log"
domainorlist=$1
target=$2
output=$3
keywordlist="<Your Dir>/<Your Keywords>.txt"

echoerror() {
    printf "${RC} [x] ${EC}: $@\n" 1>&2;
}

echoinfo() {
    printf "${GC} [*] ${EC}: %s\n" "$@";
}

echowarn() {
    printf "${YC} [-] ${EC}: %s\n" "$@";
}

usage() {
    echo "usage: sudo rf4c.sh <domain OR list> <target> <output>"
    exit 1
}

initialize() {

    echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
    echoinfo "Running rf4c.sh version $__ScriptVersion on `date`" >> $LOGFILE
    echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE

    echoinfo "---------------------------------------------------------------"
    echoinfo "Running rf4c.sh version $__ScriptVersion on `date`"
    echoinfo "---------------------------------------------------------------"


    if [ $domainorlist == 'list' ]
    then
        echoinfo "---------------------------------------------------------------"
        echoinfo "Target list is: '$target'" 
        echoinfo "---------------------------------------------------------------"

        echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
        echoinfo "Target list is: '$target'" >> $LOGFILE
        echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
    else
        echoinfo "---------------------------------------------------------------"
        echoinfo "Target domain is: '$target'" 
        echoinfo "---------------------------------------------------------------"

        echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
        echoinfo "Target domain is: '$target'" >> $LOGFILE
        echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE 
    fi


    echoinfo "---------------------------------------------------------------"
    echoinfo "Creating files and directories..." 
    echoinfo "---------------------------------------------------------------"

    echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
    echoinfo "Creating files and directories..." >> $LOGFILE
    echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE

    if [ -d "$output" ]
    then
      echowarn "$output - This is output directory exists..."
    else
      mkdir $output
      chmod -R 777 $output 
    fi

    touch /$output/crtsh.txt
    touch /$output/alldomains.txt
    touch /$output/domainlist.txt
    touch /$output/nmap.txt
    touch /$output/temp1.txt
    touch /$output/temp2.txt
    touch /$output/domaintemp.txt
    touch /$output/responsive.txt
    touch /$output/urllist.txt
    touch /$output/interesting.txt

    echoinfo "---------------------------------------------------------------"
    echoinfo "Initialization complete..." 
    echoinfo "---------------------------------------------------------------"

    echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
    echoinfo "Initialization complete..." >> $LOGFILE
    echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE

    return 0
}

pipe_to_amass() {
 
    #Execute Amass with the following params
    echoinfo "Piping program execution to Amass..."
    echoinfo "Piping program execution to Amass..." >> $LOGFILE

    echo $(snap run amass enum -passive -d $domain -o $output/domaintemp.txt) >> $LOGFILE

    cat $output/domaintemp.txt | tee -a $output/alldomains.txt

    #Amass unfortunately grabs some e-mail addresses from it's sources that mess up nmap later...scrubbing 
    echoinfo "Scrubbing e-mail addresses from Amass data..."
    echoinfo "Scrubbing e-mail addresses from Amass data..." >> $LOGFILE

    sed -n -i -r '/\w+@\w+\.\w+\s*$/!p' $output/alldomains.txt

    return 0
}

pipe_to_crtsh(){
  
    #Pull domain data on domain from crt.sh
    echoinfo "Piping program execution to cURL crt.sh..."
    echoinfo "Piping program execution to cURL crt.sh..." >> $LOGFILE
  
    curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> $output/crtsh.txt 
  
    cat $output/crtsh.txt | tee -a $output/alldomains.txt

    #Unfortunately we grab some e-mail addresses from some sources that mess up nmap later...scrubbing 
    echoinfo "Scrubbing e-mail addresses from alldomains.txt data..."
    echoinfo "Scrubbing e-mail addresses from alldomains.txt data..." >> $LOGFILE

    sed -n -i -r '/\w+@\w+\.\w+\s*$/!p' $output/alldomains.txt

    return 0
}

hostalive(){
    #ID any domains that are showing as alive
    echoinfo "Probing for live hosts..."
    echoinfo "Probing for live hosts..." >> $LOGFILE

    echo $(sudo nmap -PE -PM -PP -sn -iL $output/alldomains.txt -oA $output/responsive.txt)

    sed 's/^Nmap scan report for //' $output/responsive.txt.nmap >> temp1.txt
    sed '/^Other addresses for/ d' $output/temp1.txt >> temp2.txt
    sed 's/(.*//' temp2.txt >> $output/domainlist.txt

    echo "$(cat $output/domainlist.txt | sort -u)" > $output/domainlist.txt

    grep -E -o  "([0-9]{1,3}[\.]){3}[0-9]{1,3}" responsive.txt.gnmap | sort -u >> responsiveIPs.txt

    echo  "${yellow}Total of $(wc -l $output/domainlist.txt. | awk '{print $domain}') live subdomains were found${reset}"

    rm temp1.txt
    rm temp2.txt

    return 0
}

interesting(){
    
    grep -f $keywordlist $output/domainlist.txt >> $output/interesting.txt
  
    echo  "${yellow}Total of $(wc -l $output/interesting.txt | awk '{print $domain}') interesting subdomains were found${reset}"

    return 0
}

wrap_up() {
    echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
    echoinfo "Program complete on `date`" >> $LOGFILE
    echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE

    echoinfo "---------------------------------------------------------------"
    echoinfo "Program complete on `date`"
    echoinfo "---------------------------------------------------------------"
}

#Function calls
#Bail if we aren't root.  We have to do this for NMap
    if [ `whoami` != "root" ]; then
        echoerror "rf4c must run as root!"
        echoerror "Usage: sudo rf4c.sh <domain OR list> <target> <output>"
        exit 3
    fi
    if [ ! -z "$1" ] || [ ! -z "$2" ]
    then
        initialize
        if [ $domainorlist == 'list' ]
        then
            echoinfo "---------------------------------------------------------------"
            echoinfo "Looping through target list: '$target'" 
            echoinfo "---------------------------------------------------------------"

            echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
            echoinfo "Looping through target list: '$target'" >> $LOGFILE
            echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
            while read -r line; do
                domain=$line

                echoinfo "---------------------------------------------------------------"
                echoinfo "Target domain is: '$domain'" 
                echoinfo "---------------------------------------------------------------"

                echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
                echoinfo "Target domain is: '$domain'" >> $LOGFILE
                echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE 
                pipe_to_amass
                pipe_to_crtsh     
            done < "$target"
        elif [ $domainorlist == 'domain' ]
        then
            echo '$target = ' $target 
            domain=$target

            echoinfo "---------------------------------------------------------------"
            echoinfo "Target domain is: '$domain'" 
            echoinfo "---------------------------------------------------------------"

            echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE
            echoinfo "Target domain is: '$domain'" >> $LOGFILE
            echoinfo "--------------------------------------------------------------------------------" >> $LOGFILE

            pipe_to_amass
            pipe_to_crtsh
        else
            exit 3
        fi
        hostalive
        interesting
    else
        usage
    fi
    wrap_up
