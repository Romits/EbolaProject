#!/usr/bin/perl
use strict;
use warnings;

use constant YEAR => 0;
use constant FROM_ID => 1;
use constant FROM_NAME => 2;
use constant FROM_SYM => 3;
use constant TO_ID => 4;
use constant TO_NAME => 5;
use constant TO_SYM => 6;
use constant DOLLARS => 7;

# converts total dollars exported to number of people flown per year.
#
# According to the US Office of Travel & Tourism industries,
# the number of international visitors to the US in 2013 was 69.77 million people:
# http://travel.trade.gov/view/m-2013-I-001/table1.html
#
# According to our trade data, recorded exports to USA for 2013 = 2,209,234,120,848.
#
# So, our ratio of dollar value imported to number of visitors is 31665 to 1.
#
# Assuming this same ratio applies to all countries, we divide all the numbers
# by 31665 to get number of people traveling per year from country to country.
# (Actually, the number is 31664.53).
#

my $RATIO = 31664.53;

while (defined(my $input = <>)) {
  chomp $input;
  # 2010	104	Myanmar	MMR	376	Israel	ISR	1231
  my @f = split(/\t/, $input);
  $f[DOLLARS] = int($f[DOLLARS] / $RATIO);
  print join("\t", @f), "\n";
}

exit 0;
