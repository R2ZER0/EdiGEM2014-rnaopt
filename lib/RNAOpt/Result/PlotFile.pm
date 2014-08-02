package RNAOpt::Result::PlotFile;

use File::Temp qw( tempdir );
use File::Copy;
use File::Spec;

use Moo;
use namespace::clean;

# structure or dot
has 'plot_type' => (
    is => 'ro',
    isa => sub { die 'Unknown plot type!' unless ($_[0] eq 'structure' || $_[0] eq 'dot') },
);

# mfe or centroid
has 'simulation_type' => (
    is => 'ro',
    isa => sub { die 'Unknown simulation type!' unless ($_[0] eq 'mfe' || $_[0] eq 'centroid') },
);

has 'existing_filepath' => (
    is => 'ro',
    required => 1,
    reader => '_existing_filepath',
);

has 'filename' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my ($fvol, $fdir, $fname) = File::Spec->splitpath( $self->_existing_filename );
        return $fname;
    },
);

has 'tmpdir' => (
    is => 'ro',
    lazy => 1,
    default => sub { tempdir( TMPDIR => 1, CLEANUP => 1 ) },
);

has 'filepath' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return File::Spec->cat( $self->tmpdir, $self->filename );
    },
);

sub BUILD {
    my $self = shift;

    move($self->_existing_, $self->tmpdir);    
};

1;