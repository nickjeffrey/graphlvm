#!/usr/bin/perl
# graphlvm for AIX
#
# Copyright 2012 Brian Smith 
#
# version 0.2 Alpha - 10/13/12
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;

my ($pv, $lv, $lvd, $vgd,$varyon);
my %lv_hash;

print "graph graphlvm {\n";
print "rankdir=LR\n";

my @pvlist = `lspv | awk '{print \$3 " " \$1 " " \$2}' | sort`;

my $lastvg = "";
foreach $pv (@pvlist){
  if ($pv =~ /(\S+)\s+(\S+)\s+(\S+).*/){
    my $vg = $1;
    my $hdisk = $2;
    my $pvid = $3;
    if ($lastvg ne $vg){
      if ($lastvg ne "") {print "}\n";}
      print "subgraph \"cluster_$vg\" {\n";
      print "color=lightblue\n";
      print "style=filled\n";
      if ($vg ne "None"){
        my ($vgtotal,$vgfree,$vgused);
        $varyon = system("lsvg -o | grep \"^${vg}\$\" >/dev/null 2>&1");
        if ($varyon == 0){
          my @vgdetails = `lsvg $vg`;
          foreach $vgd (@vgdetails){
            if ($vgd =~ /.*TOTAL PPs:\s+\d+\s+\((\S+) mega.*/) {$vgtotal = $1;}
            if ($vgd =~ /.*FREE PPs:\s+\d+\s+\((\S+) mega.*/) {$vgfree = $1;}
            if ($vgd =~ /.*USED PPs:\s+\d+\s+\((\S+) mega.*/) {$vgused = $1;}
          }
          print "label=\"Volume Group: $vg\\nTotal Size: $vgtotal MB\\n";
          print "Used Space: $vgused MB\\n";
          print "Free Space: $vgfree MB\"\n";
        }else{
          print "label=\"Volume Group: $vg\\nNot varied on\"\n";
        }
      }else{
        print "label=\"Not allocated to a Volume Group\"\n";
      }
    }
    my $size=`getconf DISK_SIZE /dev/$hdisk`;
    chomp($size);
    print "\"$hdisk\" [shape=doublecircle,fillcolor=lightgrey,fontcolor=black,style=filled,fontsize=10,label=\"$hdisk\\n$size MB\"]\n";
    $lastvg = $vg;
    if ($vg ne "None" && $varyon == 0) {
      my @lvs = `lspv -l $hdisk | tail +3 | awk '{print \$1}'`;
      foreach $lv (@lvs){
        chomp ($lv);
        print "\"$hdisk\" -- \"$lv\"\n";
        #if (! grep /\Q^$lv$/, %lv_hash){
        if (! exists $lv_hash{$lv}){
          $lv_hash{$lv} = "";
          my @lvdetails = `lslv $lv`;
          my ($mg,$ppsize,$mount,$label,$copies,$lps,$pps,$type,$ssize,$swidth);
          $mount = $mg = $ppsize = $label = $copies = $lps = $pps = $type = $ssize = $swidth = "N/A";
          foreach $lvd (@lvdetails) {
            if ($lvd =~ /.*MOUNT POINT:\s+(\S+).*/) {$mount = $1;}
            if ($lvd =~ /.*LABEL:\s+(\S+).*/) {$label = $1;}
            if ($lvd =~ /.*COPIES:\s+(\S+).*/) {$copies = $1;}
            if ($lvd =~ /.*PP SIZE:\s+(\S+) mega.*/) {$ppsize = $1;}
            if ($lvd =~ /.*LPs:\s+(\S+).*/) {$lps = $1;}
            if ($lvd =~ /^LP.*PPs:\s+(\S+).*/) {$pps = $1;}
            if ($lvd =~ /^\s*TYPE:\s+(\S+).*/) {$type = $1;}
            if ($lvd =~ /.*\s*STRIPE WIDTH:\s+(\S+).*/) {$swidth = $1;}
            if ($lvd =~ /.*\s*STRIPE SIZE:\s+(\S+).*/) {$ssize = $1;}
            if ($lvd =~ /.*\s*EACH LP COPY ON A SEPARATE PV \?:\s+(\S+).*/) {$mg = $1;}
          }    

          my $factor = $pps / $lps;
          my ($lvshape,$lvcolor,$lvtype);
          if ($factor == 2){
            $lvtype = "Mirrored * 2";
            $lvcolor = "aliceblue";
            $lvshape = "doubleoctagon";
          }elsif ($factor == 3 ){
            $lvtype = "Mirrored * 3";
            $lvcolor = "azure3";
            $lvshape = "tripleoctagon";
          }else{
            $lvtype = "";
            $lvcolor = "aquamarine1";
            $lvshape = "octagon";
          }

          if ($swidth ne "N/A") { $lvtype .= "\\nStripe width: $swidth\\nStripe size: $ssize"; }

          if ($mg eq "no") {$lvcolor = "red"; $lvtype .= "\\nWARNING\\nNot mirrored on\\ndifferent PV's";}

          print "\"$lv\" [shape=$lvshape,fillcolor=$lvcolor,fontcolor=black,style=filled,fontsize=10,label=\"Logical Volume\\n";
          my $lvsize = $ppsize * $pps;
          if ($mount ne "N/A") { print "Mountpoint: $mount\\n";}
          print "$lv\\nType: $type\\nLabel: $label\\nsize: $lvsize MB\\n$lvtype\"]\n";

          if ($mount ne "N/A") { 
            print "\"$lv\" -- \"$mount\"\n";
            my ($fsinfo, $fssize, $fsused, $fsfree);
            $fssize = $fsused = $fsfree = "Not Mounted";
            $fsinfo = `df -mt | grep " ${mount}\$"`;
            if ($fsinfo =~ /\S+\s+(\S+)\s+(\S+)\s+(\S+)/) {
              $fssize = "$1 MB";
              $fsused = "$2 MB";
              $fsfree = "$3 MB";
            }
            print "\"$mount\" [shape=oval,fillcolor=darkturquoise,fontcolor=black,style=filled,fontsize=10,label=\"Filesystem\\n";
            print "$mount\\nSize: $fssize\\n";
            print "Used: $fsused\\n Free: $fsfree\\n\"]\n";
          }
        }
      }
    }  
  }
}

print "}\n";
print "labelloc=\"t\"\n";
print "label=\"graphlvm by Brian Smith\"\n";
print "}\n";
