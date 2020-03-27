FROM ubuntu:18.04

WORKDIR /src

RUN apt update -q && apt install -y autoconf build-essential git libpam0g-dev libssl-dev zlib1g-dev

COPY 0001-Keep-track-of-the-dynamic-port-created-by-a-reverse-.patch /
RUN git clone https://github.com/openssh/openssh-portable /src \
	&& git config --global user.email "you@example.com" \
	&& git config --global user.name "Your Name" \
	&& git checkout V_8_2_P1 \
	&& git am /*.patch \
	&& autoreconf \
	&& ./configure --with-pam --with-privsep-user=nobody \
	&& make \
	&& make install

FROM ubuntu:18.04

RUN apt update -q && apt install -y libssl1.1 python3 python3-requests \
	&& mkdir /var/empty

COPY --from=0 /usr/local /usr/local
COPY entrypoint.py /entrypoint
COPY sync-authorized-keys.py /sync-authorized-keys
COPY rtunnel-shell /rtunnel-shell
COPY lmp-device-session.py /
COPY sshd_config /usr/local/etc/
COPY sshd.pam /etc/pam.d/sshd

ENTRYPOINT ["/entrypoint"]
