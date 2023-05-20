#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use Cwd 'abs_path';
use File::Basename;

$ENV{PATH} = "$ENV{PATH}:~/Git/scripts";

sub nested_script {
  my ($subfolder, $script) = @_;
  my $full_path;

  if (!-d "~/Git/scripts/$subfolder") {
      return "";
  }

  find(sub {
      if ($_ eq "$script.*") {
          $full_path = abs_path($File::Find::name);
      }
  }, "~/Git/scripts/$subfolder");

  return $full_path;
}

sub top_level_script {
  my $script = shift;
  my $full_path;

  find(sub {
      if ($_ eq "$script.*") {
          $full_path = abs_path($File::Find::name);
      }
  }, "~/Git/scripts/");

  return $full_path;
}

sub run_script {
  my ($script, @args) = @_;
  my $filetype = fileparse($script, qr/\.[^.]*/);

  if ($filetype eq ".sh") {
      system("bash", $script, @args);
  } elsif ($filetype eq ".py") {
      system("python", $script, @args);
  } elsif ($filetype eq ".pl") {
      system("perl", $script, @args);
  } else {
      print "Cannot find a runner for script of type: $filetype\n";
      return 1;
  }
  return 0;
}

my $script_path = top_level_script($ARGV[0]);

if ($script_path ne "") {
  shift @ARGV;
  exit(run_script($script_path, @ARGV));
}

$script_path = nested_script($ARGV[0], $ARGV[1]);

if ($script_path ne "") {
  shift @ARGV;
  shift @ARGV;
  exit(run_script($script_path, @ARGV));
}

print "Unable to determine command\n";
exit 1;
