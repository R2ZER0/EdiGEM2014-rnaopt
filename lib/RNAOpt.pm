package RNAOpt;

use Cwd qw( getcwd );

use Moo;
use namespace::clean;


has 'report_base' => (
    is => 'ro',
    default => sub { getcwd },
);

has 'antisense_file' => (
    is => 'ro',
    required => 1,
);

