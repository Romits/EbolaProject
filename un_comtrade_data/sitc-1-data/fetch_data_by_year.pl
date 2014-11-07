#!/usr/bin/perl
use strict;
use warnings;

my $tradeCode = "S1";

sub fetch_for_year($@) {
  my $year = shift;
  my @reporters = @_;
  while (scalar @reporters) {
    my @curReporters = splice(@reporters, 0, 5);
    my $repStr = join(",", @curReporters);
    my $cmd = "curl 'http://comtrade.un.org/api/get?fmt=csv&max=50000&type=C&freq=A&px=$tradeCode&ps=$year&r=$repStr&p=all&rg=2&cc=TOTAL' > trade-$year-$repStr.txt";
    print "> $cmd\n";
    system($cmd) == 0
        or die "system($cmd) failed: $?";
    sleep 1;
  }
}


my $rep_year = "reporters_by_year.txt";
open(FILE, "< $rep_year") or die "Cannot open file $rep_year $!";
my @lines = <FILE>;
close FILE;

my %years = ();
foreach my $line (@lines) {
  chomp $line;
  my ($year, $reporter) = split("\t", $line);
  if (!exists $years{$year}) {
    $years{$year} = [];
  }
  push @{$years{$year}}, $reporter;
}

foreach my $year (sort keys %years) {
  fetch_for_year($year, @{$years{$year}});
}

exit 0;
