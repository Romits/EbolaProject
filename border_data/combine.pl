#!/usr/bin/perl
use strict;
use warnings;
use Math::Round;

my $pop_file = 'cia_wfb_population.tsv';
my $borders_file = '-';

# We assume 50% of the population works and .2% of them commute internationally.
my $POPULATION_COMMUTER_FRACTION = 0.001;

my %pop_map;
open(FILE, "< $pop_file") or die $!;
while (defined(my $line = <FILE>)) {
  chomp $line;
  my ($rank, $country, $population) = split /\t/, $line;
  $population =~ s/,//g;
  $pop_map{$country} = int($population);
}
close FILE or die $!;

open(FILE, "< $borders_file") or die $!;
while (defined(my $line = <FILE>)) {
  chomp $line;
  my ($country, $border_list) = split /\t/, $line;
  if (!defined $border_list || $border_list eq '') {
    next;
  }
  if (!exists $pop_map{$country}) {
    print STDERR "Source does not exist in population map: $country\n";
    next;
  }
  # TODO: Split the border stuff
  next unless defined $border_list && $border_list ne '';
  my @edges = split /;\s*/, $border_list;

  my $total_border_dist = 0;
  my %edge_map;
  foreach my $edge_str (@edges) {
    #print "EDGE STR: $edge_str\n";
    if ($edge_str =~ /(.*) ([\d,.]+) (km)/) {
      my ($dest, $dist_str, $unit) = ($1, $2, $3);
      $dist_str =~ s/,//g;
      my $dist = round($dist_str);
      if ($dist <= 0) {
        next;
      }
      if (!exists $pop_map{$dest}) {
        print STDERR "Destination does not exist in population map: $dest\n";
        next;
      }

      # Record total shared land border length.
      $total_border_dist += $dist;
      $edge_map{$dest} = $dist;
    }
  }

  my $commuting_population = $pop_map{$country} * $POPULATION_COMMUTER_FRACTION;
  foreach my $dest (sort keys %edge_map) {
    my $border_dist = $edge_map{$dest};
    my $border_frac = $border_dist / $total_border_dist;
    my $daily_edge_pop = round($commuting_population * $border_frac);
    print join("\t", $country, $dest, $daily_edge_pop), "\n";
  }
}
close FILE or die $!;

exit 0;
