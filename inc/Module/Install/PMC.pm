#line 1
package Module::Install::PMC;

use strict;
use Module::Install::Base 0.61;
use File::Basename ();

use vars qw{$VERSION @ISA};
BEGIN {
	$VERSION = '0.61';
	@ISA     = qw{Module::Install::Base};
}

# Add support on the installer's side to make sure all pmcs have mtime >
# mtime of .pms.
sub pmc_support {
    my $self = shift;
    require File::Find;

    my $postamble = '';

    # This will generate all the .pmcs on the author side.
    $self->admin->pmc_support
        if $self->is_admin;

    my @pmcs = glob('*.pmc');
    File::Find::find( sub {
        push @pmcs, $File::Find::name if /\.pmc$/i;
    }, 'lib');

    $self->realclean_files("@pmcs");

    $postamble .= "\nconfig :: ".join(" ",@pmcs)."\n\n";

    for my $pmc (@pmcs) {
        my $pm = $pmc;
        chop($pm);
        $postamble .= <<".";
$pmc: $pm
\t-\$(NOECHO) \$(CHMOD) 644 $pmc
\t-\$(NOECHO) \$(TOUCH) $pmc

.
    }

    $self->postamble($postamble)
        if @pmcs;
}

1;

__END__

#line 92
