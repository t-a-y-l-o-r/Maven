#!/usr/bin/perl
use strict;
use warnings;

use IO::Socket::INET;
use POSIX qw(setsid);

sub daemonize {
  chdir '/' or die "Can't chdir to /: $!";
  open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
  open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";
  open STDERR, '>&STDOUT' or die "Can't dup stdout: $!";
  setsid or die "Can't start a new session: $!";
}

sub main {
  my $daemon;
  my $port;

  my $canary_file = "/tmp/maven_canary";
  my $port_file = "/tmp/maven_port";
  my $output_file = "/home/YOUR_USERNAME/Desktop/received_data.txt";

  for ($port = 5000; $port < 5020; $port++) {
    $daemon = IO::Socket::INET->new(
      LocalPort => $port,
      Type => SOCK_STREAM,
      Reuse => 1,
      Listen => 10
    );
    last if defined($daemon);
  }

  if (!defined($daemon)) {
    my $err_message = "Could not open socket on any port in the range 5000-5019: $!";
    open my $fh, '>', $canary_file or die "Could not open '$canary_file' $!";
    print $fh $err_message;
    close $fh;
    exit 1;
  }

  open my $fh, '>', $port_file or die "Could not open '$port_file' $!";
  print $fh $port;
  close $fh;

  my $last_update = time;  # track last canary file update

  while (1) {
    if (time - $last_update >= 60) {
      my $timestamp = localtime();
      open my $fh, '>', $canary_file or die "Could not open '$canary_file' $!";
      print $fh "chirp {$timestamp}";
      close $fh;
      $last_update = time;
    }

    while (my $client = $daemon->accept()) {
      my $data = <$client>;
      chomp $data;
      open my $fh, '>>', $output_file or die "Could not open '$output_file' $!";
      print $fh "$data\n";
      close $fh;
    }

    sleep 1;
  }

  close($daemon);
}

daemonize();
main();
