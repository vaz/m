# `m`

## bookmark and jump to paths

`m` lets you bookmark paths and jump quickly to them.  It's a little tool written in the spirit of [`z`], yo.

[`z`]: https://github.com/rupa/z

Homepage: https://github.com/vaz/m

### INSTALLATION

Source it from your `~/.bashrc` or `~/.zsh` (not tested in zsh, yet!):

```sh
    . /path/to/m.sh
```

### USAGE

```text
Synopsis:
    m [-h] [--list]
    m [-s] [--add name[=path]] [--delete name] [name=[path]] ...
    m [-s] name

Options:
    -s|--follow             resolve symlinks when saving/jumping
    -a|--add name[=path]    path defaults to \$PWD
    -d|--delete name
    -h|--help               you're looking at it

Examples:
    m --add foo             bookmark current directory as 'foo'
    m -s --a tmp=/tmp       bookmark /tmp (resolves symlinks first) as 'tmp'
    m foo=.                 bookmark current directory as 'foo'

    m --delete etc          delete bookmark named 'etc'
    m foo=                  delete bookmark named 'foo'

    m foo                   jump to path bookmarked with name 'foo'
    m -s foo                jump to path resolving symlinks

    m --list                list bookmarks
    m                       list bookmarks
```
    
### ENVIRONMENT

A function `__m` is defined, and then aliased to using the value of `$_M_CMD` (defaults to `m`).

The bookmarks are stored in a file specified in `$_M_DATA` (default `~/.m-data`).

You can configure these variables in your `.bashrc` or `.zshrc` before sourcing `m.sh`.
