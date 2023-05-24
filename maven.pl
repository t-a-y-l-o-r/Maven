#!/usr/bin/perl
<<"README";
  ===============
    Description
  ===============
  Maven is a dynamic dispatch system for a generalized scripting solution.
  Why would you use it? Well you shouldn't. It was made by me for me.
  No updates will be made to this code for any third-party.
  In fact it is likely that no updates will be made for any reason unless they are

  No but seriously use at your own risk! This code is in no way secure.
  In fact this should be considered the hackiest perl you've ever laid eyes on.
  Unless you've written perl before, in which case, go away! I dont want your opinons

  In general this script will be utialized to run scripts in a structure like so:

  ~/Git/scripts/.
                ├── django
                │   └── add_command.pl
                ├── folder
                │   └── nested.sh
                ├── maven.pl
                └── top_test.sh

  Currently it supports all the script types that it supports. Ref run_script if you care.
  It handles none of the errors and may some day log things like usage and errors.
  Until it does that it doesn't do that. When will it do that? If I add it

  In it's original incarnation it was a bare-bones zsh function which used shell magic
  to do shell magic things related to files and directories.
  However in the Great .zshrc Purge of 2023 an idea was born.
  This is that idea

  ===============
    Contents
  ===============
  1. Imports
  2. Const
  3. Argument type detection
  4. Runner
  5. Main
README

#
# =============
#  Imports
# =============
#
use strict;
use warnings;
use File::Find;
use Cwd 'abs_path';
use File::Basename;

#
# =============
#  Constants, or at least what pass for a const in perl
# =============
#
use constant SCRIPTS => sub {
  my $dir = (getpwuid($<))[7] . "/Git/scripts";
  -d $dir or die $dir . " is not a valid directory\n";
  return $dir
} -> ();

#
# ==============================================
#  Argument Syntax Decider Decision Thingies
# ==============================================
#
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

#
# =============
#  Magic
# =============
#
sub run_script {
  my ($script, @args) = @_;
  if ($script =~ /\.sh$/i) {
    return system("bash", $script, @args) >> 8;
  }
  if ($script =~ /\.zsh$/i) {
    return system("zsh", $script, @args) >> 8;
  }
  if ($script =~ /\.py$/i) {
    return system("python", $script, @args) >> 8;
  }
  if ($script =~ /\.pl$/i) {
    return system("perl", $script, @args) >> 8;
  }
  print "Cannot find a runner for script of type: $script\n";
  return 1;
}

#
# ======================
#  The part that matters
# ======================
#
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
