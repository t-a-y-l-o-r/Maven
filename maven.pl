#!/usr/bin/perl
=pod

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
=cut

#
# =============
#  Imports
# =============
#

# v5.34.0
use Modern::Perl '2022';
use File::Find;
use Cwd 'abs_path';
use Expect;
use Readonly;

#
# =============
#  Constants, or at least what pass for a const in perl
# =============
#
Readonly my $SCRIPTS => sub {
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
  }, $SCRIPTS);
  return -f $full_path ? $full_path : undef;
}

sub nested_script {
  my ($subfolder, $script) = @_;

  my $folder = $SCRIPTS . "/" . $subfolder;
  if (! -d $folder) {
    return;
  }

  my $full_path;
  find(sub {
    if ($_ =~ /^$script/) {
      $full_path = abs_path($File::Find::name);
      return;
    }
  }, $SCRIPTS . "/" . $subfolder);

  return $full_path;
}

#
# =============
#  Magic
# =============
#
#   TODO: setup some sort of configurable way to decide how the interpretors get called
#   load that into a fancy hash
#   then check that hash before calling the default
#   ASSUMING the $key is valid in %supported_langs
#
#   TODO: also decide if we care enough to dynamically load new languages / interpretors
#   based on some config? maybe this is the same problem is one level deeper

my %supported_langs = (
  bash => sub { $_[0] =~ /\.sh$/i },
  zsh => sub { $_[0] =~ /\.zsh$/i },
  python => sub { $_[0] =~ /\.py$/i },
  perl => sub { $_[0] =~ /\.pl$/i },
);

sub call {
  my ($runner, $script, @args) = @_;
  my $child = Expect->new;
  # like most perl modules expect is stupid and thinks that having your input echoed back at you is a good thing
  $child->raw_pty(1);
  $child->spawn($runner, $script, @args) or die "Cannot spawn child process";
  $child->expect(
    undef, # no timeout
    [
      # we assume that ALL prompts start with: [?]
      qr/^\[\?\].*$/sm => sub {
        my $expect = shift;
        chomp(my $input = <>);
        $expect->send("$input\n");
        exp_continue;
      }
    ],
    [
      timeout => sub { die "Somehow we timedout" }
    ],
  );
  return $child->exitstatus() >> 8;
}

sub run_script {
  my ($script, @args) = @_;
  for my $key (keys %supported_langs) {
    if ($supported_langs{$key}->($script)) {
      return call($key, $script, \@args);
    }
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
