FROM registry.gitlab.com/tbro/simple-configuration-server:0.12.2
COPY --chown=scs:scs ./configuration /etc/scs
