#!/usr/bin/perl

## no critic

my $PROJECT_DIR = sub {
  my $rc = (getpwuid($<))[7] . "/.config/maven/rc";
  -f $rc or croak $rc . " is not a valid file\n";
  open(my $fh, '<', $rc) or die "Nope";
  while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /^.*MAVEN_PROJECT_DIR.*$/i) {
      close($fh);
      my $path = (split("=", $line))[-1];
      return $path =~ s/["']//gr;
    }
  }
  close($fh);
  die "No project dir found in rc file: $rc";
} -> ();

unless (defined($PROJECT_DIR)) {
  die "$PROJECT_DIR is undef";
}

my $PYTHON_VERSION = sub {
  my ($dir) = @_;
  my $python_version_file = "$dir/.python-version";

  open(my $fh, '<', $python_version_file) or die "Py version NOPED: $python_version_file";
  while (my $line = <$fh>) {
    chomp($line);
    close($fh);
    return $line;
  }
  close($fh);
  die "No python version";
} -> ($PROJECT_DIR);

# Read the Python version from .python-version file

# Get the absolute path to the build script directory

# Generate the Dockerfile content
my $docker_script = <<"EOF";
FROM python:$PYTHON_VERSION
WORKDIR /usr/src/app

RUN $PROJECT_DIR/build.sh

COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver_plus", "0.0.0.0:8000"]
EOF

open(my $fh, '>', "Dockerfile") or die "Cant open Dockerfile";
print $fh $docker_script;
close($fh);
