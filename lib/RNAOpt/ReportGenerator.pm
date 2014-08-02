package RNAOpt::ReportGenerator;
use Moo;
use namespace::clean;

# The input files
has 'template_file' => (
    is => 'ro',
    default => sub { 'report_template.html' },
);

has 'results' => (
    is => 'ro',
    required => 1,
);



has 'report' => (
    is => 'lazy',
);

sub _build_report() {

};