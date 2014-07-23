package RNAOpt::RNAfold::Result;
use namespace::autoclean;
use Moose;

use RNAOpt::Types qw( RNASeq Structure );


has 'sequence_raw' => ( is => 'ro', isa => RNASeq );

has 'structure_mfe' => ( is => 'ro', isa => Structure );
has 'structure_centroid' => ( is => 'ro', isa => Structure );

has 'mfe' => ( is => 'ro', isa => 'Num' );


__PACKAGE__->meta->make_immutable;
1;