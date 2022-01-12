FROM ubuntu:20.04

RUN apt-get update
RUN apt-get -y install curl tree git
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin
RUN curl -LO https://binaries.dl.tetrate.io/public/raw/versions/linux-amd64-1.4.4/tctl && chmod u+x tctl &&  chmod o+x tctl && mv tctl /usr/local/bin/tctl
RUN curl -LO https://github.com/mikefarah/yq/releases/download/v4.16.2/yq_linux_amd64.tar.gz && tar -zxvf yq_linux_amd64.tar.gz && mv yq_linux_amd64 /usr/local/bin/yq

COPY configure.sh .
ENTRYPOINT ["./configure.sh"]