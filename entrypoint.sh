#!/bin/sh

# This script is based fairly heavily off bateau84/openttd's. Thanks, man!
savepath="/config/save"
LOADGAME_CHECK="${loadgame}x"
BANLIST_CHECK="${BAN_LIST}x"
CONFIG_CHECK="${COPY_CONFIG}x"

if [ ${CONFIG_CHECK} != "x" ]; then
        echo "Copying static configuration from ${COPY_CONFIG}"
        cp -Lr ${COPY_CONFIG}/* /config/
fi
if [ ! -f /config/openttd.cfg ]; then
        # we start the server then kill it quickly to write a config file
        # yes this is a horrific hack but whatever
        echo "No config file found: generating one"
        timeout 3 /app/bin/openttd -D > /dev/null 2>&1
fi

if [ ${BANLIST_CHECK} != "x" ]; then
        echo "Merging external Ban List from /config/${BAN_LIST}"
        banread /config/openttd.cfg /config/${BAN_LIST}
fi
if [ ${LOADGAME_CHECK} != "x" ]; then
        case ${loadgame} in
                'false')
                        echo "Creating a new game."
                        exec /app/bin/openttd -D -x -d ${DEBUG}
                        exit 0
                ;;
                'last-autosave')
            		savegame_target=${savepath}/autosave/`ls -rt ${savepath}/autosave/ | tail -n1`

            		if [ -r ${savegame_target} ]; then
                    	        echo "Loading from autosave - ${savegame_target}"
                                exec /app/bin/openttd -D -g ${savegame_target} -x -d ${DEBUG}
                                exit 0
            		else
                                echo "Autosave not found - Creating a new game."
                		exec /app/bin/openttd -D -x -d ${DEBUG}
                    	        exit 0
            		fi
                ;;
                'exit')
            		savegame_target="${savepath}/autosave/exit.sav"

            		if [ -r ${savegame_target} ]; then
                    	        echo "Loading from exit save"
                                exec /app/bin/openttd -D -g ${savegame_target} -x -d ${DEBUG}
                                exit 0
            		else
                		echo "${savegame_target} not found - Creating a new game."
                		exec /app/bin/openttd -D -x -d ${DEBUG}
                    	        exit 0
            		fi
                ;;
                *)
                	savegame_target="${savepath}/${loadgame}"
                    if [ -f ${savegame_target} ]; then
                            echo "Loading ${savegame_target}"
                            exec /app/bin/openttd -D -g ${savegame_target} -x -d ${DEBUG}
                            exit 0
                    else
                            echo "${savegame_target} not found..."
                            exit 1
                    fi
                ;;
        esac
else
        echo "Loadgame not set - Creating a new game."
    	exec /app/bin/openttd -D -x -d ${DEBUG}
        exit 0
fi
