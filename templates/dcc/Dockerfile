ARG BASE_IMAGE
FROM ${BASE_IMAGE} 

RUN useradd -ms /bin/bash sagadmin && \
    mkdir -p /opt/softwareag && \
    chown sagadmin /opt/softwareag

COPY --chown=sagadmin:sagadmin --from=INSTALL /opt/softwareag /opt/softwareag

WORKDIR /opt/softwareag

ENTRYPOINT ["/opt/softwareag/common/db/bin/dbConfigurator.sh"]

