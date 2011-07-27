use strict;
use warnings;
use FindBin qw/$Bin/;
use Test::More;
use Try::Tiny;

plan skip_all => "Need Test::Without::Module for this test"
    unless try { require Test::Without::Module; 1 };

use Test::Without::Module qw(
    Starman
    Plack::Handler::Starman
    MooseX::Daemonize
    MooseX::Daemonize::Pid::File
    MooseX::Daemonize::Core
);
require "$Bin/../aggregate/unit_core_script_server.t";

no Test::Without::Module qw(
    Starman
    Plack::Handler::Starman
    MooseX::Daemonize
    MooseX::Daemonize::Pid::File
    MooseX::Daemonize::Core
);

1;

