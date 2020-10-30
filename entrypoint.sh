#!/bin/bash
set -x

if [ -z "$CERT" ]; then
    echo "env CERT is required"
    exit 1
fi

if [ -z "$REMOTE_CONN" ]; then
    echo "env REMOTE_CONN is required"
    exit 1
fi

if [ -z "$CERT_DEPLOY_PATH" ]; then
    echo "env CERT_DEPLOY_PATH is required"
    exit 1
fi

if [ -z "$KEY_DEPLOY_PATH" ]; then
    echo "env KEY_DEPLOY_PATH is required"
    exit 1
fi

SSH_ARGS="-q -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

FORCE=
if [ "$1" == "--force" -o "$1" == "-f" ]; then
    FORCE=1
fi

CERT_DIR=/etc/letsencrypt/live/$CERT

if [ ! -d "$CERT_DIR" ]; then
    echo "directory of cert not found: $CERT_DIR"
    exit 1
fi

CERT_MARK=$CERT_DIR/certbot-deploy-ssh.mark
TIMESTAMP_CERT=$(date +%s)

if [ -z "$FORCE" ]; then
    if [ -f "$CERT_MARK" ]; then
        last_update=$(cat $CERT_MARK)
        TIMESTAMP_CERT=$(stat -c %Y $CERT_DIR/fullchain.pem)
        if [ "$last_update" == "$TIMESTAMP_CERT" ]; then
            echo "cert is up-to-date, skip deploy"
            exit 0
        fi
    fi
fi

scp -vvv $SSH_ARGS $CERT_DIR/fullchain.pem $REMOTE_CONN:$CERT_DEPLOY_PATH
[[ $? -eq 0 ]] || exit $?
scp -vvv $SSH_ARGS $CERT_DIR/privkey.pem $REMOTE_CONN:$KEY_DEPLOY_PATH
[[ $? -eq 0 ]] || exit $?
if [ -n "$EXEC_DEPLOY_CMD" ]; then
    ssh -vvv -t -t $SSH_ARGS $REMOTE_CONN "$EXEC_DEPLOY_CMD"
    [[ $? -eq 0 ]] || exit $?
fi

echo "Certificates deploy successfully"
echo $TIMESTAMP_CERT > $CERT_MARK
