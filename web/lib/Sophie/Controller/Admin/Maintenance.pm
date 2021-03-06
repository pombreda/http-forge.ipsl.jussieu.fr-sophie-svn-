package Sophie::Controller::Admin::Maintenance;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Sophie::Controller::Admin::Maintenance - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub begin : Private {
    my ($self, $c) = @_;

    if ($c->req->address eq '127.0.0.1' || $c->req->address eq '::1') {
    } else {
        $c->forward('/admin/begin')
    }

    $c->forward('/begin');
}

sub tasks : XMLRPC {
    my ($self, $c) = @_;

    $c->stash->{xmlrpc} = [ qw(
        admin.maintenance.delete_expired_sessions
        admin.maintenance.delete_expired_paste
        admin.maintenance.delete_old_chat_statistics
    ) ];
}

sub delete_expired_sessions :XMLRPC {
    my ($self, $c) = @_;

    $c->delete_expired_sessions;

    $c->stash->{xmlrpc} = 'Done';
}

sub delete_expired_paste :XMLRPC {
    my ($self, $c) = @_;
    $c->model('Base::ChatPaste')->search({
            -nest => \[
            "whenpaste < now() - ?::interval",
            [ plain_text => "30 days" ],
        ]
    })->delete;
    $c->model('Base')->storage->sth->commit;
    $c->stash->{xmlrpc} = 'Done';
}

sub delete_old_chat_statistics :XMLRPC {
    my ($self, $c) = @_;
    $c->model('Base::ChatStat')->search(
        {
            -nest => \[
            "day < now() - ?::interval",
            [ plain_text => "365 days" ],
        ],
        }
    )->delete;
    $c->model('Base')->storage->sth->commit;
    $c->stash->{xmlrpc} = 'Done';
}

=head1 AUTHOR

Olivier Thauvin

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
