set essh_path (command -s essh)
if test -n $essh_path
    #futil_debug_echo "ESSH path detected: $essh_path"
    function ssh
        #futil_debug_echo "ssh func wrapping called!"
        "$essh_path" $argv
    end
    set rsync_path (command -s rsync)
    if test -n $rsync_path
        #futil_debug_echo "Rsync path detected: $rsync_path"
        function rsync
            #futil_debug_echo "rsync func wrapping called!"
            $rsync_path "--rsh=$essh_path" $argv
        end
    end
end