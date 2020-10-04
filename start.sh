#!/bin/sh

echo "[lustasag/mysgw] Starting MySensors Gateway..."
echo "[lustasag/mysgw] Current MySensors version: $MYSENSORS_VERSION"
echo "[lustasag/mysqw] Port: $MYSENSORSGW_PORT"

MYSENSORSGW_OPTS=""

/usr/bin/mysgw $MYSENSORSGW_OPTS
