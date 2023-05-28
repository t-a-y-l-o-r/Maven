#!/usr/bin/perl
use strict;
use warnings;

my $login_name = getlogin || getpwuid($<) || die "Cannot get login name";
my $home = (getpwnam($login_name))[7];

my $script_path = $home . "/Git/scripts/maven/envoy.pl";
print $script_path . "\n";
-e $script_path or die "Where is your envoy?\n";

my @stats = stat($script_path);
my $uid = $stats[4];
my $gid = $stats[5];
my $username = getpwuid($uid);
my $groupname = getgrgid($gid);

my $envoy_stardust = <<EOF;
[Unit]
Description=Envoy for the Maven

[Service]
ExecStart=/usr/bin/perl $script_path
Restart=always
User=$username
Group=$groupname
Environment=PERL5LIB=/path/to/your/perl/libs

[Install]
WantedBy=multi-user.target
EOF

open(my $fh, ">", "/etc/systemd/system/maven_envoy.service") or die $!;
print $fh $envoy_stardust;
close $fh;
