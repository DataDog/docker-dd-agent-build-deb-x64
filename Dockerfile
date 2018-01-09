FROM debian:wheezy
MAINTAINER Remi Hakim @remh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y \
    curl \
    procps \
    fakeroot \
    git

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable

RUN sed -i "s/libgmp-dev//g" /usr/local/rvm/scripts/functions/requirements/debian

RUN /bin/bash -l -c "rvm requirements && rvm install 2.2.2 && gem install bundler --no-ri --no-rdoc" && \
    rm -rf /usr/local/rvm/src/ruby-2.2.2

# Update certs used by ruby
RUN curl -fsSL curl.haxx.se/ca/cacert.pem \
         -o $(/bin/bash -l -c "ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE'")

RUN curl -o /tmp/go1.3.3.linux-amd64.tar.gz https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.3.3.linux-amd64.tar.gz && \
    rm -f /tmp/go1.3.3.linux-amd64.tar.gz && \
    echo "PATH=$PATH:/usr/local/go/bin" | tee /etc/profile.d/go.sh

RUN git config --global user.email "package@datadoghq.com" && \
    git config --global user.name "Debian Omnibus Package" && \
    git clone https://github.com/DataDog/dd-agent-omnibus.git

RUN git clone https://github.com/DataDog/integrations-extras.git
RUN git clone https://github.com/DataDog/integrations-core.git

RUN cd dd-agent-omnibus && \
    /bin/bash -l -c "OMNIBUS_RUBY_BRANCH='datadog-5.5.0' bundle install --binstubs"

RUN /bin/bash -l -c "echo 'deb http://apt.datadoghq.com/ stable main' > /etc/apt/sources.list.d/datadog.list"
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 C7A7DA52
RUN apt-get update

ADD checkout_omnibus_branch.sh /

VOLUME ["/dd-agent-omnibus/pkg"]
ENTRYPOINT /bin/bash -l /checkout_omnibus_branch.sh
