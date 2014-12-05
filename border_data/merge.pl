#!/usr/bin/perl
#####################################################################################
# This script expects as input a list of files that all conform to the following
# TSV schema: Source \t Destination \t Number
# They will be summed and outputted in sorted order.
#####################################################################################
use strict;
use warnings;

sub normalize($) {
  my $country = shift or die;
  $country =~ s/Lao People's Dem\. Rep\./Laos/;
  $country =~ s/Vatican City State/Vatican City/;
  $country =~ s/Saint Maarten/Sint Maarten/;
  return $country;
}

sub blacklisted($) {
  my $country = shift or die;
  if ($country =~ /European Union|World/) {
    return 1;
  }
  return 0;
}

my %sources;
while (@ARGV) {
  my $file = shift @ARGV;
  open (FILE, "< $file") or die "Cannot open file $file for read: $!";
  while (defined(my $line = <FILE>)) {
    chomp $line;
    my ($source, $dest, $num) = split /\t/, $line;

    $source = normalize($source);
    $dest = normalize($dest);

    next if blacklisted($source);
    next if blacklisted($dest);

    if (!exists $sources{$source}) {
      $sources{$source} = {};
    }
    if (!exists $sources{$source}->{$dest}) {
      $sources{$source}->{$dest} = 0;
    }
    $sources{$source}->{$dest} += $num;
  }
  close FILE or die "Cannot close file $file: $!";
}

foreach my $source (sort keys %sources) {
  foreach my $dest (sort keys %{$sources{$source}}) {
    my $num = $sources{$source}->{$dest};
    print join("\t", $source, $dest, $num), "\n";
  }
}
