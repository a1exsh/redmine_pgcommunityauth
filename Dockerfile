FROM debian:buster

RUN echo "deb http://deb.debian.org/debian buster-backports main" >/etc/apt/sources.list.d/buster-backports.list

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install -y -t buster-backports ruby-rouge
RUN apt-get install -y redmine redmine-sqlite

ENV REDMINE_ROOT=/usr/share/redmine
RUN mkdir -p "$REDMINE_ROOT/plugins/redmine_pgcommunityauth/"
COPY ./ "$REDMINE_ROOT/plugins/redmine_pgcommunityauth/"

WORKDIR "$REDMINE_ROOT"

USER www-data
CMD /usr/bin/rackup -d -E development
