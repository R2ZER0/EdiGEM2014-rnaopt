package RNAOpt::TaggedResult;
use namespace::autoclean;
use Moose;
extends 'RNAOpt::RNAfold::Result';
    
subtype 'TaggedRNASeq'
    as 'Str',
    where { /^[ACGU]+\[[ACGU]*(<[ACGU]+>)?[ACGU]*\][ACGU]+$/ },
    message { "This does not look like a tagged RNA sequence! : $_" };

has 'sequence_tagged' => ( is => 'ro', isa => 'TaggedRNASeq' );

# Ribosome binding region
has 'region_first' => ( is => 'ro', isa => 'Int',
                        default => sub { index($_[0]->sequence_tagged(), '[') } );
has 'region_last'  => ( is => 'ro', isa => 'Int',
                        default => sub { index($_[0]->sequence_tagged(), ']') - 3 } );

#Ribosome binding site
has 'site_first' => ( is => 'ro', isa => 'Int',
                      default => sub { index($_[0]->sequence_tagged(), '<') - 1 } );
has 'site_last'  => ( is => 'ro', isa => 'Int',
                      default => sub { index($_[0]->sequence_tagged(), '>') - 2 } );


__PACKAGE__->meta->make_immutable;
1;