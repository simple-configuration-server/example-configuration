FROM registry.gitlab.com/tbro/simple-configuration-server:0.12.2
# NOTE: For production implementations, ALWAYS keep SSL enabled by removing
# the below environment variable.
ENV SCS_DISABLE_SSL=1
RUN rm -r /etc/scs/*
COPY --chown=scs:scs ./configuration /etc/scs
