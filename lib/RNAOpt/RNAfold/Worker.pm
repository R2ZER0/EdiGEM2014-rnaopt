package RNAOpt::RNAfold::Worker;
use namespace::autoclean;
use Moose;

use IPC::Open3;
use IO::Handle;
use RNAOpt::RNAfold::Result;

has '_in'  => ( is => 'rw', isa => 'Maybe[IO::Handle]' );
has '_out' => ( is => 'rw', isa => 'Maybe[IO::Handle]' );
has '_pid' => ( is => 'rw', isa => 'Maybe[Int]' );

sub BUILD {
    my $self = shift;
    
    my ($in, $out);
    my $pid = open3($in, $out, $out, 'RNAfold', '-p', '-d2', '--noLP');
    
    $self->_in(  IO::Handle->new_from_fd(fileno($in ), 'w') );
    $self->_out( IO::Handle->new_from_fd(fileno($out), 'r') );
    $self->_pid( $pid );
    
    print "Got worker $pid \n"
};

sub get_result {
    my $self = shift;
    my $sequence = shift;
    
    print "Sending $sequence \n\n";
    $self->_in->print($sequence."\n");
    my @lines;
    foreach (0..4) { print "x"; push @lines, $self->_out->getline; print 'X'; }
    
    print "\n\nGetting result\n\n";
    
    
    my ($sequence_out, $structure_mfe, $structure_centroid, $mfe);
    
    #   Example RNAfold output:
    # 0: UUUGGAUGAUGUCUUCGAUCUGAUCUGAAUCGAC
    # 1: ...((((...))))((((((......)).)))). ( -3.80)
    # 2: ...{(({...}}},{(((((......),,)))). [ -5.08]
    # 3: ..............((((.(......)..)))). { -1.00 d=6.26}
    # 4: frequency of mfe structure in ensemble 0.12451; ensemble diversity 9.22
    
    if($lines[0] =~ m/([UGAC]+)/) {
        $sequence_out = $1;
    } else { die "Cannot unpack sequence from output!"; }
    
    if($lines[1] =~ m/([\.()]+)\s*\(\s*(-?[\.\d,]+)\s*\)\s*/) {
        $structure_mfe = $1;
        $mfe = $2;
    } else { die "Cannot unpack MFE/structure!"; }
    
    if($lines[3] =~ m/([\.()]+)/) {
        $structure_centroid = $1;
    } else { die "Cannot unpack centroid structure!"; }
    
    return RNAOpt::RNAfold::Result->new(
        sequence_raw => $sequence_out,
        structure_mfe => $structure_mfe,
        structure_centroid => $structure_centroid,
        mfe => $mfe,
    );
};

sub done {
    my $self = shift;
    
    $self->_in->print("@\n");
    waitpid $self->_pid, 0;
    
    $self->_in( undef );
    $self->_out( undef );
    $self->_pid( undef );
};

sub DEMOLISH {
    my $self = shift;
    $self->done;
}

__PACKAGE__->meta->make_immutable;
1;