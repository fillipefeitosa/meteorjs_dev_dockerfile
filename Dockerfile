FROM ubuntu:latest

MAINTAINER Fillipe Feitosa "fillipefeitosa@gmail.com"

# build arguments
ARG APP_NAME=boilerplate
ARG APP_LOCALE=en_US
ARG APP_CHARSET=UTF-8
ARG APP_USER=meteor
ARG APP_USER_DIR=/home/${APP_USER}
ARG APP_UPLOAD_DIR=/var/www/${APP_NAME}/public

# run environment
ENV APP_PORT=${APP_PORT:-3000}

# exposed ports and volumes
EXPOSE $APP_PORT

# add packages for building NPM modules (required by Meteor)
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl \
    python build-essential \
    debconf locales git
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove
RUN DEBIAN_FRONTEND=noninteractive apt-get clean

# set the locale (required by Meteor)
RUN localedef ${APP_LOCALE}.${APP_CHARSET} -i ${APP_LOCALE} -f ${APP_CHARSET}

# create a non-root user that can write to /usr/local (required by Meteor)
RUN useradd -mUd ${APP_USER_DIR} ${APP_USER}
RUN chown -Rh ${APP_USER} /usr/local
RUN usermod -aG sudo ${APP_USER}

# We create a folder to upload files (ie.: maps, images)
RUN mkdir -p ${APP_UPLOAD_DIR}
RUN chown -Rh ${APP_USER} ${APP_UPLOAD_DIR}

# Change to APP_USER and install Meteor
USER ${APP_USER}

# We create a dedicated folder in which the app will be copied.
RUN cd /home/${APP_USER} && mkdir app

# We copy the app in the said folder.
COPY . /home/${APP_USER}/app/.


# install Meteor
RUN curl https://install.meteor.com/?release=1.8.3 | sh

# run Meteor from the app directory
CMD cd /home/${APP_USER}/app/ && meteor
