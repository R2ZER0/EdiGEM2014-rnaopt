package RNAOpt::Runner;
use namespace::autoclean;
use Moose;

has rnafold_worker => ( is => 'ro', isa => 'RNAOpt::RNAfold::Worker', required => 1 );
has tagged_sequences => ( is => 'ro', isa => 'ArrayRef[Str]', required => 1 );

has results => (
    is => 'ro',
    isa => 'ArrayRef[RNAOpt::TaggedResult]',
    lazy => 1,
    builder => "_build_results",
);

sub _build_results {
    my $self = shift;
    
    print "building results\n";
    
    my @results = ();
    
    foreach my $seq (@{ $self->tagged_sequences }) {
        my $raw_seq = $seq;
        $raw_seq =~ s/<>\[\]//g; # Remove tags
        print "$seq";
        
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
    
    return RNAOpt::TaggedResult->new(
        # From raw folding output
        sequence_raw => $result->sequence_raw,
        structure_mfe => $result->structure_mfe,
        structure_centroid => $result->structure_centroid,
        mfe => $result->mfe,
        # Tagging!
        sequence_tagged => $tagged_seq,
        # Everything is auto-calculated... how fun!
    );
}

__PACKAGE__->meta->make_immutable;
1;

