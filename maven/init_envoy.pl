#!/usr/bin/perl
use strict;
use warnings;

use File::stat;
use File::Slurp;

my $description = "Maven Envoy Perl Daemon";
my $script_path = $ENV{'HOME'} . "/Git/scripts/maven/envoy.pl";

my $sb = stat($script_path);
my $uid = $sb->uid;
my $gid = $sb->gid;
my $username = getpwuid($uid);
my $groupname = getgrgid($gid);

my $service_content = <<EOF;
[Unit]
Description=$description

[Service]
ExecStart=/usr/bin/perl $script_path
Restart=always
User=$username
Group=$groupname
Environment=PERL5LIB=/path/to/your/perl/libs

[Install]
WantedBy=multi-user.target
EOF

write_file('/etc/systemd/system/maven_envoy.service', {binmode => ':raw'}, $service_content);
