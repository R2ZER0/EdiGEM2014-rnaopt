package RNAOpt::Runner;
use namespace::autoclean;
use Moose;

has rnafold_worker => ( is => 'ro', isa => 'RNAOpt::RNAfold::Worker' );
has tagged_sequences => ( is => 'ro', isa => 'ArrayRef[Str]' );

has results => (
    is => 'ro',
    isa => 'ArrayRef[RNAOpt::TaggedResult]',
    lazy => 1,
    builder => "_build_results",
);

sub _build_results {
    my $self = shift;
    
    
};

# Helper methods
sub _tag_result {
    my ($self, $tagged_seq, $result) = @_;
    
    return RNAOpt::TaggedResult->new(
        
    );
}

1;

