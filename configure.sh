#!/bin/bash

screen_src=""
serial=""
response=""

lcd_interface () {
    read -p "lcd address width [4/8]: " response

    if [ $response == 4 ]; then
        screen_src=screen_4bit.s
    elif [ $response == 8 ]; then
        screen_src=screen_8bit.s
    else
        echo "invalid response"
        exit 1
    fi

    rm $PWD/lcd/screen.s 2> /dev/null
    ln -s $PWD/lcd/$screen_src $PWD/lcd/screen.s
}

serial_connection () {
    read -p "using serial? [y/n]: " response

    if [[ $response = [yY] ]]; then
        serial=y
    elif [[ $response = [nN] ]]; then
        serial=n
    else
        echo "invalid response"
        exit 1
    fi
}


lcd_interface
serial_connection

