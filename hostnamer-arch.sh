#!/bin/bash
#This "Hostnamer" script helps you set a randomly generated or fixed hostname on Arch-based systems with a little GUI.
#
#This is free and unencumbered software released into the public domain.
#
#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.
#
#In jurisdictions that recognize copyright laws, the author or authors
#of this software dedicate any and all copyright interest in the
#software to the public domain. We make this dedication for the benefit
#of the public at large and to the detriment of our heirs and
#successors. We intend this dedication to be an overt act of
#relinquishment in perpetuity of all present and future rights to this
#software under copyright law.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
#OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#OTHER DEALINGS IN THE SOFTWARE.
#
#For more information, please refer to <http://unlicense.org/>
#
if [ "$(id -u)" != "0" ]; then
zenity --error --text "Error: Script must be run as root (try sudo?)" 1>&2
exit 1 
fi ##checks if we are root, if not prompt the user and quit.

if [ -f /usr/share/dict/words ]
then
    ##tests if we have a dictionary, if not fails at bottom of this script
	zenity --question --text "Welcome to Hostnamer! \n This little script helps you reset your hostname. \n Do you wish to proceed?"
	rc=$?

	if [ "${rc}" == "0" ]; then
	## answer="yes"
	zenity --question --text "Do you want to provide a hostname? \n(Otherwise we'll generate a cool random one for you)"

	rc=$?

	if [ "${rc}" == "0" ]; then
	## answer="yes"
	hostAnswer=$(zenity --entry --text "What hostname would you like?" --entry-text "localhost")
	hostnamectl set-hostname $hostAnswer
	sed -i '/127.0.0.1/c\127.0.0.1       localhost.localdomain   localhost '$hostAnswer'' /etc/hosts
	##properly sets our new host in /etc/hosts file
	hostname $hostAnswer
	##avoids need to reboot before showing our new hostname in terminals etc.
	zenity --info --text "New hostname set to "$hostAnswer".\nRun me again at any time to change your hostname again."

	else
 	## answer="no"
	RNDHOST=`egrep -i "^[^áéíÓÚàèìÒÙäëüÖÜãõñÃÕÑâêîÔÛ']{8}$" /usr/share/dict/words | shuf | tail -n 1` 
	##get a list of random words without accented characters that are 8chars long, shuffle them, and give us one.
	hostnamectl set-hostname $RNDHOST
	sed -i '/127.0.0.1/c\127.0.0.1       localhost.localdomain   localhost '$RNDHOST'' /etc/hosts
	##properly sets our new host in /etc/hosts file
	hostname $RNDHOST
	##avoids need to reboot before showing our new hostname in terminals etc.
	zenity --info --text "New hostname set to "$RNDHOST".\nRun me again at any time to change your hostname again."
	fi

	else
	##answer="no"
	zenity --error --text "Hostname not changed. Exiting!"
	fi
else
    zenity --error --text "Error: No dictionaries found in '/usr/share/dict/words' \n(try 'pacman -S words' and start me again)" 1>&2
exit 1 
fi
