#!/usr/bin/perl
use strict;
use warnings;

use IO::Socket::INET;

my $port_file = "/tmp/maven_port";

open my $fh, '<', $port_file or die "Could not open '$port_file' $!";
my $port = <$fh>;
chomp $port;
close $fh;

my $socket = IO::Socket::INET->new(
  PeerAddr => 'localhost',
  PeerPort => $port,
  Proto => 'tcp',
);

die "Could not create socket: $!\n" unless $socket;
print $socket "timestamp, user, full_script_path, arguments\n";
close($socket);
