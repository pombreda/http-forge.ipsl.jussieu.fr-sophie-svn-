package Sophie::View::TT;

use strict;
use warnings;
use Sophie;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.html',
    render_die => 1,
    INCLUDE_PATH => [
        Sophie->path_to( 'root', 'templates', 'includes' ),
        Sophie->path_to( 'root', 'templates', 'html' ),
    ],
    PRE_PROCESS => 'header.tt',
    POST_PROCESS => 'footer.tt',
    PLUGIN_BASE => 'Sophie::Template::Plugin',
);

=head1 NAME

Sophie::View::TT - TT View for Sophie

=head1 DESCRIPTION

TT View for Sophie.

=head1 SEE ALSO

L<Sophie>

=head1 AUTHOR

Olivier Thauvin

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
