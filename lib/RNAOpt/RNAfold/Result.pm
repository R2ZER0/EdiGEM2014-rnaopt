package RNAOpt::RNAfold::Result;
use namespace::autoclean;
use Moose;

subtype 'RNASeq'
    as 'Str',
    where { /^[ACGU]+$/ },
    message { "This does not look like an (untagged) RNA sequence! : $_" };
    
subtype 'Structure'
    as 'Str',
    where { /^[.()]+$/ },
    message { "This does not look like a structure! : $_" };


has 'sequence_raw' => ( is => 'ro', isa => 'RNASeq' );

has 'structure_mfe' => ( is => 'ro', isa => 'Structure' );
has 'structure_centroid' => ( is => 'ro', isa => 'Structure' );

has 'mfe' => ( is => 'ro', isa => 'Num' );


__PACKAGE__->meta->make_immutable;
1;