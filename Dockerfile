FROM centos
MAINTAINER PromptWorks <team@promptworks.com>

ENV RUBY_INSTALL_VERSION 0.4.0
ENV RUBY_VERSION 2.0.0-p353

# Install dependencies
RUN yum list installed | cut -f 1 -d " " | uniq | sort > /tmp/pre
RUN yum install git -y

# Download and extract Ruby
WORKDIR /tmp
RUN wget -O ruby-install.tar.gz \
      https://github.com/postmodern/ruby-install/archive/v$RUBY_INSTALL_VERSION.tar.gz
RUN tar -xzf ruby-install.tar.gz
RUN mv ruby-install-$RUBY_INSTALL_VERSION ruby-install

# Ruby install
WORKDIR /tmp/ruby-install
RUN make install
RUN ruby-install -i /usr/local ruby $RUBY_VERSION

# Clean up
RUN make uninstall
RUN yum list installed | cut -f 1 -d " " | uniq | sort > /tmp/post
RUN diff /tmp/pre /tmp/post | grep "^>" | cut -f 2 -d ' ' | \
      xargs echo yum erase -y
RUN yum clean all
RUN rm -rf /usr/local/src/ruby*
RUN rm -rf /tmp/*

RUN gem update --system --no-document
RUN gem install bundler --no-ri --no-rdoc
