#!/usr/bin/perl
use strict;
use warnings;

# Make the UN Comtrade DB look like the CIA world factbook.
while (<>) {
  s/Isds/Islands/g;
  s/Russian Federation/Russia/g;
  s/842	USA	USA/842	United States	USA/g;
  s/Viet Nam/Vietnam/g;
  s/State of Palestine/West Bank/g;
  s/United Rep\. of Tanzania/Tanzania/;
  s/Rep\. of Korea/Korea, South/g;
  s/Bahamas/Bahamas, The/g;
  s/Gambia/Gambia, The/g;
  s/Faeroe Islands/Faroe Islands/g;
  s/Dominican Rep./Dominican Republic/g;
  s/Czech Rep./Czech Republic/g;
  s/Côte d'Ivoire/Cote d'Ivoire/g;
  s/178	Congo	COG/178	Congo, Republic of the	COG/g;
  s/180	Dem\. Rep\. of the Congo	COD/180	Congo, Democratic Republic of the	COD/g;
  s/China, Hong Kong SAR/Hong Kong/g;
  s/China, Macao SAR/Macau/g;
  s/Bosnia Herzegovina/Bosnia and Herzegovina/g;
  s/Bolivia \(Plurinational State of\)/Bolivia/g;
  s/Central African Rep\./Central African Republic/g;
  s/Myanmar/Burma/g;
  s/Rep\. of Moldova/Moldova/g;
  s/TFYR of Macedonia/Macedonia/g;

  print;
}
