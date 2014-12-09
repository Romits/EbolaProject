#!/usr/bin/perl
######################################
use strict;
use warnings;
use Data::Dumper qw(Dumper);

while (defined (my $graph_file = <>)) {
  chomp $graph_file;
  my $meta_file = $graph_file;
  $meta_file =~ s/\.graph$//;
  $meta_file .= ".meta";

  open(GRAPH, "< $graph_file") or die "cannot open graph file: $graph_file: $!";
  open(META, "< $meta_file") or die "cannot open meta file: $meta_file: $!";
  print "Processing file $graph_file...\n";

  chomp(my $meta_hdr = <META>);
  $meta_hdr =~ s/^# //;
  my %header = map { split /: / } split(/; /, $meta_hdr);

  # Start renumbering here.
  my $cur_from_node = 0;
  my $cur_to_node = int($header{"Start"});
  my $num_nodes = int($header{"Size"});
  my $onepast_max_to_node = $cur_to_node + $num_nodes;
  my %remapping = ();

  while (defined(my $deleted_node_str = <META>)) {
    chomp $deleted_node_str;
    my $next_deleted_from_node = int($deleted_node_str);
    while ($cur_from_node < $next_deleted_from_node) {
      $remapping{$cur_from_node++} = $cur_to_node++;
    }
    ++$cur_from_node; # If we get here, it's equal.
  }
  # Now finish up building the remapping.
  while ($cur_from_node < $onepast_max_to_node) {
    $remapping{$cur_from_node++} = $cur_to_node++;
  }
  close META;

  # Now run through and renumber the graph
  my $out_graph_file = "$graph_file.renumbered";
  open(OUT, "> $out_graph_file") or die "cannot open graph file: $out_graph_file: $!";

  my $comment_pat = qr/^#/;
  while (defined(my $line = <GRAPH>)) {
    if ($line =~ $comment_pat) {
      print OUT $line;
      next;
    }
    chomp $line;
    my ($from_str, $to_str) = split(/\t/, $line, 2);
    my $from = $remapping{int($from_str)};
    my $to = $remapping{int($to_str)};
    print OUT "$from\t$to\n" or die "Cannot print to out file $out_graph_file: $!";
  }

  close OUT;
  close GRAPH;
}
