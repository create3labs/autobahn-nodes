# autobahn nodes

## Preparations
1. Create c3labs user on host system `adduser c3labs`
1. Install docker.io
1. Add user to docker group `usermod -aG docker c3labs`
1. Install docker compose v2 [https://nextgentips.com/2022/05/06/how-to-install-docker-compose-v2-on-ubuntu-22-04/](https://nextgentips.com/2022/05/06/how-to-install-docker-compose-v2-on-ubuntu-22-04/)
1. Clone this repo
1. execute `./scripts/init.sh`

## Configuration
Configure nodes/.env, nodes/member|service/.env with the correct values.

## Start
Execute execute `./scripts/start.sh`.