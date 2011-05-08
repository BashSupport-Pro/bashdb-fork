# -*- shell-script -*-
# show.sh - Show debugger settings
#
#   Copyright (C) 2002, 2003, 2006, 2007, 2008, 2010
#   2011 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

typeset -A _Dbg_debugger_show_commands
typeset -A _Dbg_command_help_show

# Help routine is elsewhere which is why we have '' below.
_Dbg_help_add show '' 1 _Dbg_complete_show

# Load in "show" subcommands
for _Dbg_file in ${_Dbg_libdir}/command/show_sub/*.sh ; do
    source $_Dbg_file
done

# Command completion for a condition command
_Dbg_complete_show() {
    _Dbg_complete_subcmd show
}

_Dbg_do_show() {
    typeset subcmd=$1
    (($# >= 1)) && shift
    typeset label=$1
    (($# >= 1)) && shift

    # Warranty, copying, directories, aliases, and warranty are omitted below.
    typeset -r subcmds="annotate args autoeval autolist basename debug different editing history linetrace listsize prompt trace-commands width"

    if [[ -z $subcmd ]] ; then 
	typeset thing
	for thing in $subcmds ; do 
	    _Dbg_do_show $thing 1
	done
	return 0
    elif [[ -n ${_Dbg_debugger_show_commands[$subcmd]} ]] ; then
	${_Dbg_debugger_show_commands[$subcmd]} "$label" "$@"
	return 0
    fi

    case $subcmd in 
	com | comm | comma | comman | command | commands )
	    typeset -i default_hi_start=_Dbg_hi-1
	    if ((default_hi_start < 0)) ; then default_hi_start=0 ; fi
	    typeset hi_start=${2:-$default_hi_start}
	    
	    eval "$_seteglob"
	     case $hi_start in
	    	"+" )
	    	    ((hi_start=_Dbg_hi_last_stop-1))
	    	    ;;
	    	$int_pat | -$int_pat)
                     ;;
	    	* )
	    	    _Dbg_msg "Invalid parameter $hi_start. Need an integer or '+'"
	    esac
	    eval "$_resteglob"
	    
	    typeset -i hi_stop=hi_start-10
	    _Dbg_do_history_list $hi_start $hi_stop
	    _Dbg_hi_last_stop=$hi_stop
	    ;;
	hi|his|hist|histo|histor|history)
	    _Dbg_printf "%-12s-- " history
	    _Dbg_msg \
		"  filename: The filename in which to record the command history is $_Dbg_histfile"
	    _Dbg_msg \
		"  save: Saving of history save is" $(_Dbg_onoff $_Dbg_set_history)
	    _Dbg_msg \
		"  size: Debugger history size is $_Dbg_history_length"
	    ;;

	lin | line | linet | linetr | linetra | linetrac | linetrace )
	    [[ -n $label ]] && label=$(_Dbg_printf_nocr "%-12s: " 'line tracing')
	    [[ -n $label ]] && label='line tracing: '
	    typeset onoff="off."
	    (( _Dbg_set_linetrace != 0 )) && onoff='on.'
	    _Dbg_msg \
		"${label}Show line tracing is" $onoff
	    _Dbg_msg \
		"${label}Show line trace delay is ${_Dbg_linetrace_delay}."
	    ;;

	lo | log | logg | loggi | loggin | logging )
	    shift
	    _Dbg_do_show_logging $*
	    ;;
	sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
	    [[ -n $label ]] && label=$(_Dbg_printf_nocr "%-12s: " 'showcommmand')
	    _Dbg_msg \
		"${label}Show commands in debugger prompt is" \
		"$_Dbg_set_show_command."
	    ;;
	t|tr|tra|trac|trace|trace-|tracec|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
	    [[ -n $label ]] && label='trace-commands: '
	    _Dbg_msg \
		"${label}State of command tracing is" \
		"$_Dbg_set_trace_commands."
	    ;;
	v | ve | ver | vers | versi | versio | version )
	    _Dbg_do_show_version
	    ;;
	w | wa | war | warr | warra | warran | warrant | warranty )
	    _Dbg_do_info warranty
	    ;;
	*)
	    _Dbg_errmsg "Unknown show subcommand: $subcmd"
	    typeset -a list; list=(${subcmds[@]})
	    typeset columnized=''
	    typeset -i width; ((width=_Dbg_set_linewidth-5))
	    typeset -a columnized; columnize $width
	    typeset -i i
	    _Dbg_errmsg "Show subcommands are:"
	    for ((i=0; i<${#columnized[@]}; i++)) ; do 
		_Dbg_errmsg "  ${columnized[i]}"
	    done
	    return 1
    esac
    return $?
}
