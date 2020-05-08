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

rf4c (I'm a plane buff :p) is my take on an automated recon script for bug bounties.

The script uses Amass which will obviously need to be installed ahead of time

Amass can easily be installed using snapd (https://snapcraft.io/install/amass/ubuntu)

Interesting domain names is also reliant on a wordlist which you'll need to supply.  These
can be supplied near the top of the script by looking for the below lines.

LOGFILE="Your_Dir/rf4c.log"
...........................
keywordlist="Your_Dir/Your_Keywords.txt"

The script can be used as follows:
"sudo ./rf4c.sh domain_OR_list target output"

As shown above, the targets can be fed in singular or using a list

Warning: This code was originally created for personal use, it generates a substantial amount of traffic, please use with caution.


