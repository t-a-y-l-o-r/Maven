#!/usr/bin/perl
use strict;
use warnings;
use Cwd qw();

@ARGV or die "No app name provided";

my $app_name = shift @ARGV;
my $dir = Cwd::abs_path();
my $project_name = (split("/", $dir))[-1];

-d "$dir/$project_name/$app_name" or mkdir "$dir/$project_name/$app_name";

my $command = "./manage.py startapp $app_name $project_name/$app_name";
system($command);
if ($? ne 0) {
  die $? >> 8;
}

my $settings_file = "$project_name/config/settings/base.py";

my $found_list = 0;
my $app_list = "LOCAL_APPS";
my $done = 0;
my @lines;

open (my $fh, '<', $settings_file) or die "Could not open file: $settings_file";
while (my $row = <$fh>) {
  chomp $row;
  if ($done eq 1) {
    push @lines, $row;
    next;
  }

  if ($found_list eq 1 && $row =~ /^\s*\]\s*,?\s*$/) {
    push @lines, "    \"$project_name.$app_name\",";
    $done = 1;
  }

  if ($row =~ /\s*\Q$app_list\E\s*=\s*\[.*$/) {
    $found_list = 1;
  }
  push @lines, $row;
}

close $fh;


open($fh, '>', $settings_file) or die "Could not write to file: $settings_file";
foreach my $line (@lines) {
  print $fh "$line\n";
}
close $fh;
exit(system("git diff"));
