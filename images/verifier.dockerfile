FROM python:3.10.4-alpine3.16

RUN apk update
RUN apk add bash
RUN apk add git
SHELL ["/bin/bash", "-c"]

RUN apk add alpine-sdk
RUN apk add libffi-dev
RUN apk add libsodium
RUN apk add libsodium-dev
RUN apk add git

# Setup Rust for blake3 dependency build
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

WORKDIR /keripy
RUN git clone -b development https://github.com/WebOfTrust/keripy.git .
RUN source "$HOME/.cargo/env" && pip install -r requirements.txt

RUN mkdir -p /usr/local/var/keri

WORKDIR /verifier
RUN git clone https://github.com/GLEIF-IT/reg-poc-verifier.git .
RUN pip install -r requirements.txt
RUN cd ../keripy && pip install -e .
COPY ./config/verifier/scripts/* ./scripts

RUN mkdir -p /usr/local/var/keri
COPY ./data/keri/* /usr/local/var/keri

ENTRYPOINT ["verifier", "server", "start", "--config-dir", "scripts", "--config-file", "verifier-config.json"]
