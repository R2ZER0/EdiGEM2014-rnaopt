use strict;
use warnings;

$| = 1;

use RNAOpt::RNAfold::Worker;
use RNAOpt::Runner;


my @sequences = <>;
chomp @sequences;

my $worker = RNAOpt::RNAfold::Worker->new();

my $runner = RNAOpt::Runner->new(
    rnafold_worker => $worker,
    tagged_sequences => \@sequences,
);

my $results = $runner->results;

#print $results->[0];