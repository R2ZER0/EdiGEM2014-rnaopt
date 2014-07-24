use strict;
use warnings;

$| = 1;

use RNAOpt::RNAfold::Worker;
use RNAOpt::Runner;
use JSON;
use GD::Image;
use Template;
use IPC::Open3;

my $RELPLOT = 'perl /usr/local/share/ViennaRNA/bin/relplot.pl';
my $RNAPLOT = 'RNAplot -t1';

open(ANTISENSE, '<', 'antisense.txt') or die 'No antisense.txt!';

my @sequences = <ANTISENSE>;
chomp @sequences;

# not a nice way but it works
@sequences = map(uc, @sequences);
foreach(@sequences) { s/[^ACGU<>\[\]]//g; }


my $worker = RNAOpt::RNAfold::Worker->new();

my $runner = RNAOpt::Runner->new(
    rnafold_worker => $worker,
    tagged_sequences => \@sequences,
);

my $results = $runner->results;

my @sorted_results = sort { ($b->region_clear_ratio_centroid + $b->region_clear_ratio_mfe) cmp ($a->region_clear_ratio_centroid + $a->region_clear_ratio_mfe) } @{$results}; 

# Generate the report
my $template_html = <<"ENDHTML";
<!DOCTYPE html>
<html>
    <head>
        <title>Results!</title>
        <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
        <style>
            .seq { font-size: 9px; }
            .region { background-color: #AAF; }
            .site { background-color: #F88; }
        </style>
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12">
                    <h1>Report for [% title %]</h1>
                </div>
            </div>
            [% FOREACH result IN results %]
                <div class="row">
                    <div class="col-xs-12">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Rank</th>
                                    <th>MFE</th>
                                    <th>Region Clarity (MFE)</th>
                                    <th>Region Clarity (Centroid)</th>
                                    <th>Site Clear? (MFE)</th>
                                    <th>Site Clear? (Centroid)</th>
                                    <th>Length</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>[% result.rank %]</td>
                                    <td>[% result.mfe %] kcal/mol</td>
                                    <td>[% result.region_clarity_mfe %]%</td>
                                    <td>[% result.region_clarity_centroid %]%</td>
                                    <td>[% result.site_clear_mfe %]</td>
                                    <td>[% result.site_clear_centroid %]</td>
                                    <td>[% result.length %]</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-xs-12">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Sequence / Structure (MFE) / Structure (Centroid)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><samp class="seq">[% result.sequence_l %]<span class="region">[% result.sequence_rl %]<span class="site">[% result.sequence_s %]</span>[% result.sequence_rr %]</span>[% result.sequence_r %]</td>
                                </tr>
                                <tr>
                                    <td><samp class="seq">[% result.structure_mfe_l %]<span class="region">[% result.structure_mfe_rl %]<span class="site">[% result.structure_mfe_s %]</span>[% result.structure_mfe_rr %]</span>[% result.structure_mfe_r %]</td>
                                </tr>
                                <tr>
                                    <td><samp class="seq">[% result.structure_centroid_l %]<span class="region">[% result.structure_centroid_rl %]<span class="site">[% result.structure_centroid_s %]</span>[% result.structure_centroid_rr %]</span>[% result.structure_centroid_r %]</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="col-xs-12 col-md-6">
                        MFE:
                        <img class="img-responsive" src="[% result.image_path_mfe %]"></img>
                    </div>
                    <div class="col-xs-12 col-md-6">
                        Centroid:
                        <img class="img-responsive" src="[% result.image_path_centroid %]"></img>
                    </div>
                </div>
            [% END %]
        </div>
        <script src="http://code.jquery.com/jquery-2.1.1.min.js"></script>
        <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
    </body>
</html>
ENDHTML

sub generate_result_view_hash {
    my $rank = shift;
    my $result = shift;
    my %view = ();
    
    $view{rank} = $rank;
    $view{mfe} = $result->mfe;
    $view{region_clarity_mfe} = sprintf '%.1f', $result->region_clear_ratio_mfe()*100.0;
    $view{region_clarity_centroid} = sprintf '%.1f', $result->region_clear_ratio_centroid()*100.0;
    $view{site_clear_mfe} = $result->site_clear_mfe ? 'Yes' : 'No';
    $view{site_clear_centroid} = $result->site_clear_centroid ? 'Yes' : 'No';
    $view{'length'} = length $result->sequence_raw;
    
    
    sub areas {
        my $result = shift;
        my $s = shift;
        my ($rf, $rl, $sf, $sl) = ($result->region_first, $result->region_last, $result->site_first, $result->site_last);
        my @res = (
            substr($s, 0, $rf),
            substr($s, $rf, $sf - $rf),
            substr($s, $sf, $sl + 1 - $sf),
            substr($s, $sl + 1, $rl - $sl),
            substr($s, $rl + 1),
        );
        return \@res;
    }
    
    @view{('sequence_l', 'sequence_rl', 'sequence_s', 'sequence_rr', 'sequence_r')} = @{ areas($result, $result->sequence_raw) };
    @view{('structure_mfe_l', 'structure_mfe_rl', 'structure_mfe_s', 'structure_mfe_rr', 'structure_mfe_r')} = @{ areas($result, $result->structure_mfe) };
    @view{('structure_centroid_l', 'structure_centroid_rl', 'structure_centroid_s', 'structure_centroid_rr', 'structure_centroid_r')} = @{ areas($result, $result->structure_centroid) };
    
    $view{image_path_mfe} = 'img/'.$rank.'_mfe.png';
    $view{image_path_centroid} = 'img/'.$rank.'_centroid.png';
    
    return \%view;
};

sub generate_plots {
    my $rank = shift;
    my $result = shift;
    
    my ($in, $out);
    open3($in, $out, $out, $RNAPLOT);
    
    if( -e 'rna.ps' ) { unlink 'rna.ps'; }
    if( -e 'dot.ps' ) { unlink 'dot.ps'; }
    
    # First for the MFE plot
    $in->print($result->structure_mfe . "\n"); 
}

open(INDEXFILE, '>', 'index.html');
mkdir './img';

my $template = Template->new();
my $output = '';

my @results_for_display = ();
foreach my $rank (0..19) {
    push @results_for_display, generate_result_view_hash($rank, $sorted_results[$rank]);
}

$template->process(
    \$template_html,
    { 'results' => \@results_for_display, 'title' => $ARGV[0]},
    \$output,
) || die $template->error();

print INDEXFILE $output;


