package Synthesizer;

use Modern::Perl '2022';
use JSON;
use Readonly;
use Carp;

use feature 'signatures';

#   TODO: also decide if we care enough to dynamically load new languages / interpretors
#   based on some config? maybe this is the same problem is one level deeper

# TODO: lets get fancy with tied variables
# OR: perl attributes sounds pretty cool
our $DEFAULT_ESSENCE;
our $the_old_ways_are_best = sub {
  my $synth = (getpwuid($<))[7] . "/.config/maven/synth.json";
  if (not -f $synth) {
    return;
  }
  return $synth;
};

sub new ($class, %params) {
  my $self = {
    ancient_readings => $params{ancient_readings},
    essence => {},
  };
  bless $self, $class;
  $self->_sythesize();
  return $self;
}

sub _default_essence ($self) {
  if (defined($DEFAULT_ESSENCE)) {
    return $DEFAULT_ESSENCE;
  }
  Readonly $DEFAULT_ESSENCE => $the_old_ways_are_best->();
  return $DEFAULT_ESSENCE;
}

sub _sythesize ($self) {
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

  my $found_ancient_knowledge = defined($self->{ancient_readings}) && -f $self->{ancient_readings};

  my $isafile = (-f $self->{ancient_readings}) + 0;

  if (not $found_ancient_knowledge) {
    return;
  }
  $from_without->();
  return;
}

my %supported_arcana = (
  "bash" => {
    "runner" => "bash",
    "extension" => "sh",
  },
  "zsh" => {
    "runner" => "zsh",
    "extension" => "zsh",
  },
  "python" => {
    "runner" => "python",
    "extension" => "py",
  },
  "perl" => {
    "runner" => "perl",
    "extension" => "pl",
  },
);

sub matcher ($scroll, $discipline) {
  return $scroll =~ /\.\Q$discipline\E$/i
}


sub divine ($self, $scroll) {
  my %innate_and_learned = (%supported_arcana, %{$self->{essence}});
  for my $arcana (keys %innate_and_learned) {
    my $discipline = $innate_and_learned{$arcana}->{extension};
    if (matcher($scroll, $discipline)) {
      return glob($innate_and_learned{$arcana}->{runner});
    }
  }
  croak "Cannot find a runner for script of type: $scroll\n";
}

1;
