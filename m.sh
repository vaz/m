# ䷀ ䷁ ䷂ ䷃ ䷄ ䷅ ䷆ ䷇ ䷈ ䷉ ䷊ ䷋ ䷌ ䷍ ䷎ ䷏ ䷐ ䷑ ䷒ ䷓ ䷔ ䷕ ䷖ ䷗ ䷘ ䷙ ䷚ ䷛ ䷜ ䷝ ䷞ ䷟ 
#
# m.sh
#
# in the spirit of rupa deadwyler's z.sh
# by Vaz ䷣ 縷々2013年 under the WTFPL
# 
# Install:
#   - you can set $_M_CMD to change the command name (default b)
#   - you can set $_M_DATA to change the data file (default ~/.b)
#   - source this file in your .bashrc or .zsh
#         . /path/to/m.sh
#   - now bookmark some directories!
#
#
# Remark:
#   I have no idea if this actually works in zsh or any shell
#   other than bash.
#
# ䷠ ䷡ ䷢ ䷣ ䷤ ䷥ ䷦ ䷧ ䷨ ䷩ ䷪ ䷫ ䷬ ䷭ ䷮ ䷯ ䷰ ䷱ ䷲ ䷳ ䷴ ䷵ ䷶ ䷷ ䷸ ䷹ ䷺ ䷻ ䷼ ䷽ ䷾ ䷿ 

# TODO: fuzzy matching, tab completion


# warn and debug
__m_warn ()  { echo "${_M_CMD:-m}: $@" >&2; }

__m () {
  # usage instructions {{{

  local usage
  read -d '' usage <<EOF
Usage:
    m [-l|--list]
    m [-s] [--add <name>[=<path>]] [--delete <name>] [<name>=[<path>]] ...
    m [-s] <target name>

    The -s (or --follow) flag will resolve symlinks when saving or jumping
    to a path.  Paths are expanded and in the --add command will default to
    the current directory.

EOF

  # }}}
  # check data file {{{

  local fileheader="###m.sh-data###"
  local datafile="${_M_DATA:-$HOME/.m-data}"

  # if we don't own it, that's no good.
  [ -f "$datafile" -a ! -O "$datafile" ] && {
    __m_warn "we don't own the data file $datafile"; return
  }

  # quickly check if it appears to be the right file
  [ -f "$datafile" ] && [ "$(cat "$datafile")" != "" ] && {
    [ "$(head -n1 $datafile)" = "$fileheader" ] || {
      __m_warn "file $datafile doesn't seem to be the data file"; return
    }
  } || {
    # initialize data file if it didn't exist or was empty
    echo "$fileheader" > "$datafile"
  }

  # }}}
  # parse arguments {{{

  local addlist deletelist
  declare -a addlist=( )
  declare -a deletelist=( )

  local list=yes follow= jump=

  while [ "$1" ]; do case "$1" in
    -h|--help)
      echo "$usage"; return ;;

    -s|--follow)
      follow='-P' ;;

    -a|--add)
      [ "$2" ] && { addlist+=( "$2" ); } || {
        __m_warn "--add takes an argument"; return 1;
      }; shift ;;

    -d|--delete)
      [ "$2" ] && { deletelist+=( "$2" ); } || {
        __m_warn "--delete takes an argument"; return 1;
      }; shift ;;

    -l|--list)
      list=yes ;;

    -*)
      __m_warn "invalid option: $1" ;;

    *)
      local lhs=$(expr "$1" : "\(.*\)=")
      local rhs=$(expr "$1" : ".*=\(.*\)")

      [ "$lhs" ] && {
        [ "$rhs" ] && {
          addlist+=( "$1" )
        } || {
          deletelist+=( "$lhs" )
        }
      } || jump="$jump $1" ;;
  esac; shift; done

  # }}}
  # jump {{{

  [ -n "$jump" ] && {
    # don't try to add stuff and jump at the same time
    (( ${#addlist[@]} + ${#deletelist[@]} )) && { echo "$usage"; return 1; }

    local target=$(grep -e "^$jump=" "$datafile" | cut -d= -f2)
    [ -z "$target" ] && { warn "no such bookmark: $jump"; return 1; }
    cd "$target"
    return 0
  }
  # }}}
  # add {{{
  local arg

  for arg in ${addlist[@]}; do
    local name="$(echo "$arg" | cut -d= -f1)"
    local path="$(echo "$arg" | cut -d= -f2)"

    [ "$name" = "$path" ] && path=.

    [ ! -d "$path" ] && { __m_warn "$path: no such directory"; return; }

    # expand the path
    path=$(builtin cd "$path" 2>/dev/null; echo $(pwd $follow))

    local entry="$(grep -e "^$name=" "$datafile")"
    [ -z "$entry" ] && {
      echo "$name=$path" >> "$datafile"
    } || {
      sed -ie "s:^$name=.*$:$name=$path:" "$datafile"
    }
    list=no
  done

  # }}}
  # delete {{{

  for arg in ${deletelist[@]}; do
    # arg="$(echo $arg | cut -d= -f1)"
    sed -ie "/^$arg=/ d" "$datafile"
    list=no
  done

  # }}}
  # list {{{

  [ $list = yes ] && tail -n+2 "$datafile"
  return 0

  # }}}
}

alias ${_M_CMD:-m}='__m 2>&1'
