#!/usr/bin/perl
use strict;
use warnings;

use File::stat;
use File::Slurp;

# Set the description
my $description = "Maven Envoy Perl Daemon";

# Get the full path of the script
my $script_path = $ENV{'HOME'} . "/Git/scripts/maven/envoy.pl";

# Get the user and group of the script
my $sb = stat($script_path);
my $uid = $sb->uid;
my $gid = $sb->gid;
my $username = getpwuid($uid);
my $groupname = getgrgid($gid);

# Define the systemd service file content
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

# Write the service content to the systemd service file
write_file('/etc/systemd/system/maven_envoy.service', {binmode => ':raw'}, $service_content);
