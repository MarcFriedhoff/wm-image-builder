ARG BASE_IMAGE

FROM ${BASE_IMAGE} AS buildStage

MAINTAINER Super iPaaS Integration LLC, an IBM Company

ENV MICROGW_DIR /opt/softwareag/Microgateway

RUN mkdir -p ${MICROGW_DIR}/logs

COPY --from=INSTALLER ${MICROGW_DIR}/adduser.sh ${MICROGW_DIR}
RUN ${MICROGW_DIR}/adduser.sh sagadmin 1724 ${MICROGW_DIR}

RUN chown -R 1724:1724 /opt/softwareag

COPY --chown=1724:1724 --from=INSTALLER ${MICROGW_DIR}/config/ ${MICROGW_DIR}/config/
COPY --chown=1724:1724 --from=INSTALLER ${MICROGW_DIR}/lib/ ${MICROGW_DIR}/lib/
COPY --chown=1724:1724 --from=INSTALLER ${MICROGW_DIR}/files/ ${MICROGW_DIR}/files/
COPY --chown=1724:1724 --from=INSTALLER ${MICROGW_DIR}/resources/ ${MICROGW_DIR}/resources/
COPY --chown=1724:1724 --from=INSTALLER ${MICROGW_DIR}/*.jar ${MICROGW_DIR}/
COPY --chown=1724:1724 --from=INSTALLER ${MICROGW_DIR}/*.sh ${MICROGW_DIR}/

COPY --chown=1724:1724 --from=INSTALLER ${MICROGW_DIR}/microgateway-jre-linux-musl/ ${MICROGW_DIR}/microgateway-jre-linux-musl/

USER root
RUN chgrp -R 0 /opt/softwareag/ && chmod -R g=u /opt/softwareag/

FROM ${BASE_IMAGE}

MAINTAINER Super iPaaS Integration LLC, an IBM Company

ENV MICROGW_DIR /opt/softwareag/Microgateway

RUN mkdir -p ${MICROGW_DIR}
COPY --from=INSTALLER ${MICROGW_DIR}/adduser.sh ${MICROGW_DIR}
RUN ${MICROGW_DIR}/adduser.sh sagadmin 1724 ${MICROGW_DIR}

USER root
RUN chgrp -R 0 /opt/softwareag/ && chmod -R g=u /opt/softwareag/

USER 1724

COPY --from=buildStage --chown=1724:0 /opt/softwareag /opt/softwareag

EXPOSE 9090

HEALTHCHECK CMD ${MICROGW_DIR}/microgateway.sh status 2>&1 | grep 'Server active'

WORKDIR ${MICROGW_DIR}

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["-p", "9090", "-lv", "ERROR"]