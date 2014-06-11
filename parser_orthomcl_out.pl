#!/usr/bin/perl

#===============================================================================
#
#         FILE: x.pl
#
#        USAGE: ./x.pl
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Ousmane CissÃ© (oc), OusmaneHamadoun.Cisse@unil
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 28.09.2012 21:58:58
#     REVISION: ---
#===============================================================================

use warnings;
use Carp;
use Getopt::Long;
#use Scalar::Util qw< looks_like_number >;

#use IO::Prompt;
#use Perl6::Slurp;
#use Perl6::Say;
#use Smart::Comments;
#use Method::Signatures;
#use Moose::Error::Croak;

# Implementation here
#if (@ARGV < 1) { Usage(); }

# $Id$
=head1 NAME
parse Orthologous proteins groups from Orthomcl v.14


=head1 DESCRIPTION
$0 <Orthomcl out> < list of proteomes used for clustering>
read an orthomcl and write the number of proteins per taxa per cluster

=head1 OPTIONS
to be implemented in the future

Input/Output (tbi)

=head1 OUTPUT
tbi

=head1 AUTHORS

Ousmane H. CissÃ©: ousmanecis@gmail.com

=cut

GetOptions(
    'h|help' => sub {exec('perldoc',$0);
        exit(0);},
);

# need a file with the names of all proteomes tested

my ($file, $list_of_proteomes) = @ARGV;

# declare variables
my (%cluster, %compte, %verified_compte,%organism);
my ($cluster_id, $num_of_genes, $num_of_taxa);

# work

%organism = retrieve_original_name($list_of_proteomes);
print_header_for_CAFE_file(%organism);


open (FILE, $file) || die "Can not open $file:$!\n";
while (<FILE>){
chomp;
if(/^ORTHOMCL/){

# read line and return an hash with $hash{protein} = taxon
# the output is one cluster per line
%cluster = extract_taxon_and_number_of_proteins($_);

# extract cluster relevant information

($cluster_id, $num_of_genes, $num_of_taxa) = extract_cluster_info($_);

# count the number of taxon and proteins
(%compte) = count_taxons_and_number_of_proteins(%cluster);

# verify and assign a value of O for species that have no representative in this  cluster

%verified_compte = verify(%compte);
# print report
print_values($cluster_id,%verified_compte);

    }
}

close FILE;


##### SUBs ####
sub verify {
    my (%compte_adjuster) = @_;
    foreach (keys %organism) {
        if ($compte_adjuster{$_}) {
        }
        else {
            #print "$_:is NOT included in the organism list\n";
            $compte_adjuster{$_} = 0;
        }
    }
    return(%compte_adjuster);
}

sub retrieve_original_name {

my ($file) = @_;
my (%orgn) = ();

open FILE, $file || die "Can not open $file:$!\n";
while (<FILE>){
chomp;
$orgn{$_} = 1;
}
return(%orgn);
}

sub Usage {

print<<EOF

$0 <Orthomcl out> < list of proteomes used for clustering>
read an orthomcl and write the number of proteins per taxa per cluster

Ousmane Cissé

EOF
}

sub extract_taxon_and_number_of_proteins {
my ($data) = @_;


# parse orthoMCL output
my %clusters; # $clusters{protein_name}{taxon_label}

my ($cluster, $proteins) = split /:\s+/xms, $data;

#print '-' x 100 ."\n";
#print "$cluster\n";
#print '-' x 100 ."\n";

my @proteins = split /\s/xms, $proteins;

foreach (@proteins){
    my @sep = split /\(/, $_;
    my $protein = $sep[0];
    my $taxon = $sep[1];
    $taxon =~s/\)//;
    $clusters{$protein} = $taxon if $protein;
}
return (%clusters);
close FILE;
}

sub extract_cluster_info {
my ($data) = @_;

# parse orthoMCL output
my %clusters; # $clusters{protein_name}{taxon_label}

my ($cluster, $proteins) = split /:\s+/xms, $data;
my (@line0) = split/:/, $_;
my (@line1) =  split /\(/, $line0[0];
my ($cluster_id) = $line1[0];
my (@line2) = split /,/, $line1[1];
my ($num_of_genes) = $line2[0];
my ($num_of_taxa) = $line2[1];
    $num_of_taxa =~s/\)//;

return ($cluster_id,$num_of_genes,$num_of_taxa);
}

sub count_taxons_and_number_of_proteins {

my (%cluster) = @_;

my (@taxon) = (values %cluster);
my (%compte) = ();
foreach $element (@taxon) {
    $compte{$element}++;
}
return (%compte);
}

sub print_header_for_CAFE_file {
my (%hash_with_taxon_as_keys) = @_;
my ($taxa);

print "FAMILYDESC\tFAMILY\t";
foreach $taxa (sort keys %hash_with_taxon_as_keys) {
print "$taxa\t";
}
print "\n";
}
sub print_values {

my ($clust_id, %compte) = @_;

my ($element);

print "UNKNOWN\t$clust_id\t";  # will add functional annotation of the cluster based on blast later

foreach $element (sort keys %compte){

print "$compte{$element}\t";

}

print "\n";
}

GetOptions(
    'h|help' => sub {exec('perldoc',$0);
        exit(0);},
);


