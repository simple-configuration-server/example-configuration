# To build a SCS docker image that includes the configuration, simpy use the
# SCS image as base, and copy in your configuration data. Note that you need to
# remove the existing 'dummy' data that's in /etc/scs by default.
#
# Alternatively, you can use the base SCS docker image without building one with
# your own configuration, and use a bind-mount to link you local configuration
# directories to the /etc/scs folder.

FROM ghcr.io/simple-configuration-server/simple-configuration-server:2.0.0
# NOTE: For production implementations, ALWAYS keep SSL enabled by removing
# the below environment variable.
ENV SCS_DISABLE_SSL=1
RUN rm -r /etc/scs/*
COPY --chown=scs:scs ./configuration /etc/scs
