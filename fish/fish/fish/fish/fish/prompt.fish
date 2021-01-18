# Makes it so prompt_pwd isn't so aggressive with its abbreviating paths
set -x fish_prompt_pwd_dir_length 128

### Our custom hex color definitions

set hexcolor_cute_purple C300FF
set hexcolor_firey_orange FF8800
set hexcolor_cute_pink FB57D0

# Our suffixes for root and non-root respectively
set fish_suffix_root '#'
set fish_suffix_user '$'

set fish_send_notification 1
set fish_notification_threshold 10000


function fish_prompt --description "Write out the prompt"
    alias sudo /usr/bin/sudo
    # Store status of last user-executed command
    # before it's overwritten.
    set -l last_status $status


    # Initialize suffix variable (controls whether we're using $ or #)
    set -l suffix
    
     # Get percentage of free space on disk
    #set -l rpcnt (perl -e 'use Filesys::Df;print df("/")->{per};')   
    
    #set -l rpcnt (/etc/fish/bin/disk_percentage)   

    ### Initialize dynamic color vars

    # Working directory color changes based on whether we're root
    set -l color_cwd
    # Username color changes based on whether we're root
    set -l color_username
    # Status color changed based on whether status is zero
    set -l color_status
    # Disk percentage color changes based on how full the disk is
    set -l color_percent
    # Time color changes based on whether we're root
    set -l color_time

    ### Dynamic garbage -- code to change colors and stuff based on various conditions
   
    # Configure colors and suffix symbol based on whether or not we're root 
    switch "$USER"
        case root toor
            set color_cwd $fish_color_cwd_root
            set color_username $fish_color_username_root
            set color_time $fish_color_time_root
            set suffix $fish_suffix_root
        case '*'
            set color_cwd $fish_color_cwd
            set color_username $fish_color_username 
            set suffix $fish_suffix_user
            set color_time $fish_color_time
    end
    
    # Change status color based on whether it was zero
    if test $last_status -eq 0
        set color_status $fish_color_status_zero
    else
        set color_status $fish_color_status_nonzero
    end
    
    # Set disk percentage color based on how full disk is
    #if test $rpcnt -gt 90
    #    set color_percent $fish_color_percent_worst
    #else if test $rpcnt -gt 50
    #    set color_percent $fish_color_percent_bad
    #else
    #    set color_percent $fish_color_percent_good
    #end
    
    # Initialize a bunch of little variables to display
    set -l wd (prompt_pwd)
    set -l host (cat /etc/hostname)
    set -l time (date '+%H:%M:%S')

    ### The following creates a set of variables containing color characters
    ### These variables are extremely abbreviated so that our final prompt line instructions are vaguely readable and not too verbose

    # Color for current user
    set Cusr (set_color $color_username)
    # Color for delimiters and the suffix
    set Cdlm (set_color $fish_color_delimiter)
    # Color for status of previous command
    set Cstat (set_color $color_status)
    # Normal color, for end of prompt
    set Cnorm (set_color normal)
    # Color for hostname
    set Chost (set_color $fish_color_hostname)
    # Color for current working directory
    set Ccwd (set_color $color_cwd)
    # Color for percentage of / taken up
    set Cpcnt (set_color $color_percent)
    # Color for time
    set Ctime (set_color $color_time)   


    ### Endgame: it's finally time for us to print our prompt line!
    
    # Line 1: Makes something of a format like "user@hostname /some/path (status) (drive percentage full)"
    #
    echo -s $Cusr "$USER" $Cdlm '@' $Chost $host ' ' $Ccwd $wd $Cdlm" ("$Ctime $time \
    $Cdlm") (" $Cstat $last_status $Cdlm ')' 
    #(' $Cpcnt $rpcnt '%' $Cdlm ')'

    # Line 2: Just prints the suffix (# or $) and normalizes font color for user input
    
    echo -s $Cdlm $suffix  $Cnorm ' '
end

function fish_prompt
    # Store status of last user-executed command
    # before it's overwritten.
    set -l last_status $status

    set current_working_dir (pwd)

    # Since disabling the path abbreviation of prompt_pwd seems glitchy,
    # I implemented my own solution
    if test "$current_working_dir" = "$HOME"
        set current_working_dir '~'
    end

    set root_disk_percent (df / -H | tail -n 1 | awk '{ print $5 " " $1 }'| cut -f1 -d '%')
    set color_percent brgreen
    # Set disk percentage color based on how full disk is
    if test $root_disk_percent -gt 90
        set color_percent brred
    else if test $root_disk_percent -gt 50
        set color_percent FF8800
    end

    set color_status brred
    if test $last_status -eq 0
        set color_status brgreen
    end


    set user_color ff00bf
    set path_color FB57D0
    set prompt_char '$'
    switch "$USER"
        case root toor
            set user_color brred
            set path_color brred
            set prompt_char '#'
    end

    set_color $user_color
    echo -nes "$USER"
    set_color bryellow
    echo -nes '@'
    #set_color C300FF
    set_color (string sub -l 6 (md5sum /etc/hostname))
    echo -nes (cat /etc/hostname) ' '

    set_color bryellow
    echo -nes '('
    set_color brcyan
    echo -nes (date '+%H:%M:%S')

    set_color bryellow
    echo -nes ') ('

    set_color $color_percent
    echo -nes "$root_disk_percent%"

    set_color bryellow
    echo -nes ') ('

    set_color $color_status
    echo -nes  "$last_status"

    set_color bryellow
    echo -nes ') '

    set_color $path_color
    # Disable shitty path shrinking
    set -x fish_prompt_pwd_dir_length 0
    
    echo -nes "$current_working_dir" ' '
    set_color bryellow
    echo -nes "\n$prompt_char "
    set_color normal
end


## Optional: add additional right-justified elements to terminal prompt
#function fish_right_prompt
    #set Cms (set_color $fish_color_mscount)
    #set Cnorm (set_color normal)
    #echo -s $Cms $CMD_DURATION $Cnorm
#end

function fish_title
    echo (cat /etc/hostname)": "(prompt_pwd)
end


# Allows FISH to support Ctrl+backspace for deleting the previous word
# NOTE: There are apparently inconsistencies in the char terminals send when the user presses Ctrl+Backspace
# If you find entire words disappear every time you press back button, try disabling this
bind \cH backward-kill-path-component

