# External Commands

Homebrew, like Git, supports *external commands*. This lets you create new commands that can be run like:

```sh
brew mycommand --option1 --option3 <formula>
```

without modifying Homebrew's internals.

## Command types
External commands come in two flavours: Ruby commands and shell scripts.

In both cases, the command file should be executable (`chmod +x`) and live somewhere in `PATH`.

External commands can be added to a tap to allow easy distribution. See [below](#external-commands-in-taps) for more details.

### Ruby commands
An external command `extcmd` implemented as a Ruby command should be named `brew-extcmd.rb`. The command is executed by doing a `require` on the full pathname. As the command is `require`d, it has full access to the Homebrew "environment", i.e. all global variables and modules that any internal command has access to. Be wary of using Homebrew internals; they may change at any time without warning.

The command may `Kernel.exit` with a status code if it needs to; if it doesn't explicitly exit then Homebrew will return `0`.

### Other executable scripts
An executable script for a command named `extcmd` should be named `brew-extcmd`. The script itself can use any suitable shebang (`#!`) line, so an external script can be written in Bash, Ruby, or even Python. Unlike the ruby commands this file must not end with a language-specific suffix (`.sh`, or `.py`). This file will be run via `exec` with some Homebrew variables set as environment variables, and passed any additional command-line arguments.

| Variable               | Description                                                                                                                                                                 |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `HOMEBREW_CACHE`       | Where Homebrew caches downloaded tarballs to, by default `~/Library/Caches/Homebrew`.                                                                                       |
| `HOMEBREW_CELLAR`      | The location of the Homebrew Cellar, where software is staged. This will be `HOMEBREW_PREFIX/Cellar` if that directory exists, or `HOMEBREW_REPOSITORY/Cellar` otherwise.   |
| `HOMEBREW_LIBRARY_PATH`| The directory containing Homebrew’s own application code.                                                                                                                   |
| `HOMEBREW_PREFIX`      | Where Homebrew installs software. This is always the grandparent directory of the `brew` executable, `/usr/local` by default.                                               |
| `HOMEBREW_REPOSITORY`  | If installed from a Git clone, the repository directory (i.e. where Homebrew’s `.git` directory lives).                                                                       |

## Providing `--help`

All internal and external Homebrew commands can provide styled `--help` output by using lines starting with `#:` (a comment then `:` character in both Bash and Ruby) which are then output by `--help`.

For example, see the [header of `brew-services.rb`](https://github.com/Homebrew/homebrew-services/blob/a58a1fe9145de4e50e1cbfb5b0e8a30087826393/cmd/brew-services.rb#L1-L23) which is output with `brew services --help`.

## Homebrew organisation external commands

### homebrew-command-not-found
Ubuntu's `command-not-found equivalent` for Homebrew.
See the [`README`](https://github.com/Homebrew/homebrew-command-not-found/blob/HEAD/README.md) for more info and usage.

Install using:

```sh
brew tap homebrew/command-not-found
```

### homebrew-aliases
Allows you to alias your Homebrew commands.
See the [`README`](https://github.com/Homebrew/homebrew-aliases/blob/HEAD/README.md) for more info and usage.

Install using:

```sh
brew tap homebrew/aliases
```

## Unofficial external commands
These commands have been contributed by Homebrew users but are not included in the main Homebrew organisation, nor are they installed by the installer script. You can install them manually, as outlined above.

Note they are largely untested, and as always, be careful about running untested code on your machine.

### brew-gem
Install any `gem` package into a self-contained Homebrew Cellar location: <https://github.com/sportngin/brew-gem>

Note this can also be installed with `brew install brew-gem`.

## External commands in taps
External commands can be hosted in a [tap](Taps.md) to allow users to easily install and use them. See [How to Create and Maintain a Tap](How-to-Create-and-Maintain-a-Tap.md) for more details about creating and maintaining a tap.

External commands should be added to a `cmd` directory in the tap. An external command `extcmd` implemented as a Ruby command should live in `cmd/extcmd.rb` (don't forget to `chmod +x`).

To easily use Homebrew's argument parser, follow the following Ruby template for external commands (replacing all instances of `foo` with the name of the command):

```ruby
# frozen_string_literal: true

module Homebrew
  module_function

  def foo_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Do something. Place a description here.
      EOS
      switch "-f", "--force",
             description: "Force doing something in the command."
      flag   "--file=",
             description: "Specify a file to do something with in the command."
      comma_array "--names",
                  description: "Add a list of names to the command."

      named_args [:formula, :cask], min: 1
    end
  end

  def foo
    args = foo_args.parse

    something if args.force?
    something_else if args.file == "file.txt"
  end
end
```

Using the above will generate appropriate help text:

```console
$ brew foo --help
Usage: brew foo [options] formula|cask [...]

Do something. Place a description here.

  -f, --force                      Force doing something in the command.
      --file                       Specify a file to do something with in the
                                   command.
      --names                      Add a list of names to the command.
  -d, --debug                      Display any debugging information.
  -q, --quiet                      Make some output more quiet.
  -v, --verbose                    Make some output more verbose.
  -h, --help                       Show this message.
```

The usage string is automatically generated based on the specified number and type of named arguments (see below for more details on specifying named arguments). The generated usage string can be overridden by passing the correct usage string to the `usage_banner` method (placed just before the `description` method). See the [`brew tap` command](https://github.com/Homebrew/brew/blob/HEAD/Library/Homebrew/cmd/tap.rb) for an example.

Use the `named_args` method to specify the type and number of named arguments that are expected. Pass either a symbol to indicate the type of argument expected, an array of symbols to indicate that multiple types should be expected, or an array of strings to specify which specific options should be expected (see the [`brew analytics`](https://github.com/Homebrew/brew/blob/HEAD/Library/Homebrew/cmd/analytics.rb) command for an example of this).

Pass an integer to the `number`, `min`, or `max` parameter of `named_args` to specify the number of named arguments that are expected. See the following examples:

```ruby
# Accept no named args
named_args :none

# Accept any number (including none) of formula arguments
named_args :formula

# Accept exactly one of the specified options as an argument
named_args %w[state off on], number: 1

# Accept at least one argument that is either a formula or a cask
named_args [:formula, :cask], min: 1

# Accept no more than one argument that is a tap
named_args :tap, max: 1

# Accept between one and two named args
named_args min: 1, max: 2
```

Named arguments can be accessed by calling `args.named`. Check out the internal [commands](https://github.com/Homebrew/brew/tree/HEAD/Library/Homebrew/cmd) and [developer commands](https://github.com/Homebrew/brew/tree/HEAD/Library/Homebrew/dev-cmd) for more usage examples.
