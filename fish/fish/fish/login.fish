source functions.fish

# Abbreviation & alias declarations go here
source alias.fish

if test -e /etc/fish/env_local.fish
    source /etc/fish/env_local.fish
end

# Environment variables
source /etc/fish/env.fish

