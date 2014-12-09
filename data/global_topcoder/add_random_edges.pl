#!/usr/bin/perl
########################################################################
# Add specified number of random edges between two countries
########################################################################
use strict;
use warnings;

my $country_numbering_file = 'country_nodes_start_size.dat';
my $edges_file = 'daily_migrants_total.tsv';

my %country_info;
open(FILE, "< $country_numbering_file") or die $!;
my @lines = <FILE>;
close FILE;
chomp @lines;
foreach my $line (@lines) {
  my ($country, $start, $size) = split /\t/, $line;
  $country_info{$country} = { start => int($start), size => int($size) };
}

my %ignored_countries;

open(FILE, "< $edges_file") or die $!;
while (defined(my $line = <FILE>)) {
  chomp $line;
  my ($src, $dst, $connections) = split /\t/, $line;
  next if $connections == 0;
  next if exists $ignored_countries{$src};
  next if exists $ignored_countries{$dst};

  if (!exists $country_info{$src}) {
    print STDERR "No country info for $src\n";
    $ignored_countries{$src} = 1;
    next;
  }
  if (!exists $country_info{$dst}) {
    print STDERR "No country info for $dst\n";
    $ignored_countries{$dst} = 1;
    next;
  }
  if ($connections > $country_info{$src}{size}) {
    print STDERR "Number of edges between $src and $dst ($connections) exceeds population of $src: " . $country_info{$src}{size} . "\n";
    next;
  }
  if ($connections > $country_info{$dst}{size}) {
    print STDERR "Number of edges between $dst and $src ($connections) exceeds population of $dst " . $country_info{$dst}{size} . "\n";
    next;
  }

  print STDERR "Generating $connections edges between $src & $dst...\n";

  # Output the edges.
  my %seen;
  my $num_generated_edges = 0;
  while ($num_generated_edges < $connections) {
    my $src_node = int(rand($country_info{$src}{size})) + $country_info{$src}{start};
    next if exists $seen{$src_node};
    my $dst_node = int(rand($country_info{$dst}{size})) + $country_info{$dst}{start};
    next if exists $seen{$dst_node};
    $seen{$src_node} = 1;
    $seen{$dst_node} = 1;
    print $src_node, "\t", $dst_node, "\n";
    $num_generated_edges++;
  }
}
close FILE;
