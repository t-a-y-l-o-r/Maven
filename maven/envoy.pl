#!/usr/bin/perl
use strict;
use warnings;

use IO::Socket::INET;
use File::Slurp;
use POSIX qw(setsid);

sub daemonize {
    chdir '/'                  or die "Can't chdir to /: $!";
    open STDIN, '/dev/null'    or die "Can't read /dev/null: $!";
    open STDOUT, '>/dev/null'  or die "Can't write to /dev/null: $!";
    open STDERR, '>&STDOUT'    or die "Can't dup stdout: $!";
    setsid                     or die "Can't start a new session: $!";
}

sub main {
    my $daemon;
    my $port;

    my $canary_file = "/dev/tmp/maven_canary";
    my $port_file = "/dev/tmp/maven_port";
    my $output_file = "/home/YOUR_USERNAME/Desktop/received_data.txt";

    # Iterate through 20 ports starting at 5000
    for ($port = 5000; $port < 5020; $port++) {
        $daemon = IO::Socket::INET->new(
            LocalPort => $port,
            Type      => SOCK_STREAM,
            Reuse     => 1,
            Listen    => 10
        );
        last if defined($daemon);  # Break out of the loop if binding is successful
    }

    # Write error to the canary file and terminate if no free port found
    if (!defined($daemon)) {
        my $err_message = "Could not open socket on any port in the range 5000-5019: $!";
        write_file($canary_file, {binmode => ':raw'}, $err_message);
        exit 1;
    }

    write_file($port_file, {binmode => ':raw'}, $port);

    my $last_update = time;  # track last canary file update

    while (1) {
        # update canary file if one minute has passed
        if (time - $last_update >= 60) {
            my $timestamp = localtime();
            write_file($canary_file, {binmode => ':raw'}, "chirp {$timestamp}");
            $last_update = time;
        }

        # check for connections and process data
        while (my $client = $daemon->accept()) {
            my $data = <$client>;
            chomp $data;
            write_file($output_file, {append => 1, binmode => ':raw'}, "$data\n");
        }

        sleep 1;
    }

    close($daemon);
}

daemonize();
main();
