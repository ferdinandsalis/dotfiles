function _fzf_docker_containers --description "Manage Docker containers with FZF"
    set -f container (docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}" | tail -n +2 | fzf --preview 'docker logs --tail 50 {1}' --preview-window down:50% | awk '{print $1}')
    
    if test -n "$container"
        set -f action (echo "logs\nstart\nstop\nrestart\nremove\nshell" | fzf --header="Select action for container $container")
        
        switch $action
            case logs
                docker logs -f $container
            case start
                docker start $container
            case stop
                docker stop $container
            case restart
                docker restart $container
            case remove
                docker rm $container
            case shell
                docker exec -it $container /bin/sh
        end
    end
end