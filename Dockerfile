FROM openjdk:11.0.5-slim-buster
LABEL AUTHOR Mike Hummel <mh@mhus.de>

ENV APP_UID=501

ARG BUILD_KARAF_VERSION=4.2.6
ENV JAVA_MAX_MEM=2048m
ENV APP_NAME=karaf
# for jdk9 and above, debug also from other then localhost
ENV JAVA_DEBUG_PORT=*:5005

RUN set -x \
    && echo ">>> Install linux tools" \
    && apt-get update && apt-get install -y --no-install-recommends python3 jq wget curl less nano \
    && echo ">>> Setup" \
    && mkdir /docker \
    && mkdir -p /docker/profiles/default \
    && mkdir -p /docker/profiles/initial \
    && cd / \
    && echo ">>> Download and install karaf" \
    && url="http://archive.apache.org/dist/karaf/${BUILD_KARAF_VERSION}/apache-karaf-${BUILD_KARAF_VERSION}.tar.gz" \
    && wget -O "/tmp/apache-karaf.tar.gz" "${url}" \
    && mkdir -p /opt/karaf \
    && mv /tmp/apache-karaf.tar.gz /docker/assembly.tar.gz \
    && echo ">>> Cleanup" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY karaf /docker/profiles/initial
COPY start.sh /docker/
COPY install.sh /docker/
COPY substitute.py /docker/
COPY environment_folders.txt /docker/

RUN set -x \
    && echo ">>> Prepare start" \
    && chmod ugo+x /docker/start.sh \
    && chmod ugo+x /docker/install.sh \
    && chmod ugo+x /docker/substitute.py \
    && useradd -u $APP_UID -m user \
    && chown -R user:user /opt/karaf \
    && mkdir -p /home/user/.m2/repository \
    && chown -R user:user /home/user/.m2 \
    && chown -R user:user /docker \
    && ln -sfn /opt/karaf/bin/client /usr/bin/client

EXPOSE 8181

USER ${APP_UID}
ENTRYPOINT ["/docker/start.sh"]
CMD []
