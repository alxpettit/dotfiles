# Entry-point FISH config file
# Copyleft (C) Alexandria Pettit, GNU GPLv3

if test "$FISH_CONFIGS_LOADED" != true

    set FISH_CONFIG_DIR /etc/fish


    # ESSENTIAL FISH UTIL FUNCTIONS

    function futil_source_config_file
        if test -e "$FISH_CONFIG_DIR/$argv[1]_local.fish"
            source "$FISH_CONFIG_DIR/$argv[1]_local.fish"
        else
            source "$FISH_CONFIG_DIR/$argv[1].fish"
        end
    end

    function futil_import_env_var_file
        for line in (cat $argv[1])
            # If string isn't comment
            if not string match --regex -q  '^\s*#.*' "$line"
                set -xg (string split '=' "$line")
            end
        end
    end

    function futil_add_to_path
        set new_item "$argv[1]"
        if test -e "$new_item"
            if not contains "$new_item" $argv[2..-1]
                echo -n "$new_item"
            end
        end
    end

    function futil_update_path
        set provisional_path_list /cbin {/var/lib,}/snap/bin {/usr/local,/usr,}/{bin,sbin} $PATH $HOME/bin
        set NEW_PATH
        for item in $provisional_path_list
            set -a NEW_PATH (futil_add_to_path $item $NEW_PATH)
        end
        set -x PATH $NEW_PATH
    end

    futil_update_path

    if command -sq essh
        function ssh
            "essh" $argv
        end
        set rsync_path (command -s rsync)
	    if test -n $rsync_path
        	function rsync
                $rsync_path "--rsh=$target_path" $argv
        	end
	    end
    end

    # Environment variables
    # Typical instructions suggest to load envs iff `status --is-login`,
    # but that doesn't actually give you what you want in most DEs.
    # Note: MOST_PATH is not to my knowledge paid attention to by any applications
    # but it seems like the sort of thing that ought to be available to them.
    # Export is probably superfluous on MOST_PATH

    # TODO: have environment variables try to be set on login, and if they are, set a marker to disable loading them each time we load!

    if test -e '/etc/locale.conf'
        futil_import_env_var_file '/etc/locale.conf'
    end

    if status --is-interactive
        # disabled this code chunk because most sucks. >.>
        # Imagine writing a pager most people use to get colorful `man` pages,
        # and then not supporting `\b`.
        # Like, half the time when you're using man pages, you want to filter for something like `-l\b`.

        #set -x MOST_PATH (which most)
        #if test -n MOST_PATH
            #set -x PAGER $MOST_PATH
            #set -x MANPAGER $MOST_PATH
        #end

        if test -e '/usr/bin/thefuck'
            thefuck --alias | source
        end

        # Abbreviation & alias declarations go here
        futil_source_config_file alias
        futil_source_config_file prompt
    end

    # Any overrides for above would go here, naturally
    futil_import_env_var_file "$FISH_CONFIG_DIR/env.conf"
end

set FISH_CONFIGS_LOADED true
