#!/usr/bin/perl
use strict;
use warnings;

# reweights dollar values of records in trade-simpler.csv format based on the
# latest total exports data from the CIA world factbook.

use constant YEAR => 0;
use constant FROM_ID => 1;
use constant FROM_NAME => 2;
use constant FROM_SYM => 3;
use constant TO_ID => 4;
use constant TO_NAME => 5;
use constant TO_SYM => 6;
use constant DOLLARS => 7;

my %total_exports = ();

# Reweights export values according to the latest dollar value from the CIA world factbook.
# We assume that exports have retained their distribution by country over time.
# Once the reweighting is done, the records are printed to stdout.
sub process_records($@) {
  defined(my $name = shift) or die;
  my @records = @_ or die;

  my $old_total = 0;
  foreach my $rec (@records) {
    $old_total += $rec->[DOLLARS];
  }

  if (!exists $total_exports{$name}) {
    die "Cannot find total exports for $name";
  }
  my $new_total = $total_exports{$name};
  my $weight = $new_total / $old_total;

  foreach my $rec (@records) {
    $rec->[DOLLARS] = int($rec->[DOLLARS] * $weight);
    print join("\t", @$rec), "\n";
  }
}

# Pull in the CIA world factbook total exports data.
my $total_exports_file = "cia_world_factbook_exports.tsv";
open(FILE, "< $total_exports_file") or die $!;
while (defined(my $line = <FILE>)) {
  # 1	China	$    2,210,000,000,000
  chomp $line;
  my ($rank, $name, $formatted_dollars) = split(/\t/, $line);
  $formatted_dollars =~ s/^\$\s*//; # strip dollar sign
  $formatted_dollars =~ s/,//g;     # strip commas
  my $dollars = int($formatted_dollars);
  $total_exports{$name} = $dollars;
}
close FILE;

# Reweight the data based on the CIA world factbook totals.
my $cur_name = "";
my @cur_records = ();
while (defined(my $input = <>)) {
  chomp $input;
  # 2010	104	Myanmar	MMR	376	Israel	ISR	1231
  my @f = split(/\t/, $input);
  if ($f[FROM_NAME] ne $cur_name) {
    if ($cur_name ne '') {
      process_records($cur_name, @cur_records);
    }
    $cur_name = $f[FROM_NAME];
    @cur_records = ();
  }
  push @cur_records, \@f;
}
process_records($cur_name, @cur_records);

exit 0;
