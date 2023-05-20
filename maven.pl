#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use Cwd 'abs_path';
use File::Basename;

use constant SCRIPTS => sub {
  my $dir = (getpwuid($<))[7] . "/Git/scripts";
  -d $dir or die $dir . " is not a valid directory\n";
  return $dir
} -> ();



sub top_level_script {
  my $script = shift;
  my $full_path;
  find(sub {
    if ($_ =~ /^$script/) {
      $full_path = abs_path($File::Find::name);
      return;
    }
  }, SCRIPTS);
  return -f $full_path ? $full_path : undef;
}

sub nested_script {
  my ($subfolder, $script) = @_;

  my $folder = SCRIPTS . "/" . $subfolder;
  if (! -d $folder) {
    return undef;
  }

  my $full_path;
  find(sub {
    if ($_ =~ /^$script/) {
      $full_path = abs_path($File::Find::name);
      return;
    }
  }, SCRIPTS . "/" . $subfolder);

  return $full_path;
}
sub run_script {
  my ($script, @args) = @_;
  if ($script =~ /\.sh$/i) {
    system("bash", $script, @args);
  } elsif ($script =~ /\.py$/i) {
    system("python", $script, @args);
  } elsif ($script =~ /\.pl$/i) {
    system("perl", $script, @args);
  } else {
    print "Cannot find a runner for script of type: $script\n";
    return 1;
  }
  return 0;
}

my $script_path = top_level_script($ARGV[0]);

if (defined $script_path) {
  shift @ARGV;
  exit(run_script($script_path, @ARGV));
}

$script_path = nested_script($ARGV[0], $ARGV[1]);

if (defined $script_path) {
 shift @ARGV;
 shift @ARGV;
 exit(run_script($script_path, @ARGV));
}

print "Unable to determine command\n";
exit 1;
