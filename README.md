# Maven

  Maven is a dynamic dispatch system for a generalized scripting solution.

# Who is Maven for?

  Me. It's intended for personal use only

# Disclamer

  Use at your own risk! This code is in no way secure.
  In fact this should be considered the hackiest perl you've ever laid eyes on.
  Unless you've written perl before, in which case, go away! I dont want your opinons

# Usage

  Say for instance that you have a script titled `add_command` within a folder named `django`.
  If you wanted to run this command from maven with the arguments `project/application` and `new_command_name`
  then you would do so as follows:
  ```sh
  maven django add_command 'project/application' 'new_command'
  ```

  Maven will attempt to discover your script in one of two ways;
    1) As the first argument in the set of arguments
    2) As a file within the subfolder of the first argument.

  What this means is you can have "sub" commands by nesting scripts in folders.
  Please note that currently maven will only discover commands one layer deep.
  i.e. it is not capable of discovering scripts recursively. Although that sounds cool, so maybe it will someday

  If we take the file tree from below then the following patterns are valid:

  ```sh
  maven top_test args*
  ```

  ```sh
  maven folder nested args*
  ```

# Configuration

  You can configure which "runner" is used when a language is detected.
  In fact this also technically allows maven to work on languages outside of it's original scrope.
  But I haven't tested that so good luck.

  The config file lives here:
    ~/.config/maven/synth.json

  And here is an example usage:

  ```json
  {
    "perl": "~/perl5/perlbrew/perls/perl-5.36.1/bin/perl5.36.1"
  }
  ```

# Structure

  In general this script will be utialized to run scripts in a structure like so:
  ```
    .
    ├── django
    │   └── add_command.pl
    ├── folder
    │   └── nested.sh
    ├── maven.pl
    └── top_test.sh
  ```

# Functionality

  Currently it supports all the script types that it supports. Ref `maven::run_script` if you care.
  It handles none of the errors and may some day log things like usage and errors.
  Until it does that it doesn't do that. When will it do that? If I add it

  In it's original incarnation it was a bare-bones zsh function which used shell magic
  to do shell magic things related to files and directories.
  However in the Great .zshrc Purge of 2023 an idea was born.
  That ideas was named maven.pl

# Setup

  How do you utalize maven? What's the point of having a script that calls other scripts?
  If you need to ask this then you probably dont need or care to need maven. Tools like maven
  are best utalized when bootstrapped by an rc configuration in patterns like so:

  ```zsh
  function maven {
    perl $HOME/Git/scripts/maven.pl "$@"
  }
  ```
  If you aren't sure what that means then dont worry about it. You can always forget this ever existed

# Contributing

  I'd prefer if you didn't! Instead feel free to fork it and make your own copy.

# Why Is This Public?

  Great question! Because in the world of open source there are two types of projects we like to imagine exist:

  1) Someone builds something for money and then realizes really all things should be free because this capitalistic system we live in is designed to parasitize every aspect of our waking moment.

  or

  2) Someone does something dumb late at night

  This is the latter
