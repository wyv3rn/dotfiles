-- thanks to https://gist.github.com/h1k3r/089d43771bdf811eefe8
function get_hostname()
    local f = io.popen ("/bin/hostname")
    local hostname = f:read("*a") or ""
    f:close()
    hostname =string.gsub(hostname, "\n$", "")
    return hostname
end
