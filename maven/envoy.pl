#!/usr/bin/perl
use strict;
use warnings;

use IO::Socket::INET;
use POSIX qw(setsid);

my $login_name = getlogin || getpwuid($<) || die "Cannot get login name";
my $home = (getpwnam($login_name))[7];

sub daemonize {
  chdir '/' or die "Can't chdir to /: $!";
  open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
  # open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";
  open STDOUT, '>/tmp/maven_log' or die "Can't write to /dev/null: $!";
  open STDERR, '>&STDOUT' or die "Can't dup stdout: $!";
  setsid or die "Can't start a new session: $!";
}

sub main {
  print "Starting main\n";
  my $daemon;
  my $port;

  my $canary_file = "/tmp/maven_canary";
  my $port_file = "/tmp/maven_port";
  my $output_file = $home . "/Desktop/received_data.txt";

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

  print "[*] First!\n";
  open my $fh_port, '>', $port_file or die "Could not open '$port_file' $!";
  print $fh_port $port;
  close $fh_port;

  my $last_update = time;  # track last canary file update
  open my $fh_canary, '>', $canary_file or die "Could not open '$output_file' $!";
  print $fh_canary "first $last_update\n";
  close $fh_canary;


  while (1) {
    print "[*] Loopy~\n";
    if (time - (stat($canary_file))[9] >= 60) {
      my $timestamp = localtime();
      open $fh_canary, '>', $canary_file or die "Could not open '$canary_file' $!";
      print $fh_canary "chirp $timestamp\n";
      close $fh_canary;
      $last_update = time;
    }

    while (my $client = $daemon->accept()) {
      my $data = <$client>;
      chomp $data;
      open my $fh_log, '>>', $output_file or die "Could not open '$output_file' $!";
      print $fh_log "$data\n";
      close $fh_log;
    }

    sleep 1;
  }

  close($daemon);
}

daemonize();
main();
