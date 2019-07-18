# cyrus-imap-docker

Docker container for cyrus-imap 3.x based on alpine

## Special

* It starts **syslogd** under the master process for logging
* It starts **saslauthd** for authentication under the master process

# Run

    docker run --rm -ti -p 80:80 -p 143:143 -p 110:110 -p 2000:2000 -p 24:24 threez/cyrus-imap:latest

## Create login

    $ docker exec -ti $(docker ps -f ancestor=threez/cyrus-imap -q) /bin/sh
    # #### admin user (cyrus) password
    # echo secret | saslpasswd2 -p -c cyrus
    # #### add regular user password
    # echo secret | saslpasswd2 -p -c imapuser

# Build

    make