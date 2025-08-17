function ports --description "Show processes listening on ports"
    if test (uname) = "Darwin"
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    else
        sudo netstat -tulpn
    end
end