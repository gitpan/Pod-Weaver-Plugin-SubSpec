package Pod::Weaver::Plugin::SubSpec;
BEGIN {
  $Pod::Weaver::Plugin::SubSpec::VERSION = '0.05';
}
# ABSTRACT: Insert POD for subs from spec

use 5.010;
use Moose;
with 'Pod::Weaver::Role::Section';

use Log::Any '$log';

use Pod::Elemental;
use Pod::Elemental::Element::Nested;
use Sub::Spec::To::Pod qw(gen_module_subs_pod);


sub weave_section {
    $log->trace("-> ".__PACKAGE__."::weave_section()");
    my ($self, $document, $input) = @_;

    my $filename = $input->{filename} || 'file';

    # guess package name from filename
    my $package;
    if ($filename =~ m!^lib/(.+)\.pm$!) {
        $package = $1;
        $package =~ s!/!::!g;
    } else {
        #$self->log(["skipped file %s (not a Perl module)", $filename]);
        $log->debugf("skipped file %s (not a Perl module)", $filename);
        return;
    }

    unshift @INC, "lib" unless 'lib' =~ @INC;

    # find the FUNCTIONS section in the POD
    my $funcs_section;
    for my $i (0 .. $#{ $input->{pod_document}->children }) {
        my $para = $input->{pod_document}->children->[$i];
        next unless $para->isa('Pod::Elemental::Element::Nested') &&
            $para->command eq 'head1' && $para->content =~ /^FUNCTIONS$/s;
        $funcs_section = $para;
        last;
    }
    unless ($funcs_section) {
        $self->log(["skipped file %s (no =head1 FUNCTIONS)", $filename]);
        $log->debugf("skipped file %s (no =head1 FUNCTIONS)");
        return;
    }

    # generate the POD and insert it to FUNCTIONS section
    my $pod_text = gen_module_subs_pod(module=>$package, path=>$filename);
    while ($pod_text =~ /^=head2 ([^\n]+)\n(.+?)(?=^=head2|\z)/msg) {
        my $fpara = Pod::Elemental::Element::Nested->new({
            command  => 'head2',
            content  => $1,
            children => Pod::Elemental->read_string($2)->children,
        });
        $self->log(["adding spec POD for %s", $filename]);
        $log->infof("adding spec POD for %s", $filename);
        push @{ $funcs_section->children }, $fpara;
    }
    $log->trace("<- ".__PACKAGE__."::weave_section()");
}

1;


=pod

=head1 NAME

Pod::Weaver::Plugin::SubSpec - Insert POD for subs from spec

=head1 VERSION

version 0.05

=head1 SYNOPSIS

In your C<weaver.ini>:

 [-SubSpec]

=head1 DESCRIPTION

This plugin inserts POD documentation (generated by L<Sub::Spec::To::Pod>) at
the end of the C<=head1 FUNCTIONS> section. That section must already exist, or
the file will be skipped.

=for Pod::Coverage weave_section

=head1 SEE ALSO

L<Sub::Spec::To::Pod>

L<Sub::Spec>

L<Pod::Weaver>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

