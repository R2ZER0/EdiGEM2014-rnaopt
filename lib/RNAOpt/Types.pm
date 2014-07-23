package RNAOpt::Types;

use MooseX::Types -declare => [
    qw(
        RNASeq
        TaggedRNASeq
        Structure
    )
];

use MooseX::Types::Moose qw/Str/;

subtype RNASeq,
    as Str,
    where { /^[ACGU]+$/ },
    message { "This does not look like an (untagged) RNA sequence! : $_" };
    
subtype TaggedRNASeq,
    as Str,
    where { /^[ACGU]+\[[ACGU]*(<[ACGU]+>)?[ACGU]*\][ACGU]+$/ },
    message { "This does not look like a tagged RNA sequence! : $_" };

    
subtype Structure,
    as Str,
    where { /^[.()]+$/ },
    message { "This does not look like a structure! : $_" };

    