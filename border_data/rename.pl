#!/usr/bin/perl
use strict;
use warnings;

# Clean up the country names in the CIA data.
while (<>) {
  s/Democratic Republic of the Congo/Congo, Democratic Republic of the/g;
  s/Republic of the Congo/Congo, Republic of the/g;
  s/North Korea/Korea, North/g;
  s/South Korea/Korea, South/g;
  s/French Guiana/Guyana/g;
  s/UK/United Kingdom/g;
  s/US/United States/g;
  s/The Gambia/Gambia, The/g;

  print;
}
