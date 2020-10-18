FROM mhus/karaf-k8s:4.2.6.1

COPY data/local-assembly.tar.gz /docker/assembly.tar.gz
COPY data/karaf /docker/profiles/custom-initial
RUN /docker/install.sh
