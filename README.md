# graphlvm
GraphLVM for AIX Logical Volume Manager

Forked from the original written by Brian Smith at https://graphlvm.sourceforge.net/

GraphLVM for AIX is a Perl program that creates a visual representation of the AIX logical volume manager.  

Here is an example diagram created from the script:
<img src=images/graphlvm1.png>

<img src=images/graphlvm2.png>

<img src=images/graphlvm3.png>

<img src=images/graphlvm4.png>

# Installation / Use

GraphLVM uses the open source Graphviz application to create the diagrams.   For a quick overview of Graphviz please see the article I wrote:  Using Graphviz to generate automated system diagrams

When you run the script on AIX it will generate the Graphviz dot language code to create the diagram.   I recommend running the script on your AIX servers and then transferring the output .dot files to a Linux server that has Graphviz installed to generate the images. 

To gather the LVM information you can run the script on any AIX server without installing anything else other than the graphlvm.pl script.   Redirect the output to a file, and then transfer that file to a server/computer that has Graphviz installed:
```
    ./graphlvm.pl > lvm.dot
```

I recommend using Graphviz on Linux because it is in most distro's repositories and very easily installable.  Once you have transferred the .dot file to a server that has Graphviz, run a command such as this to create the image:
```
    dot -Tpng -o lvm.png lvm.dot
```

Again, to clarify, you only need to have Graphviz installed on a single server.  For example, you could run the graphlvm.pl script on a hundred AIX servers without installing anything else on them, and then transfer all the output files to a Linux server with Graphviz, and generate all of the images centrally on the Linux server. 

It is also possible to install Graphviz on AIX, but more difficult.  See http://www.perzl.org/aix/ for AIX binaries of Graphviz.



# Downloading
Download the script from:  https://sourceforge.net/projects/graphlvm/files/
or 
```
git clone https://github.com/nickjeffrey/graphlvm
cd graphlvm
chmod +x graphlvm.pl
```


# Related scripts
http://pslot.sourceforge.net/

http://npivgraph.sourceforge.net/

# License / Disclaimer
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

