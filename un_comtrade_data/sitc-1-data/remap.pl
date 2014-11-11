#!/usr/bin/perl
use strict;
use warnings;

my $remappings_file = "remappings.list";
my $redactions_file = "redactions.regex";

open(FILE, "< $remappings_file") or die $!;
my @remappings_raw = <FILE>;
chomp @remappings_raw;
close FILE;

# stuff to redact
my %redact = ();

# Not countries.
$redact{"WLD"} = 1; # World
$redact{"EU2"} = 1; # European Union

# No longer a state.
$redact{"PCI"} = 1; # Pacific Islands
$redact{"DDR"} = 1; # East Germany

# Not in CIA world factbook.
$redact{"BRN"} = 1;
$redact{"GUF"} = 1;
$redact{"GLP"} = 1;
$redact{"MTQ"} = 1;
$redact{"MYT"} = 1;
$redact{"ANT"} = 1;
$redact{"REU"} = 1;

# build up a map of from -> to IDs and index the data lines by ID also.
my %remap = ();
my %remap_data = ();
foreach my $line (@remappings_raw) {
  # 810	Fmr USSR	SUN=>643	Russian Federation	RUS
  my ($from, $to) = split(/=>/, $line);
  my ($from_id, $blah1) = split(/\t/, $from, 2);
  my ($to_id, $blah2) = split(/\t/, $to, 2);
  $remap{$from_id} = $to_id;
  $remap_data{$to_id} = $to;
}

#use Data::Dumper qw(Dumper);
#print Dumper(\%remap);
#print Dumper(\%remap_data);
#exit 0;

while (defined(my $input = <>)) {
  chomp $input;
  # 2010	104	Myanmar	MMR	376	Israel	ISR	1231
  my ($year, $from_id, $from_name, $from_sym, $to_id, $to_name, $to_sym, $dollars) = split(/\t/, $input);
  if (exists $remap{$from_id} || $from_sym eq '' || $to_sym eq '' || exists $redact{$from_sym} || exists $redact{$to_sym}) {
    # Skip entries originating from countries that have been remapped.
    # Also skip entries to places that don't have a symbol (generally vague regions or continents).
    # Also skip entries to stuff we want to redact (see above list).
    next;
  } elsif (exists $remap{$to_id}) {
    my $remapped_id = $remap{$to_id};
    my $remapped_entry = $remap_data{$remapped_id};
    print join("\t", ($year, $from_id, $from_name, $from_sym, $remapped_entry, $dollars)), "\n";
  } else {
    print $input, "\n";
  }
}

exit 0;
