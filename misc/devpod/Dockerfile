FROM ubuntu:latest

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    make \
    curl

RUN curl -L https://golang.org/dl/go1.22.1.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="${PATH}:/usr/local/go/bin"

RUN apt-get clean && rm -rf /var/lib/apt/lists/*