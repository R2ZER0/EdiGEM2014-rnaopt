package RNAOpt::Runner;
use namespace::autoclean;
use Moose;

use RNAOpt::TaggedResult;

has rnafold_worker => ( is => 'ro', isa => 'RNAOpt::RNAfold::Worker', required => 1 );
has tagged_sequences => ( is => 'ro', isa => 'ArrayRef[Str]', required => 1 );
has hook => ( is => 'ro' );

has results => (
    is => 'ro',
    isa => 'ArrayRef[RNAOpt::TaggedResult]',
    lazy => 1,
    builder => "_build_results",
);

sub _build_results {
    my $self = shift;
    
    my @results = ();
    
    foreach my $seq (@{ $self->tagged_sequences }) {
        my $raw_seq = $seq;
        $raw_seq =~ s/[<>\[\]]//g; # Remove tags
        
        push @results, $self->_tag_result(
            $seq,
            $self->rnafold_worker->get_result( $raw_seq )
        );
    }
    
    return \@results;
    
};

# Helper methods
sub _tag_result {
    my ($self, $tagged_seq, $result) = @_;
    
    my $tagged_result = RNAOpt::TaggedResult->new(
        # From raw folding output
        sequence_raw => $result->sequence_raw,
        structure_mfe => $result->structure_mfe,
        structure_centroid => $result->structure_centroid,
        mfe => $result->mfe,
        # Tagging!
        sequence_tagged => $tagged_seq,
        # Everything is auto-calculated... how fun!
    );
    
    if (defined $self->hook) {
        &{ $self->hook() }($result);
    }
    
    return $tagged_result;
}

__PACKAGE__->meta->make_immutable;
1;

