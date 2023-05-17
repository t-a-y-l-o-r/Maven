#!/usr/bin/perl

use strict;
use warnings;

@ARGV == 2 or die "This script requires a project_prefix and a command_name\n";

my $project_prefix = cwd() . $ARGV[0];
my $command_name = $ARGV[1];

defined $project_prefix or die "Project/app prefix is requied\n";
defined $command_name or die "Command name is required!\n";

-d $project_prefix or die "Project prefix is not a valid directory!\n";
$command_name =~ /^[a-z_]+$/ or die "File name must be snake case!\n";

-d $project_prefix . "/management" or mkdir $project_prefix . "/management" or die "Cant make managment folder\n";
-d $project_prefix . "/management/commands" or mkdir $project_prefix . "/management/commands" or die "Cant make commands folder\n";

open(my $file, ">", $project_prefix . "/management/__init__.py") or die "Failed to ensure init1 was created\n" and close $file;
open(my $file, ">", $project_prefix . "/management/commands/__init__.py") or die "Failed to ensure init2 was created\n" and close $file;

# the part that matters
open(my $file, ">", $project_prefix . "/management/commands/" . $command_name .".py") or die "Failed to ensure command file was created\n" and close $file;

