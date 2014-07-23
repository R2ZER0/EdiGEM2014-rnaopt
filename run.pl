use strict;
use warnings;

use RNAOpt::RNAfold::Worker;
use RNAOpt::Runner;

my @sequences;
while(<>) {
    push @sequences, chomp($_);
}


my $worker = RNAOpt::RNAfold::Worker->new();

my $runner = RNAOpt::Runner->new(
    rnafold_runner => $runner,
    tagged_sequences => \@sequences,
);

my $results = $runner->results;

print $results->[0];