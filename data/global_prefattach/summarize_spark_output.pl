#!/usr/bin/perl
########################################################################
# Add specified number of random edges between two countries
########################################################################
use strict;
use warnings;

my $country_numbering_file = 'country_nodes_start_size.dat';

my @node_index;     # Dense index node_id => country_id ... dumb but easy & fast
my @country_index;  # Dense index country_id => country_name

open(FILE, "< $country_numbering_file") or die $!;
my @lines = <FILE>;
chomp @lines;
foreach my $line (@lines) {
  my ($country, $start, $size) = split /\t/, $line;
  #$country_info{$country} = { start => int($start), size => int($size) };
  #push @start_nodes, { start => int($start), country => $country };

  my $country_id = scalar @country_index;
  push @country_index, $country;
  my $end = int($start) + int($size);
  for (my $i = int($start); $i < $end; $i++) {
    push @node_index, $country_id;
  }
}
close FILE;

my %country_totals;
foreach my $country_name (@country_index) {
  $country_totals{$country_name} = 0;
}

while (defined(my $line = <>)) {
  chomp $line;
  $line =~ s/\D//g;
  my $infected_node = int($line);
  my $country_id = $node_index[$infected_node];
  my $country_name = $country_index[$country_id];
  $country_totals{$country_name}++;
}

# Now print.
foreach my $country_name (@country_index) {
  print $country_name, "\t", $country_totals{$country_name}, "\n";
}

exit 0;
