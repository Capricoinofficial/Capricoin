#!/bin/dash
set -e

if [ ! -s "$CAPRICOIN_DATA/Capricoin.conf" ]; then
	cat <<-EOF > "$CAPRICOIN_DATA/Capricoin.conf"
	printtoconsole=1
	rpcallowip=::/0
	rpcpassword=${CAPRICOIN_RPC_PASSWORD:-password}
	rpcuser=${CAPRICOIN_RPC_USER:-capricoin}
	EOF
fi

exec "$@"