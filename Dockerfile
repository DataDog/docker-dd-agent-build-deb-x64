FROM debian:squeeze
MAINTAINER Remi Hakim @remh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y \
    curl \
    procps \
    fakeroot

RUN echo "deb http://http.debian.net/debian squeeze-backports main" >/etc/apt/sources.list.d/squeeze-backports.list
RUN apt-get update -qq && apt-get -t wheezy-backports install -y -qq \
    git

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable

RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.2.2"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

RUN curl -o /tmp/go1.3.3.linux-amd64.tar.gz https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.3.3.linux-amd64.tar.gz && \
    echo "PATH=$PATH:/usr/local/go/bin" | tee /etc/profile.d/go.sh

RUN git config --global user.email "package@datadoghq.com"
RUN git config --global user.name "Debian Omnibus Package"
RUN git clone https://github.com/DataDog/dd-agent-omnibus.git
# TODO: remove the checkout line after the merge to master
RUN cd dd-agent-omnibus && \
    /bin/bash -l -c "bundle install --binstubs"

VOLUME ["/dd-agent-omnibus/pkg"]
ENTRYPOINT /bin/bash -l /dd-agent-omnibus/omnibus_build.sh
