# NAME

Test::CLI - Testing command-line invocations

# VERSION

This document describes Test::CLI version {{\[ version \]}}.

<div>
    <!-- a href="https://travis-ci.org/polettix/Test-CLI">
    <img alt="Build Status" src="https://travis-ci.org/polettix/Test-CLI.svg?branch=master">
    </a -->
    <a href="https://www.perl.org/">
    <img alt="Perl Version" src="https://img.shields.io/badge/perl-5.24+-brightgreen.svg">
    </a>
    <a href="https://badge.fury.io/pl/Test-CLI">
    <img alt="Current CPAN version" src="https://badge.fury.io/pl/Test-CLI.svg">
    </a>
    <a href="http://cpants.cpanauthors.org/dist/Test-CLI">
    <img alt="Kwalitee" src="http://cpants.cpanauthors.org/dist/Test-CLI.png">
    </a>
    <a href="http://www.cpantesters.org/distro/O/Test-CLI.html?distmat=1">
    <img alt="CPAN Testers" src="https://img.shields.io/badge/cpan-testers-blue.svg">
    </a>
    <a href="http://matrix.cpantesters.org/?dist=Test-CLI">
    <img alt="CPAN Testers Matrix" src="https://img.shields.io/badge/matrix-@testers-blue.svg">
    </a>
</div>

# SYNOPSIS

    use Test::CLI qw< tc >;

    my $tc = tc(qw{ ls [options=-l] <dir> });

    ok $tc->run('/'), 'plain run returns success/failure as boolean';

    # run and test on one go
    $tc->run_ok(dir => '/etc'); # run & test in one go
    $tc->run_ok(dir => '/var', 'optional message');

    # Last run is cached, all tests are related to it
    $tc->stdout_like(qr{log});
    $tc->stderr_is('');

    # Tests can be chained
    $tc->exit_code_is(0)
       ->signal_is(0)
       ->timeout_is(0)
       ->stdout_like(qr{run});

    # Verbose mode produces a dump of the whole run result if the test
    # is not successful
    $tc->verbose(1);
    $tc->failure_ok('test fails because run was ok'); # will dump data

    # It's always possible to go more in depth anyway
    $tc->run('/not-existent');
    my $run = $tc->last_run; # Test::Command::Runner::Record object
    isnt $run->exit_code, 0, 'file does not exist'
       or diag($run->stdout);

# DESCRIPTION

