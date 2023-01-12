alias clean="./clean.sh"
alias build="./build.sh"
alias wicinst="./wicinst.sh"
alias wicshell="./wicshell.sh"
alias wicqemu="./start-qemu.sh"
alias makeova="./makeova.sh"
alias buildperf="./check-build-perform.sh"

function 7z() {
    local total_ram used_ram limit
    # Get the total amount of RAM
    total_ram=$(free -b | awk '/^Mem:/{print $2}')
    # Get the amount of used RAM
    used_ram=$(free -b | awk '/^Mem:/{print $3}')
    # Set a limit on the amount of RAM that can be used by the 7z process
    # as the total amount of RAM minus the used RAM
    limit=$(( total_ram - used_ram ))

    if ulimit -v | grep -q unlimited; then
        ulimit -v $limit
    else
        declare -i ulim=$(ulimit -v)
        if [ $ulim -gt $limit ]; then
            ulimit -v $limit
        fi
    fi
    command 7z "$@"
}
export -f 7z

