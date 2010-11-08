package Sophie::Model::Base;

use strict;
use base 'Sophie::Base';
use base 'Catalyst::Model';

sub new {
    my ($class) = @_;
    bless($class->connect, $class);
}

=head1 NAME

Sophie::Model::Base - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Sophie>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Sophie::Base>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.43

=head1 AUTHOR

Olivier Thauvin

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
