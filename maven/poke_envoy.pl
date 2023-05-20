#!/usr/bin/perl
use strict;
use warnings;

use IO::Socket::INET;
use File::Slurp;

my $port_file = "/dev/tmp/maven_port";
my $port = read_file($port_file, chomp => 1);

my $socket = IO::Socket::INET->new(
    PeerAddr => 'localhost',
    PeerPort => $port,
    Proto => 'tcp',
);

die "Could not create socket: $!\n" unless $socket;

print $socket "timestamp, user, full_script_path, arguments\n";

close($socket);

