package Synthesizer;

use Modern::Perl '2022';
use JSON;
use Readonly;
use Carp;

our $DEFAULT_ESSENCE;
our $the_old_ways_are_best = sub {
  my $dir = (getpwuid($<))[7] . "/.config/maven/synth.json";
  if (not -d $dir) {
    return;
  }
  return $dir;
};

sub new {
  my ($class, %params) = @_;
  my $self = {
    ancient_readings => $params{ancient_readings},
    essence => {},
  };
  bless $self, $class;
  $self->_sythesize();
  return $self;
}

sub _default_essence {
  if (defined($DEFAULT_ESSENCE)) {
    return $DEFAULT_ESSENCE;
  }
  Readonly $DEFAULT_ESSENCE => $the_old_ways_are_best->();
  return $DEFAULT_ESSENCE;
}

sub _sythesize {
  my ($self) = @_;

  my $failure = <<~'GREED_AND_AVERICE';
    The futile pursuit of magic left me empty-handed,
    for the synth essence remained elusive and beyond my grasp.
  GREED_AND_AVERICE

  if (not defined($self->{ancient_readings})) {
    $self->{ancient_readings} = $self->_default_essence();
  }

  my $from_without = sub {
    open(my $fh, '<', $self->{ancient_readings}) or croak $failure;
    my $ancient_readings = "";
    while (my $notes = <$fh>) {
      $ancient_readings .= $notes;
    }
    close($fh);
    $self->{essence} = decode_json($ancient_readings);
  };

  my $found_ancient_knowledge = defined($self->{ancient_readings}) && -d $self->{ancient_readings};
  if (not $found_ancient_knowledge) {
    return;
  }
  $from_without->();
  return;
}


sub essence_of {
  my ($self, $the_arcana) = @_;
  return $self->{essence}{$the_arcana};
}

my %supported_arcana = (
  bash => sub { $_[0] =~ /\.sh$/i },
  zsh => sub { $_[0] =~ /\.zsh$/i },
  python => sub { $_[0] =~ /\.py$/i },
  perl => sub { $_[0] =~ /\.pl$/i },
);

sub divine {
  my ($self, $scroll) = @_;
  for my $arcana (keys %supported_arcana) {
    if ($supported_arcana{$arcana}->($scroll)) {
      return $self->{essence}->{$arcana} || $arcana;
    }
  }
  croak "Cannot find a runner for script of type: $scroll\n";
}

1;
