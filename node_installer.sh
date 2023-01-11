#!/bin/bash
# shellcheck disable=SC2034
# Copyright © 2021-2022 The Unigrid Foundation, UGD Software AB

# This program is free software: you can redistribute it and/or modify it under the terms of the
# addended GNU Affero General Public License as published by the Free Software Foundation, version 3
# of the License (see COPYING and COPYING.addendum).

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received an addended copy of the GNU Affero General Public License with this program.
# If not, see <http://www.gnu.org/licenses/> and <https://github.com/unigrid-project/unigrid-installer>.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/unigrid-project/unigrid-installer/main/node_installer.sh)" ; source ~/.bashrc

bash -c "$(wget -qO - raw.githubusercontent.com/unigrid-project/unigrid-installer/main/node_installer.sh)" '' testnet
```

'

ARGS=("$@")

while test $# -gt 0; do
case "$1" in
    -h|--help)
    echo "$package - attempt to capture frames"
    echo " "
    echo "$package [options] application [arguments]"
    echo " "
    echo "options:"
    echo "-h, --help                    show brief help"
    echo "-t, --tx-detail=TXID          specify an address and an id for the tx detail\n example: 149448f8c06cda10f1e7a30db5df0911cb7e3e6c1b8e3656c232f3caa3cb7965 0"
    echo "-k, --private-key=GN_KEY      specify the genereted private key from the wallet"
    exit 0
    ;;
    -t)
    shift
    if test $# -gt 0; then
        export TXID=$1
    else
        echo "no tx id specified"
        exit 1
    fi
    shift
    ;;
    --tx-id*)
    export TXID=`echo $1 | sed -e 's/^[^=]*=//g'`
    shift
    ;;
    -k)
    shift
    if test $# -gt 0; then
        export GN_KEY=$1
    else
        echo "no private key specified"
        exit 1
    fi
    shift
    ;;
    --private-key*)
    export GN_KEY=`echo $1 | sed -e 's/^[^=]*=//g'`
    shift
    ;;
    -i)
    shift
    if test $# -gt 0; then
        export INDEX=$1
    else
        echo "no index specified"
        exit 1
    fi
    shift
    ;;
    --index*)
    export INDEX=`echo $1 | sed -e 's/^[^=]*=//g'`
    shift
    ;;
    *)
    break
    ;;
esac
done

if [ "${TXID}" ]; then
    TX_DETAILS=($TXID)
    if [[ -z "${TX_DETAILS[0]}" || -z "${TX_DETAILS[1]}" ]]; then
        MSG="${RED}Please enter both a txid and output ID"
        echo -e "${MSG}"
        exit 1;
    fi
fi

if [[ -n "${1}" ]]
then
IMAGE_SOURCE="${1}"
else
IMAGE_SOURCE='latest'
fi

ORANGE='\033[0;33m'

ASCII_ART() {
    echo -e "${ORANGE}"
    clear 2>/dev/null
    cat <<"UNIGRID"
 _   _ _   _ ___ ____ ____  ___ ____
| | | | \ | |_ _/ ___|  _ \|_ _|  _ \
| | | |  \| || | |  _| |_) || || | | |
| |_| | |\  || | |_| |  _ < | || |_| |
 \___/|_| \_|___\____|_| \_\___|____/

Copyright © 2021-2022 The Unigrid Foundation, UGD Software AB 

UNIGRID
}

cd ~/ || exit
COUNTER=0
rm -f ~/___gn.sh
while [[ ! -f ~/___gn.sh ]] || [[ $(grep -Fxc "# End of gridnode setup script." ~/___gn.sh) -eq 0 ]]; do
    rm -f ~/___gn.sh
    echo "Downloading Unigrid Setup Script."
    wget -4qo- https://raw.githubusercontent.com/TimNhanTa/installer/master/scripts/node-setup.sh -O ~/___gn.sh
    COUNTER=1
    if [[ "${COUNTER}" -gt 3 ]]; then
        echo
        echo "Download of setup script failed."
        echo
        exit 1
    fi
done

(
    sleep 2
    rm ~/___gn.sh
) &
#disown

(
    # shellcheck disable=SC1091
    # shellcheck source=/root/___gn.sh
    . ~/___gn.sh "${ARGS[@]}"
    START_INSTALL
) &

# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane 2>/dev/null
exit
