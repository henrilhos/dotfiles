function sail
    if test -f sail
        sh sail $argv
    else
        sh vendor/bin/sail $argv
    end
end
