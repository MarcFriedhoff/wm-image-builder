ARG BASE_IMAGE
FROM ${BASE_IMAGE} as MSR_INSTALL

MAINTAINER Software AG
ENV SAG_HOME /opt/softwareag
ENV LANG C.utf8
RUN groupadd -g 1724 sagadmin; useradd -u 1724 -m -g 1724 -d ${SAG_HOME} sagadmin
USER 1724
RUN mkdir -p ${SAG_HOME}/jvm ${SAG_HOME}/common ${SAG_HOME}/IntegrationServer ${SAG_HOME}/IntegrationServer/packages ${SAG_HOME}/IntegrationServer/cacheStore ${SAG_HOME}/IntegrationServer/db ${SAG_HOME}/install

ENV JAVA_HOME ${SAG_HOME}/jvm/jvm/
ENV JRE_HOME ${SAG_HOME}/jvm/jvm/

COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/jvm/jvm/ ${SAG_HOME}/jvm/jvm/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/install/products/ ${SAG_HOME}/install/products/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/Licenses/ ${SAG_HOME}/Licenses/

COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/common/bin/ ${SAG_HOME}/common/bin/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/common/conf/ ${SAG_HOME}/common/conf/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/common/db/ ${SAG_HOME}/common/db/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/common/metering/ ${SAG_HOME}/common/metering/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/common/lib/ ${SAG_HOME}/common/lib/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/WS-Stack/ ${SAG_HOME}/WS-Stack/

COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/SAGUpdateManager/UpdateManager/readme/ ${SAG_HOME}/readme/

COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/bin/ ${SAG_HOME}/IntegrationServer/bin/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/lib/ ${SAG_HOME}/IntegrationServer/lib/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/updates/ ${SAG_HOME}/IntegrationServer/updates/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/web/ ${SAG_HOME}/IntegrationServer/web/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/docker/ ${SAG_HOME}/IntegrationServer/docker/
COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/replicate/ ${SAG_HOME}/IntegrationServer/replicate/

COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/.tc.custom.log4j2.properties ${SAG_HOME}/IntegrationServer/.tc.custom.log4j2.properties

COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/config/ ${SAG_HOME}/IntegrationServer/config/

COPY --chown=1724:1724 --from=INSTALL ${SAG_HOME}/IntegrationServer/packages ${SAG_HOME}/IntegrationServer/packages

RUN cd ${SAG_HOME}/IntegrationServer/docker; ./is_container.sh updateDockerConfigFiles -Ddocker.isHomeDir=${SAG_HOME}/IntegrationServer -Ddocker.rootDir=${SAG_HOME};
#RUN rm -f ${SAG_HOME}/common/runtime/bundles/ext/eclipse/plugins/org.yaml.snakeyaml_1.30.0.jar /opt/softwareag/common/runtime/bundles/platform/eclipse/plugins/org.apache.shiro.core_1.8.0.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/org.apache.commons.text_1.8.0.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/com.google.guava_30.1.1.jre.jar /opt/softwareag/common/runtime/bundles/lar/eclipse/plugins/org.eclipse.jgit_5.11.0.202103091610-r.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/org.apache.commons.fileupload_1.4.0.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/com.fasterxml.jackson.core.jackson-databind_2.13.2.2.jar /opt/softwareag/common/runtime/bundles/tes/eclipse/plugins/net.sf.ehcache.ee_2.11.0.0_132.jar /opt/softwareag/common/runtime/bundles/tes/eclipse/plugins/org.terracotta.toolkit-runtime-ee_4.4.0.0_109.jar /opt/softwareag/common/runtime/bundles/event-routing-shared/eclipse/plugins/org.apache.jackrabbit.webdav_2.12.6.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/com.google.protobuf_3.19.3.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/com.fasterxml.woodstox.woodstox-core_6.1.1.jar /opt/softwareag/common/runtime/bundles/platform/eclipse/plugins/com.softwareag.security.web.sso.saml2_10.15.0.0000-0476.jar /opt/softwareag/common/runtime/bundles/esapi/eclipse/plugins/org.owasp.esapi_2.4.0.0.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/com.fasterxml.jackson.core.jackson-core_2.13.2.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/org.apache.commons.configuration_2.8.0.jar /opt/softwareag/common/runtime/bundles/ext/eclipse/plugins/org.apache.commons.io_2.10.0.jar ;
#RUN rm -f ${SAG_HOME}/common/runtime/bundles/event-routing-shared/eclipse/plugins/org.apache.jackrabbit.webdav_2.12.6.jar ;

USER root
RUN chgrp -R 0 ${SAG_HOME} && chmod -R g=u ${SAG_HOME}
LABEL com.softwareag.product=IntegrationServerOpenShiftBase

FROM ${BASE_IMAGE} 

MAINTAINER Software AG
ENV SAG_HOME /opt/softwareag
ENV JAVA_HOME ${SAG_HOME}/jvm/jvm/
ENV JRE_HOME ${SAG_HOME}/jvm/jvm/

USER root

RUN dnf install -y shadow-utils procps-ng tar \
 && dnf clean all \
 && rm -rf /var/cache/*

COPY --from=MSR_INSTALL ${SAG_HOME} ${SAG_HOME}
RUN chgrp 0 ${SAG_HOME} && chmod g=u ${SAG_HOME}
RUN groupadd -g 1724 sagadmin; useradd -u 1724 -m -g 1724 -d ${SAG_HOME} sagadmin
USER 1724

EXPOSE 5555
EXPOSE 9999
EXPOSE 5543

ENTRYPOINT ["/opt/softwareag/IntegrationServer/bin/startContainer.sh"]
