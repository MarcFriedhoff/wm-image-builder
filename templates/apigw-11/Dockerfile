ARG BASE_IMAGE
FROM ${BASE_IMAGE} as APIGW_INSTALLER

MAINTAINER Software AG
ENV SAG_HOME /opt/softwareag
ENV LANG C.utf8
RUN groupadd -g 1724 sagadmin; useradd -u 1724 -m -g 1724 -d ${SAG_HOME} sagadmin
USER 1724
RUN mkdir -p ${SAG_HOME}/jvm ${SAG_HOME}/common ${SAG_HOME}/IntegrationServer ${SAG_HOME}/IntegrationServer/packages ${SAG_HOME}/IntegrationServer/cacheStore ${SAG_HOME}/IntegrationServer/db ${SAG_HOME}/install

ENV JAVA_HOME ${SAG_HOME}/jvm/jvm/
ENV JRE_HOME ${SAG_HOME}/jvm/jvm/

COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/jvm/jvm/ ${SAG_HOME}/jvm/jvm/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/install/products/ ${SAG_HOME}/install/products/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/Licenses/ ${SAG_HOME}/Licenses/


COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/common/bin/ ${SAG_HOME}/common/bin/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/common/conf/ ${SAG_HOME}/common/conf/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/common/db/ ${SAG_HOME}/common/db/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/common/metering/ ${SAG_HOME}/common/metering/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/common/lib/ ${SAG_HOME}/common/lib/
# excludeComponents input param = [${exclude.components}]
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/WS-Stack/ ${SAG_HOME}/WS-Stack/

COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/bin/ ${SAG_HOME}/IntegrationServer/bin/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/lib/ ${SAG_HOME}/IntegrationServer/lib/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/updates/ ${SAG_HOME}/IntegrationServer/updates/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/web/ ${SAG_HOME}/IntegrationServer/web/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/docker/ ${SAG_HOME}/IntegrationServer/docker/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/replicate/ ${SAG_HOME}/IntegrationServer/replicate/

COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/.tc.custom.log4j2.properties ${SAG_HOME}/IntegrationServer/.tc.custom.log4j2.properties

#COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/db/ ${SAG_HOME}/IntegrationServer/db/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/config/ ${SAG_HOME}/IntegrationServer/config/

COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/Default/ ${SAG_HOME}/IntegrationServer/packages/Default/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmART/ ${SAG_HOME}/IntegrationServer/packages/WmART/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmFlatFile/ ${SAG_HOME}/IntegrationServer/packages/WmFlatFile/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmAPIGateway/ ${SAG_HOME}/IntegrationServer/packages/WmAPIGateway/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmARTExtDC/ ${SAG_HOME}/IntegrationServer/packages/WmARTExtDC/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmAdmin/ ${SAG_HOME}/IntegrationServer/packages/WmAdmin/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmISExtDC/ ${SAG_HOME}/IntegrationServer/packages/WmISExtDC/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmPublic/ ${SAG_HOME}/IntegrationServer/packages/WmPublic/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmCloud/ ${SAG_HOME}/IntegrationServer/packages/WmCloud/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmRoot/ ${SAG_HOME}/IntegrationServer/packages/WmRoot/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmJSONAPI/ ${SAG_HOME}/IntegrationServer/packages/WmJSONAPI/
COPY --chown=1724:1724 --from=INSTALLER ${SAG_HOME}/IntegrationServer/packages/WmXSLT/ ${SAG_HOME}/IntegrationServer/packages/WmXSLT/

#RUN mkdir -p ${SAG_HOME}/wpm/ &&\
#        wget -q -O - https://techcommunity.softwareag.com/wpm/download/wpm.tar | tar -xzf - -C /opt/softwareag/wpm/ &&\
#        chmod +x /opt/softwareag/wpm/bin/wpm.sh &&\
#        ENV PATH=/opt/softwareag/wpm/bin:$PATH &&\
#        ./wpm.sh install YOUR_PACKAGE_NAME -u YOUR_GITHUB_USERNAME -p CREDENTIAL -r REPO_URL &&\
#        rm -rf ${SAG_HOME}/wpm/; rm -f ${SAG_HOME}/wpm.tar

RUN cd /opt/softwareag/IntegrationServer/docker; ./is_container.sh updateDockerConfigFiles -Ddocker.isHomeDir=${SAG_HOME}/IntegrationServer -Ddocker.rootDir=${SAG_HOME};

USER root
RUN chgrp -R 0 ${SAG_HOME} && chmod -R g=u ${SAG_HOME}
LABEL com.softwareag.product=IntegrationServerOpenShiftBase

FROM ${BASE_IMAGE} 

MAINTAINER Software AG
ENV SAG_HOME /opt/softwareag
ENV JAVA_HOME ${SAG_HOME}/jvm/jvm/
ENV JRE_HOME ${SAG_HOME}/jvm/jvm/

USER root
COPY --from=APIGW_INSTALLER ${SAG_HOME} ${SAG_HOME}
RUN chgrp 0 ${SAG_HOME} && chmod g=u ${SAG_HOME}
RUN groupadd -g 1724 sagadmin; useradd -u 1724 -m -g 1724 -d ${SAG_HOME} sagadmin
USER 1724

EXPOSE 5555
EXPOSE 9999
EXPOSE 5543

ENTRYPOINT ["/opt/softwareag/IntegrationServer/bin/startContainer.sh"]