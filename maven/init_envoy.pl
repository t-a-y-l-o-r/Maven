#!/usr/bin/perl
use strict;
use warnings;

my $script_path = $ENV{'HOME'} . "/Git/scripts/maven/envoy.pl";

my $sb = stat($script_path);
my $uid = $sb->uid;
my $gid = $sb->gid;
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
