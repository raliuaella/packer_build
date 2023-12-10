FROM golang:latest
ENV TERRAFORM_VERSION=1.2.5
RUN apt-get update && apt-get install unzip  && curl -Os https://releases.hashicorp.com/terraform/1.2.5/terraform_1.2.5_linux_amd64.zip  \ 
curl -Os https://releases.hashicorp.com/terraform/1.2.5/terraform_1.2.5_SHA256SUMS  \ 
curl https://keybase.io/hashicorp/pgp_keys.asc | gpg --import  && curl -Os https://releases.hashicorp.com/terraform/1.2.5/terraform_1.2.5_SHA256SUMS.sig \ 
&& gpg --verify  terraform_1.2.5_SHA256SUMS.sig terraform_1.2.5_SHA256SUMS && shasum -a 256 -c \ 
terraform_1.2.5_SHA256SUMS 2>&1 | grep "1.2.5_linux_amd64.zip:\sOK" \ && unzip -o terraform_1.2.5_linux_amd64.zip -d /usr/bin
RUN mkdir /tfcode
COPY . /tfcode
WORKDIR /tfcode