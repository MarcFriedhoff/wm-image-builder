ARG BASE_IMAGE
FROM ${BASE_IMAGE} 

ENV SAG_HOME=/opt/softwareag
ENV JAVA_HOME=${SAG_HOME}/jvm/jvm/
ENV JRE_HOME=${SAG_HOME}/jvm/jvm/

RUN mkdir -p $SAG_HOME && groupadd -g 1724 sagadmin && useradd -u 1724 -m -g 1724 -d $SAG_HOME -c "SoftwareAG Admin" sagadmin && chown 1724:1724 $SAG_HOME && chmod 775 $SAG_HOME

RUN dnf install -y shadow-utils procps-ng tar \
 && dnf clean all \
 && rm -rf /var/cache/*

ARG INSTANCE_NAME=default
ARG VOLUMES_DIR=$SAG_HOME/MWS/volumes

ENV DB_TYPE= \
    DB_URL= \
    DB_USERNAME= \
    DB_PASSWORD= \
    NODE_NAME= \
    APPS_DIR=$VOLUMES_DIR/apps \
    CONFIGS_DIR=$VOLUMES_DIR/configs \
    DATA_DIR=$VOLUMES_DIR/data \
    LIBS_DIR=$VOLUMES_DIR/libs \
    LOGS_DIR=$VOLUMES_DIR/logs \
    PATCHES_DIR=$VOLUMES_DIR/patches \
    MWS_WORKDIR=$SAG_HOME/MWS/server/$INSTANCE_NAME/bin 

RUN mkdir -p $APPS_DIR $CONFIGS_DIR $DATA_DIR $LIBS_DIR $LOGS_DIR $PATCHES_DIR && chown 1724:1724 $APPS_DIR && chown 1724:1724 $CONFIGS_DIR && chown 1724:1724 $DATA_DIR && chown 1724:1724 $LIBS_DIR && chown 1724:1724 $LOGS_DIR && chown 1724:1724 $PATCHES_DIR

COPY --chown=1724:1724 --from=INSTALL $SAG_HOME/ $SAG_HOME/

RUN chmod u+x $SAG_HOME/MWS/bin/mws.sh && chmod u+x $MWS_WORKDIR/container.sh

USER 1724

WORKDIR $MWS_WORKDIR

VOLUME ["$APPS_DIR", "$CONFIGS_DIR", "$DATA_DIR", "$LIBS_DIR", "$LOGS_DIR", "$PATCHES_DIR"]

ENTRYPOINT $MWS_WORKDIR/container.sh

EXPOSE 8585

HEALTHCHECK --interval=15s --timeout=30s --start-period=5m CMD $MWS_WORKDIR/container.sh healthcheck