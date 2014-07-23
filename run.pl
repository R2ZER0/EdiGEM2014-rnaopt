use strict;
use warnings;

$| = 1;

use RNAOpt::RNAfold::Worker;
use RNAOpt::Runner;

my @sequences = <>;
chomp @sequences;

# not a nice way but it works
@sequences = map(uc, @sequences);
foreach(@sequences) { s/[^ACGU<>\[\]]//g; }


my $worker = RNAOpt::RNAfold::Worker->new();

my $runner = RNAOpt::Runner->new(
    rnafold_worker => $worker,
    tagged_sequences => \@sequences,
);

my $results = $runner->results;

my @sorted_results = sort { ($b->region_clear_ratio_centroid + $b->region_clear_ratio_mfe) cmp ($a->region_clear_ratio_centroid + $a->region_clear_ratio_mfe) } @{$results}; 

print join("\n", map { $_->freeze } @sorted_results );