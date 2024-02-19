if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting ""

abbr -a vim nvim
abbr -a apt sudo apt
abbr -a install sudo apt install -y
abbr -a remove sudo apt remove
abbr -a gst git status
abbr -a ga git add
abbr -a gaa git add --all
abbr -a gc git commit -m
abbr -a gp git push
abbr -a gd git diff
abbr -a c wl-copy
abbr -a p wl-paste
abbr -a dcu docker compose up
abbr -a dcd docker compose down

# Source: https://github.com/TheR1D/shell_gpt/issues/128
# Alias sgpt as ai without quotes
function ai
    set -l first_char (string sub -s 1 -l 1 -- $argv[1])
    if [ "$first_char" = "-" -o "$first_char" = "—" ]
        sgpt $argv[1] (string join " " -- $argv[2..-1])
    else
        sgpt (string join " " -- $argv)
    end
end

# Quick interactive chat
# TODO: Improve
function aic
    set -gx LC_ALL C
    set -l chat_id (cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
    set -l first_char (string sub -s 1 -l 1 -- $argv[1])

    if [ "$first_char" = "-" -o "$first_char" = "?^?^?" ]
        sgpt --repl $chat_id $argv[1] (string join " " -- $argv[2..-1])
    else
        sgpt --repl $chat_id (string join " " -- $argv)
    end

    echo "Chat ID: $chat_id"
end

# Jenv
status --is-interactive; and source (jenv init -|psub)

