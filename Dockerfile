FROM fedora:41
ENV HOME "/root"
ENV PATH "${HOME}/.local/bin:${PATH}"
ENV SHELL "/bin/bash"
RUN dnf -y update
RUN <<ALIASES
    echo "alias ll='ls -l'" >> ${HOME}/.bashrc
    echo "alias python='python3'" >> ${HOME}/.bashrc
    mkdir ${HOME}/.aws
    mkdir -p ${HOME}/.local/bin
    # mkdir -p ${HOME}/.sdkman/etc
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
ALIASES
# See README.md for __copypersisted.sh and what this image does to help you maintain your shell history and configs
COPY __copy2persisted.sh ${HOME}/.local/bin/
RUN chmod +x ${HOME}/.local/bin/__copy2persisted.sh
RUN dnf -y install \
    git \
    which \
    pass \
    dos2unix \
    gcc \
    gcc-c++ \
    make \
    python3-devel \
    poetry \
    awscli \
    unzip \
    zip \
    direnv

RUN python3 -m ensurepip --upgrade && python3 -m pip install --user pipx
RUN echo '__copy2persisted.sh' >> /root/.bashrc
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/persisted/.bash_history" \
    && echo "$SNIPPET" >> "/root/.bashrc"
RUN SNIPPET="export AWS_CONFIG_FILE=/persisted/.aws/config" && echo "$SNIPPET" >> "/root/.bashrc"
COPY tool-versions ${HOME}/.tool-versions
COPY sdkmanconfig ${HOME}/sdkmanconfig
RUN dos2unix ${HOME}/.bashrc ${HOME}/.tool-versions ${HOME}/sdkmanconfig
# # RUN echo "export AWS_PROFILE=seguridad-dev-admin" >> "/root/.bashrc"
# # RUN echo "export AWS_VAULT_BACKEND=file" >> "/root/.bashrc"
# # RUN echo "export AWS_VAULT_FILE_DIR=/persisted/.aws/" >> "/root/.bashrc"
RUN <<ASDF
    git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v0.14.0
    echo ". $HOME/.asdf/asdf.sh" >> ${HOME}/.bashrc
    echo ". $HOME/.asdf/completions/asdf.bash" >> ${HOME}/.bashrc
    . ${HOME}/.asdf/asdf.sh
    asdf plugin-add aws-vault https://github.com/karancode/asdf-aws-vault.git    
    asdf install aws-vault
    # export AWS_VAULT_FILE_PASSPHRASE=somepassword needs to be set
    asdf plugin-add nodejs
    asdf install nodejs
    asdf plugin-add pnpm
    asdf install pnpm
    pnpm setup
    . ${HOME}/.bashrc
    # pnpm install -g serverless
    # serverless update
ASDF
RUN echo 'eval "$(starship init bash)"' >> ${HOME}/.bashrc  
ENV MAVEN_HOME "${HOME}/.sdkman/candidates/maven/current"
ENV JAVA_HOME "${HOME}/.sdkman/candidates/java/current"
RUN <<SDKMAN
    JDK_VERSION="17.0.12-amzn"
    JDK_GRAAL_VERSION="21.0.4-graal"
    MAVEN_VERSION="3.9.8"
    LIQUIBASE_VERSION="4.29.0"
    QUARKUS_VERSION="3.12.3"
    _DIR="${HOME}/.sdkman"
    curl -s "https://get.sdkman.io" | bash
    mv ${HOME}/sdkmanconfig ${HOME}/.sdkman/etc/config
    # echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ${HOME}/.bashrc
    # echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ${HOME}/.bashrc
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    # sdk install java ${JDK_GRAAL_VERSION}
    # sdk install java "21.0.2-open"
    sdk install java ${JDK_VERSION}
    # sdk install java 
    sdk default java ${JDK_VERSION}
    sdk install maven #{MAVEN_VERSION}
    sdk default maven ${MAVEN_VERSION}
    sdk install jbang
    sdk install jarviz
    sdk install layrry
    sdk install liquibase ${LIQUIBASE_VERSION}
    sdk default liquibase ${LIQUIBASE_VERSION}
    # sdk install quarkus ${QUARKUS_VERSION} 
    # sdk default quarkus ${QUARKUS_VERSION}
    # sdk install springboot # Need version probably from ibparent, etc
SDKMAN