`Test::CLI` helps with performing tests of invoking external commands,
leveraging [Command::Template::Runner](https://metacpan.org/pod/Command::Template::Runner) for a flexible way of easily
calling these commands and [Command::Template::Runner::Record](https://metacpan.org/pod/Command::Template::Runner::Record) for
analyzing the outcome of these commands.

In general, it is geared at covering simpler cases where there is no
interaction with the command that is run, apart possibly providing a
standard input for the command to read in. To this extent, then, it is
mostly indicated for non-interactive commands (like, for example, most
Unix commands, or most of the sub-commands of `git`).

# INTERFACE

The interface is _object-oriented_, with the exception of the function
["tc"](#tc) (which is also aliased as ["test\_cli"](#test_cli)) that allows easily
getting a new `Test::CLI` object.

## Functions

There is one function with two aliases:

- `test_cli`
- `tc`

        my $tc = test_cli(@command_template);

    Create a `Test::CLI` object from the provided `@command_template`. It
    is actually a wrapper around the ["new"](#new) class method.

## Class Method: Constructor

The following constructor is supported as a class method:

- `new`

        my $tc = Test::CLI->new(@command_template);

    The `@command_template` is parsed and used through [Command::Template](https://metacpan.org/pod/Command::Template)
    (actually, through [Command::Template::Runner](https://metacpan.org/pod/Command::Template::Runner)).

    Returns a `Test::CLI` object, see below for the available interface of
    this object.

## Methods: Accessors

The following accessors are supported:

- `last_run`

        my $r = $tc->last_run;

    Returns the last `Command::Template::Runner::Record` produced in the
    last command run.

    Read-only.

- `last_command`

        my $string = $tc->last_command;

    Returns the stringification of the latest command that was run.

    Read-only.

- `runner`

        my $runner = $tc->runner;

    Returns the `Command::Template::Runner` object used by `Test::CLI` for
    executing commans.

    Read-only.

- `verbose`

        my $is_verbose = $tc>verbose;
        $tc->verbose(1); # set verbose mode
        $tc->verbose(0); # unset verbose mode

    Get or set the verbosity in error output. When set, each error in a test
    also generates a dump of the [Command::Template::Runner::Record](https://metacpan.org/pod/Command::Template::Runner::Record) object
    via a `diag` call.

    Defaults to _false_.

    Returns the current value for the flag when called without parameters.
    Sets the value and returns the object reference otherwise.

    Read-write method.

## Method: Executing

The following method allows executing one run of the command template
through [Command::Template::Runner](https://metacpan.org/pod/Command::Template::Runner), although with a different return
value.

- `run`

        my $run_was_successful = $tc->run(%bindings_and_options);

    Run the command with the provided bindings and options (see
    [Command::Template::Runner](https://metacpan.org/pod/Command::Template::Runner) for the details).

    The method returns a _true_ value if the command execution is
    successful (i.e. the exit value is 0 and there was no signal terminating
    the command). It also records the last run overall result as a
    `Command::Template::Runner::Record` object that can be later retrieved
    via ["last\_run"](#last_run).

## Method: Dumping

The following method is not a test but allows introspection. It is
called automatically if a test is unsuccessful and ["verbose"](#verbose) is
_true_.

- `dump_diag`

    This method method allows dumping the outcome of the last run as a
    `diag` message (which goes to standard error).

    The method returns a reference to the object itself, for easier
    chaining.

## Methods: Testing

The central methods of this package are devoted to testing the outcome
of a command execution.

All the following methods return the object's reference, so that
multiple tests can be chained one after another.

Before describing the methods, it's useful to point out what
characteristics are tested:

- _exit code_

    the command's exit code, typically provided by the command's `exit`
    function;

- _signal_

    a signal that might have forced the command's process to exit;

- _timeout_

    a timeout set when calling the command, which might have been hit
    (leading to termination of the command's process) or not;

- _stdout_

    what the command sends on the standard output;

- _stderr_

    what the command sends on the standard error;

- _merged_

    what the command sends on either output channels (standard error first,
    then standard output).

All test functions accept an optional last parameter to pass a custom
message to mark the text; if not present or undefined, it is
automatically generated based on the specific test and the command that
has been expanded.

The following test functions are available:

- `run_ok`

        $tc->run_ok(\%bindings_and_opts);
        $tc->run_ok(\%bindings_and_opts, $message);

    First call ["run"](#run) and then ["ok"](#ok) to do a new run with the provided
    parameters and then check that the run is successful.

- `run_failure_ok`

        $tc->run_failure_ok(\%bindings_and_opts);
        $tc->run_failure_ok(\%bindings_and_opts, $message);

    First call ["run"](#run) and then ["failure\_ok"](#failure_ok) to do a new run with the
    provided parameters and then check that the run is NOT successful.

- `ok`

        $tc->ok;
        $tc->ok('command successful');

    Check if the latest run was successful. This is defined by
    ["success" in Command::Template::Runner::Record](https://metacpan.org/pod/Command::Template::Runner::Record#success), that checks that neither a
    signal nor a non-0 exit code were returned.

- `failure_ok`

        $tc->failure_ok;
        $tc->failure_ok('command failed as expected');

    Check if the latest run was unsuccessful (this is considered a condition
    to pass the test, i.e. the test passes if the command fails).  This is
    defined by ["failure" in Command::Template::Runner::Record](https://metacpan.org/pod/Command::Template::Runner::Record#failure), that checks
    that neither a signal nor a non-0 exit code were returned.

Other test functions are described in the following subsections.

### Characteristic-specific successful tests

This type of test succeeds if the value corresponding to the specific
characteristic is 0.

- `exit_code_ok`

        $tc->exit_code_ok;
        $tc->exit_code_ok('exit code 0 as expected');

- `signal_ok`

        $tc->signal_ok;
        $tc->signal_ok('signal 0 as expected');

- `in_time_ok`

        $tc->in_time_ok;
        $tc->in_time_ok('timeout 0 as expected');

### Characteristic-specific failure tests

This type of test succeeds if the value corresponding to the specific
characteristic is different from 0.

- `exit_code_failure_ok`

        $tc->exit_code_failure_ok;
        $tc->exit_code_failure_ok('exit code different from 0 as expected');

- `signal_failure_ok`

        $tc->signal_failure_ok;
        $tc->signal_failure_ok('signal different from 0 as expected');

- `timed_out_ok`

        $tc->timed_out_ok;
        $tc->timed_out_ok('timeout different from 0 as expected');

### Characteristic-specific equality tests

This type of test succeeds is the value corresponding to the specific
characteristic is as specified.

- `exit_code_is`

        $tc->exit_code_is(0);
        $tc->exit_code_is(42, 'exit code is 42 as expected');

- `signal_is`

        $tc->signal_is(0);
        $tc->signal_is(9, 'killed without appeal');

- `timeout_is`

        $tc->timeout_is(0);
        $tc->timeout_is(5, 'timed out after 5 seconds');

- `stdout_is`

        $tc->stdout_is('foo bar baz');
        $tc->stdout_is('foo bar baz', 'standard output as expected');

- `stderr_is`

        $tc->stderr_is('foo bar baz');
        $tc->stderr_is('foo bar baz', 'standard error as expected');

- `merged_is`

        $tc->merged_is('foo bar baz');
        $tc->merged_is('foo bar baz', 'merge of standard output and error as expected');

### Characteristic-specific inequality tests

This type of test succeeds is the value corresponding to the specific
characteristic is different from what specified.

- `exit_code_isnt`

        $tc->exit_code_isnt(0);
        $tc->exit_code_isnt(42, 'exit code is 42 as expected');

- `signal_isnt`

        $tc->signal_isnt(0);
        $tc->signal_isnt(9, 'not killed without appeal');

- `timeout_isnt`

        $tc->timeout_isnt(0);
        $tc->timeout_isnt(5, 'timeout not 5 seconds');

- `stdout_isnt`

        $tc->stdout_isnt('foo bar baz');
        $tc->stdout_isnt('foo bar baz', 'standard output different from it');

- `stderr_isnt`

        $tc->stderr_isnt('foo bar baz');
        $tc->stderr_isnt('foo bar baz', 'standard error different from it');

- `merged_isnt`

        $tc->merged_isnt('foo bar baz');
        $tc->merged_isnt('foo bar baz', 'merge of standard output and error...');

### Characteristic-specific similarity (match) tests

This type of test succeeds is the value corresponding to the specific
characteristic matches a regular expression.

- `stdout_like`

        $tc->stdout_like(qr{(^mxs: foo | bar | baz)});
        $tc->stdout_like(qr{(^mxs: foo | bar | baz)}, 'standard output match');

- `stderr_like`

        $tc->stderr_like(qr{(^mxs: foo | bar | baz)});
        $tc->stderr_like(qr{(^mxs: foo | bar | baz)}, 'standard error match');

- `merged_like`

        $tc->merged_like(qr{(^mxs: foo | bar | baz)});
        $tc->merged_like(qr{(^mxs: foo | bar | baz)}, 'merged outputs match');

### Characteristic-specific unsimilarity (negated match) tests

This type of test succeeds is the value corresponding to the specific
characteristic does not match a regular expression.

- `stdout_unlike`

        $tc->stdout_unlike(qr{(^mxs: foo | bar | baz)});
        $tc->stdout_unlike(qr{(^mxs: foo | bar | baz)}, 'standard output no match');

- `stderr_unlike`

        $tc->stderr_unlike(qr{(^mxs: foo | bar | baz)});
        $tc->stderr_unlike(qr{(^mxs: foo | bar | baz)}, 'standard error no match');

- `merged_unlike`

        $tc->merged_unlike(qr{(^mxs: foo | bar | baz)});
        $tc->merged_unlike(qr{(^mxs: foo | bar | baz)}, 'merged outputs no match');

# BUGS AND LIMITATIONS

Minimul perl version 5.24.

Report bugs through GitHub (patches welcome) at
[https://github.com/polettix/Test-CLI](https://github.com/polettix/Test-CLI).

# AUTHOR

Flavio Poletti <flavio@polettix.it>

# COPYRIGHT AND LICENSE

Copyright 2021 by Flavio Poletti <flavio@polettix.it>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
