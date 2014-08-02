package RNAOpt::ResultFile;

use File::Temp qw( tempdir );
use File::Copy;

use Moo;
use namespace::clean;

has 'filename' => (
    is => 'ro',
    required => 1,
);

has 'tmpdir' => (
    is => 'ro',
    lazy => 1,
    default => sub { tempdir( TMPDIR => 1, CLEANUP => 1 ) };
);

sub filepath {
    my $self = shift;
    return $self->tmpdir . '/' . $self->filename;
};


sub BUILD {
    my $self = shift;
    
    copy(
};

1;