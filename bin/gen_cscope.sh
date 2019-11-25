#!/bin/bash -e
find -L $PWD                                                              \
        -path "$PWD/arch/*" ! \( -path "$PWD/arch/x86*" \) -prune -o       \
        -path "$PWD/kernel*"                                             \
        -path "$PWD/fs*"                       \
        -path "$PWD/net*"                                           \
        -path "$PWD/virt*"                                          \
        -path "$PWD/ipc*"                                           \
        -path "$PWD/mm*"                                            \
        -path "$PWD/init*"                                          \
        -path "$PWD/tools*"                                         \
        -path "$PWD/ipc*"                                           \
        -path "$PWD/include*"                                            \
        -path "$PWD/lib*"                                \
        -path "$PWD/drivers*"                  \
        -path "$PWD/crypto*"                    \
        -path "$PWD/security*"                  \
        -path "$PWD/block*"                    \
        -path "$PWD/samples*" -prune -o                  \
        -path "$PWD/Documentation*"             \
        -path "$PWD/firmware*" -prune -o                 \
        -path "$PWD/sound*" -prune -o                    \
        -path "$PWD/.git*" -prune -o                     \
        -path "$PWD/scripts*" -prune -o                  \
        -path "$PWD/usr*" -prune -o                      \
        -path "$PWD/block*" -prune -o                    \
        -name "*.[chxsS]" -print > $PWD/cscope.files
cscope -b -q -k
printf "\nCscope Rebuilt database for %d files \n" $( cat $PWD/cscope.files | wc -l)
