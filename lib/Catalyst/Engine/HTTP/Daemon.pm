package Catalyst::Engine::HTTP::Daemon;

use strict;
use base 'Catalyst::Engine::Test';

use IO::Socket qw(AF_INET);

=head1 NAME

Catalyst::Engine::HTTP::Daemon - Catalyst HTTP Daemon Engine

=head1 SYNOPSIS

A script using the Catalyst::Engine::HTTP::Daemon module might look like:

    #!/usr/bin/perl -w

    BEGIN { 
       $ENV{CATALYST_ENGINE} = 'HTTP::Daemon';
    }

    use strict;
    use lib '/path/to/MyApp/lib';
    use MyApp;

    MyApp->run;

=head1 DESCRIPTION

This is the Catalyst engine specialized for development and testing.

=head1 OVERLOADED METHODS

This class overloads some methods from C<Catalyst::Engine::Test>.

=over 4

=item $c->run

=cut

$SIG{'PIPE'} = 'IGNORE';

sub run {
    my $class = shift;
    my $port  = shift || 3000;

    my $daemon = Catalyst::Engine::HTTP::Daemon::Catalyst->new(
        LocalPort => $port,
        ReuseAddr => 1
    );

    unless ($daemon) {
        die("Failed to create daemon: $!\n");
    }

    printf( "You can connect to your server at %s\n", $daemon->url );

    while ( my $connection = $daemon->accept ) {

        while ( my $request = $connection->get_request ) {

            $request->uri->scheme('http');    # Force URI::http

            my $lwp = Catalyst::Engine::Test::LWP->new(
                request  => $request,
                address  => $connection->peerhost,
                hostname => gethostbyaddr( $connection->peeraddr, AF_INET )
            );

            $class->handler($lwp);
            $connection->send_response( $lwp->response );
        }

        $connection->close;
        undef($connection);
    }
}

=back

=head1 SEE ALSO

L<Catalyst>, L<HTTP::Daemon>.

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>
Christian Hansen, C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

package Catalyst::Engine::HTTP::Daemon::Catalyst;

use strict;
use base 'HTTP::Daemon';

sub product_tokens {
    "Catalyst/$Catalyst::VERSION";
}

1;
