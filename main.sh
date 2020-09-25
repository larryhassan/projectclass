#!/usr/bin/env bash

set -eu

# Main bash language cheatsheet.

# The goal is to make this fully executable and automatic self checking,
# but currently it should not be run as it may do bad things:
# copy and paste individual commands of interest on a shell instead.

## Comments

    echo #

  # Escape comment:

    echo \#

  # If a number sign appears in the middle of a string, no need to escape it:

    echo a#b

  # But you should anyways because it is insane. If there is a space, it becomes a comment again:

    echo a #b

## Help

  # Prints help on a built-in commands. The information shown is the same as in the highly recommended:

    #man bash

  # Bash extension.

  # Bash built-in

  # View all built-in commands:

    help

  # Get help on an specific command:

    help help
    help for

## Spaces

  # More than one tabs or spaces are useless like in C.

  # Indentation is not required. Google recommends 2 spaces: Google says 2 spaces: http://google-styleguide.googlecode.com/svn/trunk/shell.xml?showone=Indentation#Indentation
  # Other styles: <http://unix.stackexchange.com/questions/39210/whats-the-standard-for-indentation-in-shell-scripts>

  # `;` can be used to separate commands much like in c:

    echo a; echo b

  # Unlike C, newlines at the end od a command imply `;`:

    echo a
    echo b

  # So you can't use newlines at will as you can in C

    init_test() {
      wd="`pwd`"
      tmp="`mktemp -d`"
      cd $tmp
    }

    cleanup_test() {
      cd "$wd"
      rm -r "$tmp"
    }

# Execute file oustide PATH:

  echo "echo a" > a
  chmod 777 a
  ./a
  #a
  `realpath a`
  #a

## source

## dot

## .

  # Same as copy pasting commands from another file in the current shell.

  # Different from executing the file in a subshell!

  # Some people recommend using extension `.bashrc` for files that are primarily meant to be sourced.

    a=b
    echo 'a=c' > a.bashrc
    . a.bashrc
    [ "$a" = "c" ] || exit 1

  # Bash also supports a `source` operator:

    source a.bashrc

  # However don't use it as it is not POSIX 7.

## Variable substitution

## Parameter expansion

## ${}

  # Replace a variable by its value.

    a='printf b'
    [ $($a) = b ] || exit 1

  # Inside double quotes, variable substitution can happen.

    a=b
    b="$a"
    [ $b = b ] || exit 1

    a=b
    b="${a}c"
    [ $b = bc ] || exit 1

  # Cannot happens inside single quoted strings.

  # Escape:

    a=b
    [ "\$a" = '$a' ] || exit 1

  # Single dollars become literal dolars:

    [ "$" = "\$" ] || exit 1
    [ "$ " = "\$ " ] || exit 1

  # But I woud not rely on such obscure behaviour.

  ## Environment variables

    # It is not possible to set an environment variable for a single command:

      A=a
      [ "$(env A=b echo "$A")" = "a" ] || exit 1
      [ "$A" = "a" ] || exit 1

  ## Expansion

    # Variables are not called variables, but parameter expansion for a reason:
    # they expand at an early stage, and whatever they expand to is evaluated afterwards.

    # This means for instance that you can use variables to store command names and execute them later:

      a="printf"
      [ "$("$a" b)" = "b" ] || exit 1

    # Word splitting however happens before, so the following fails:

      a="printf"
      [ "$("$a")" = "b" ] || exit 1

    # With:

      #printf b: command not found

    # Because bash is treating "printf b" as a single command.

  ## Parameters are not expand recursivelly

    # Goes for `$`, quotes, etc.

      b=c
      a='$b'
      [ "$a" = '$b' ] || exit 1
      a="$b"
      [ "$a" = c ] || exit 1

    # One possibility is to use eval:
    # http://stackoverflow.com/questions/2005192/how-to-execute-a-bash-command-stored-as-a-string-with-quotes-and-asterisk

  ## Dynamic variable name

  ## Store variable name inside a variable and set it

    # http://stackoverflow.com/questions/16553089/bash-dynamic-variable-names

      a=b
      # Command not found: b=c
      #$a=c

    # `eval` workaround

      b=0
      a=b
      eval "$a=1"
      [ "$b" = 1 ] || exit 1

    ## declare

      # bash extension to set properties of variables.

        b=0
        a=b
        declare $a=1
        [ "$b" = 1 ] || exit 1

  ## Modifiers in parameter expansion

    # String length:

      s='abcd'
      [ ${#s} -eq 4 ] || exit 1

    # Substrings:

      s='abcd'
      [ ${s:0:1} = 'a'  ] || exit 1
      [ ${s:1:1} = 'b'  ] || exit 1
      [ ${s:0:2} = 'ab' ] || exit 1
      [ ${s:2}   = 'cd' ] || exit 1

    # You can do certain glob operations on strings:

      s='12223'

    # Remove shortest matching preffix:

      [ ${s#1*2} = '223' ] || exit 1

    # Uses pattern matching notation to replace.

    # Mnemonic:

    # - `#` (under 3) comes before `%` (under 5) (left of qwerty) so it is the prefix, and not suffix
    # - `##` has more characters than `#`, so it is the longest match possible

    # Remove longest matching preffix

      [ ${s## 1*2} = '3' ] || exit 1

    # Mnemonic: two `## ` is for long, one `#` is for short

    # Remove shortest matching suffix:

      [ ${s%2*3} = '122' ] || exit 1

    # Remove longest matching suffix:

      [ ${s%%2*3} = '1' ] || exit 1

    # Alternate values: <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02>

    # Check if variable is unset (not null):

      var=''
      [ -z "${var+a}" ] && exit 1
      unset var
      [ -z "${var+a}" ] || exit 1

    ## :-

      # ${a:-b}: expand to `$a` if `a` is neither unset nor null, and expand to `b` otherwise.

    ## :+

      # ${a:+b}: expand to b if a is neither unset nor null. Expand to nothing otherwise:

        x='a'
        [ "${x:+b}" = 'b' ] || exit 1
        unset x
        [ -z "${x:+b}" ] || exit 1

      # Application 1: check if variable is unset or null:

        x='a'
        [ -z "${x:+a}" ] && exit 1
        x=''
        [ -z "${x:+a}" ] || exit 1
        unset x
        [ -z "${x:+a}" ] || exit 1

      # Application 1: only add path separator if the prefix is not null:

        pref='a'
        path="${pref}${pref:+/}b"

      # This allows relative paths

    # Important distinction when running with `-u`, where `[ -z "$VAR" ]` would give an error.
    # This often bytes when running scripts that use `PS1` to check if running interactively with `[ -z "$PS1" ]`,
    # when you want to source them from a non interactive script like a Vagrant provision script.

    ## Applications

      # Get file extension or path without the extension:

        s='a/b.ext'
        [ ${s%.*}  = 'a/b' ] || exit 1
        [ ${s##*.} = 'ext' ] || exit 1

  ## unset

      a=''
      unset a
      [ -z "${a+a}" ] || exit 1

  ## readonly

    # POSIX 7:
