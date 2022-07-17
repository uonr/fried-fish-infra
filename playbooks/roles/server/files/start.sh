#!/bin/sh
java -Xms2G -Xmx2G -XX:+UseG1GC -jar server.jar nogui
