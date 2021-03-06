package Sophie::Bot::IRC;

use 5.010000;
use strict;
use warnings;
use base qw(Sophie::Bot);
use POE qw(Component::IRC);

our $VERSION = '0.01';

sub PING_INTERVAL { 60 }
sub NO_PONG_TOUT  { 5  }

sub setup_server {
    my ($self, $server, $nick, $password) = @_;

    if (!$nick) {
        my $resp = $self->send_request('user.fetchdata', $server);
        if (ref $resp) {
            if ($resp->value) {
                $nick = $resp->value->{nick};
            }
        }
    }

    my $irc = POE::Component::IRC->spawn(
        Nick     => $nick,
        Server   => $server,
        Ircname  => 'Rpm2sql',
        Debug    => 1,
    );
 
    POE::Session->create(
        heap => {
            irc => $irc,
            sophie => $self,
            server => $server,
            password => $password,
            nick => $nick,
        },
        package_states => [
            ref($self)  => [ qw(_start irc_001 irc_public irc_msg ping_server
                irc_pong irc_433) ],
        ],
    ); 
}

sub _start {
    my $heap = $_[HEAP];
    my $kernel = $_[KERNEL];
    my $irc = $heap->{irc};

    $irc->yield('register', 'all', '001');
    $irc->yield('connect', { });

    $kernel->delay( 'ping_server' => PING_INTERVAL );
}

sub ping_server {
    my $heap = $_[HEAP];
    my $kernel = $_[KERNEL];
    $heap->{nopong} ||= 0;
    if ($heap->{nopong} >= NO_PONG_TOUT) {
        $_[KERNEL]->stop;
        return;
    }
    $heap->{nopong}++;
    $heap->{irc}->yield( 'ping' => scalar(time()) );
    $kernel->delay( 'ping_server' => PING_INTERVAL );
}

sub irc_pong {
    my $heap = $_[HEAP];
    my $kernel = $_[KERNEL];
    $heap->{nopong} = 0;
}

sub irc_433  {
    my $heap = $_[HEAP];
    my $irc = $heap->{irc};
    my $self = $heap->{sophie};

    warn "Nickname already in use\n";

    my $config = $self->get_var($heap->{server});

    if (my $pass = $config->{password}) {
        $irc->yield('privmsg', 'nickserv', "ghost " . $heap->{nick} . " $pass");
    }

    $_[KERNEL]->stop;
}

sub irc_001 {
    my $heap = $_[HEAP];
    my $irc = $heap->{irc};
    my $self = $heap->{sophie};

    my $config = $self->get_var($heap->{server});

    if (my $pass = $config->{password}) {
        $irc->yield('privmsg', 'nickserv', "identify $pass");
    }

    foreach my $chan (@{ $config->{channels} || [] }) {
        $irc->yield('join', $chan);
    }
}

sub irc_public {
    my $heap = $_[HEAP];
    my $self = $heap->{sophie};
    my $nick = $heap->{nick};
    my ($string) = $_[ARG2] =~ m/^(?:\Q$nick\E:?\s+|:)(\S.*)/
        or return;

    my $from = ($_[ARG0] =~ /^([^!]*)!/)[0];
    my $chan = shift(@{$_[ARG1]});

    $self->handle_message(
        {
            from => $from,
            to => $chan,
            heap => $heap
        },
        [ 
            $heap->{server} . '@' . lc($chan),
            $heap->{server} . '@' . lc($from),
        ],
        $string
    );
}

sub irc_msg {
    my $heap = $_[HEAP];
    my $irc = $heap->{irc};
    my $self = $heap->{sophie};

    my $line = $_[ARG2];
    $line =~ s/^://;
    my $from = ($_[ARG0] =~ /^([^!]*)!/)[0];
 
    $self->handle_message(
        {
            from => $from,
            heap => $heap
        },
        [ $heap->{server} . '@' . lc($from) ],
        $line
    );
}

sub show_reply {
    my ($self, $heap, $reply) = @_;

    my ($replyto, $prefix) = $heap->{to} && !$reply->{private_reply}
        ? ($heap->{to}, $heap->{from} . ': ')
        : ($heap->{from}, '');
    
    foreach (@{$reply->{message}}) {
        $heap->{heap}->{irc}->yield(
            'privmsg',
            $replyto,
            sprintf("%s%s", ($heap->{to} ? $prefix : ''), $_)
        );
    }
}

sub user_config {
    my ($self, $heap, $var, $value) = @_;

    $self->set_var($heap->{heap}{server} . '@' . lc($heap->{from}),
        { $var => $value });
}

sub run {
    my ($self) = @_;

    while (1) {
        if ($self->{options}{ircserver}) {
            $self->setup_server(
                $self->{options}{ircserver},
                $self->{options}{ircnick},
            );
        } else {
            my $resp = $self->send_request('user.fetchdata', 'botconfig');
            if (ref $resp) {
                if ($resp->value) {
                    foreach (ref($resp->value->{server}) ? @{$resp->value->{server}}
                        : $resp->value->{server}) {
                        $self->setup_server($_);
                    }
                } else {
                    warn "No config found\n";
                    return;
                }
            } else {
                warn "Cannot fetch config\n";
                return;
            }
        }

        POE::Kernel->run();
        my $wait = 15 + rand(60);
        warn "waiting $wait to reconnect\n";
        sleep($wait);
    }
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Sophie::Client - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Sophie::Client;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Sophie::Client, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Olivier Thauvin, E<lt>olivier@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Olivier Thauvin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
