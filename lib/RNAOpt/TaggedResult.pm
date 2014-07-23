package RNAOpt::TaggedResult;
use namespace::autoclean;
use Moose;
extends 'RNAOpt::RNAfold::Result';

use RNAOpt::Types qw( TaggedRNASeq );

has 'sequence_tagged' => ( is => 'ro', isa => TaggedRNASeq );

# Ribosome binding region
has 'region_first' => (
    is => 'ro', isa => 'Int',
    default => sub {
        my $self = shift;
        
        return index($self->sequence_tagged(), '[');
    },
);

has 'region_last' => (
    is => 'ro', isa => 'Int',
    default => sub {
        my $self = shift;
    ( is => 'ro', isa => 'Bool', lazy => 1, default =>
                        sub { 
                            my $self = shift;
        return index($self->sequence_tagged(), ']') - 3;
    },
);

#Ribosome binding site
has 'site_first' => (
    is => 'ro', isa => 'Int',
    default => sub {
        my $self = shift;
        
        return index($self->sequence_tagged(), '<') - 1;
    },
);
    
has 'site_last'  => (
    is => 'ro', isa => 'Int',
    default => sub {
        my $self = shift;
        
        return index($self->sequence_tagged(), '>') - 2
    },
);

# Useful information to filter & optimise on
has 'site_clear_mfe' => (
    is => 'ro', isa => 'Bool',
    default => sub {
        my $self = shift;
        
        return $self->_check_site_clear($self->structure_mfe);
    },
);

has 'region_clear_ratio_mfe' => (
    is => 'ro', isa => 'Num', lazy => 1
    default => sub {
        my $self = shift;
        
        return $self->_calc_region_clear_ratio($self->structure_mfe);
    }
);

has 'site_clear_centroid' => (
    is => 'ro', isa => 'Bool',
    default => sub {
        my $self = shift;
        
        return $self->_check_site_clear($self->structure_centroid);
    },
);

has 'region_clear_ratio_centroid' => (
    is => 'ro', isa => 'Num', lazy => 1
    default => sub {
        my $self = shift;
        
        return $self->_calc_region_clear_ratio($self->structure_centroid);
    }
);

# Is the binding site free from folding?
sub _check_site_clear {
    my $self = shift;
    my $structure = shift;
    
    my $clear = 1;
    foreach my $i ($self->site_first .. $self->site_last) {
        if($structure[$i] ne '.') {
            $clear = 0;
            last;
        }
    }
    
    return $clear;
}

# What % of the region is free from folding
sub _calc_region_clear_ratio {
    my $self = shift;
    my $structure = shift;
    
    my $region_length = $self->region_last - $self->region_first;
    my $region_clear_nts = $region_length;
    
    foreach my $i ($self->region_first .. $self->region_last) {
        if($structure[$i] ne '.') {
            $region_clear_nts = $region_clear_nts - 1;
        }
    }
    
    return $region_clear_nts/$region_length;
}

__PACKAGE__->meta->make_immutable;
1;