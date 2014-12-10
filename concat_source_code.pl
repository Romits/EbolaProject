#!/usr/bin/perl
###################################################
use strict;
use warnings;

my @files = grep { ! m{/\.} } `find . -type f -name \\*.c -o -name \\*.cc -o -name \\*.scala -o -name \\*.java -o -name \\*.pl -o -name \\*.py -o -name \\*.sh -o -name \\*.m -o -name \\*README\\*`;
chomp @files;



print "\n";
print "================================================================================\n";
print "Table of contents:\n";
print "================================================================================\n";
print "\n";

foreach my $file (@files) {
  print $file, "\n";
}

#exit 0;

print "\n";
print "================================================================================\n";
print "Code:\n";
print "================================================================================\n";
print "\n";

foreach my $file (@files) {
  print "--------------------------------------------------------------------------------\n";
  print "> $file\n";
  print "--------------------------------------------------------------------------------\n";
  print `cat '$file'`;
  print "\n";
}

exit 0;
