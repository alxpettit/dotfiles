# Entry-point FISH config file
# Copyleft (C) Alexandria Pettit, GNU GPLv3

if test "$FUTIL_CONFIGS_LOADED" != true
    set FUTIL_DEBUG_MODE false
    set FUTIL_CONF_DIR /etc/fish
    set FUTIL_CONF_D_PATH "$FUTIL_CONF_DIR/conf.d"


    # ESSENTIAL FISH UTIL FUNCTIONS

    function futil_debug_echo
        if test "$FUTIL_DEBUG_MODE" = true
            echo $argv
        end
    end

    function futil_source
        futil_debug_echo "Sourcing: $argv[1]"
        source "$argv[1]"
    end

    function futil_source_config_file
        if test -e "$FUTIL_CONF_DIR/$argv[1]_local.fish"
            futil_source "$FUTIL_CONF_DIR/$argv[1]_local.fish"
        else
            futil_source "$FUTIL_CONF_DIR/$argv[1].fish"
        end
    end

    function futil_import_env_var_file
        for line in (cat $argv[1])
            futil_debug_echo "Parsing: $line"
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

    function futil_import_conf_d
        for file in $FUTIL_CONF_D_PATH/*
            source "$FUTIL_CONF_D_PATH/$file"
        end
    end

    function futil_update_path
	# Ordered from the most to the least secure path, to reduce exploitability
	# Overrides may be symlinked from /usr/local/bin/ to target, if so desired
        set provisional_path_list /cbin /var/lib/flatpak/exports/bin/ {/var/lib,}/snap/bin {/usr/local,/usr,}/{bin,sbin} $PATH $HOME/cbin $HOME/.{cargo,nimble}/bin/ 
        set NEW_PATH
        for item in $provisional_path_list
            futil_debug_echo "Checking path: $item"
            set -a NEW_PATH (futil_add_to_path $item $NEW_PATH)
        end
        set -x PATH $NEW_PATH
    end

    futil_update_path

    futil_import_conf_d


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
    futil_import_env_var_file "$FUTIL_CONF_DIR/env.conf"
end

set FUTIL_CONFIGS_LOADED true
