# Copyright (c) 2016-.. #John
#
# Author: #John <pocolab.com@gmail.com>
# URL: http://www.pocolab.com
# Version: 1.0.0

# Commentary:

# Parse generated http/ftp pages (lan ua)

# License:

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Emacs; see the file COPYING.  If not, write to the
# Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA 02110-1301, USA.
#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use LWP::Simple;
use open ':std', ':encoding(UTF-8)';
use utf8;
my $file_name;
my $fh;
my $dir_content="content";

sub get_content{
    my$url="@_";
    my$content=get$url;
    die"Couldn't get $url"unless defined$content;
    return $content;
}
sub get_dirs{
    my$content="@_";
    
    my@arr; 
    while ($content=~/(href="[\p{L} \/.\d\-_+\(\),'%]+\/)/gi) {
	my$dir=$1;
	$dir=~s/(href=")//gi; 
	$dir=~s/(\.\.\/)//gi; 
	if($dir){
	    push@arr,$dir;
	}
    }
    return@arr;
}
sub get_title{
    my$content="@_";
    $content=~/(title\>[\p{L} \/.\d\-_+\(\),'%]+)/gi;
    my $title=$1;
    $title=~s/(title\>)//gi;
    return$title;
}
sub get_files{
    my$content="@_";
    
    my@arr; 
    while ($content=~/(href="[\p{L} \/.\d\-_+\(\),'%]+\.(avi)|(mkv)|(mp4)|(mpg)|(mpeg))/gi) {
	my$dir=$1;
	$dir=~s/(href=")//gi; 
	push@arr,$dir;
    }
    return@arr;

}

sub get_dirs_files{
    my$url="@_";
    my$content=get_content($url);
    my@files=get_files($content);
    if(@files){
	my$title=get_title($content);
	foreach my$file(@files){
	    print$fh "#EXTINF:-1,$title\n";
	    print$fh "$url$file\n";
	}
    }
    my@dirs=get_dirs($content);
    if(@dirs){
	foreach my$dir(@dirs){
	    get_dirs_files("$url$dir");
	}
    }
}

sub main{
    $ARGV="@_";
    
    mkdir$dir_content;
    
    foreach my$url($ARGV){

	my$content=get_content($url);
	my@dirs=get_dirs($content);
	
	foreach my$dir(@dirs){
	    $file_name=$dir;
	    $file_name=~s/(\/$)//g;
	    $file_name="$dir_content/$file_name.m3u";
	    open($fh, '>:encoding(UTF-8)', $file_name) or die "Could not open file '$file_name' $!";
	    
	    get_dirs_files("$url$dir");
	    
	    close $fh;
	    
	}

	
    }
}
main(@ARGV);
