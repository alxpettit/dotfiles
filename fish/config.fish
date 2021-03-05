# Entry-point FISH config file
# Copyleft (C) Alexandria Pettit, GNU GPLv3 

if test "$FISH_CONFIGS_LOADED" != true

    set FISH_CONFIG_DIR /etc/fish

    function source_config_file
        source "$FISH_CONFIG_DIR/$argv[1].fish"
        if test -e "$FISH_CONFIG_DIR/$argv[1]_local.fish"
            source "$FISH_CONFIG_DIR/$argv[1]_local.fish"
        end
    end

    function import_env_var_file
        for line in (cat $argv[1])
            # If string isn't comment
            if not string match --regex -q  '^\s*#.*' "$line"
                set -xg (string split '=' "$line")
            end
        end
    end

    set ESSH_PATH (which essh 2> /dev/null)
    set SSH_PATH (which ssh 2> /dev/null)
    set RSYNC_PATH (which rsync 2> /dev/null)

    function ssh
        if test -n $ESSH_PATH
            set target_path $ESSH_PATH
        else
            set target_path $SSH_PATH
        end
        "$target_path" $argv
    end

    function rsync
        if test -n $ESSH_PATH
            set target_path $ESSH_PATH
        else
            set target_path $SSH_PATH
        end
        "$RSYNC_PATH" "--rsh=$target_path" $argv
    end

    # Environment variables
    # Typical instructions suggest to load envs iff `status --is-login`,
    # but that doesn't actually give you what you want in most DEs.
    # Note: MOST_PATH is not to my knowledge paid attention to by any applications
    # but it seems like the sort of thing that ought to be available to them.
    # Export is probably superfluous on MOST_PATH

    # TODO: have environment variables try to be set on login, and if they are, set a marker to disable loading them each time we load!

    if test -e '/etc/locale.conf'
        import_env_var_file '/etc/locale.conf'
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

        source_config_file functions

        # Abbreviation & alias declarations go here
        source_config_file alias

        source_config_file prompt
    end

    # Any overrides for above would go here, naturally
    import_env_var_file "$FISH_CONFIG_DIR/env.conf"
end

set FISH_CONFIGS_LOADED true
