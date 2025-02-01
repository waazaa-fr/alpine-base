FROM alpine:@@ALPINE_VERSION@@

LABEL org.opencontainers.image.authors="waazaa <waazaa@waazaa.fr>"
LABEL version="alpine-base"
LABEL desc="Alpine Linux base image with bash instead of ash and supervisor"

ENV TZ=Europe/Paris
ENV PUID=99
ENV PGID=100

#######################################################################################################################################################################
##### PAQUETS UTILES
#######################################################################################################################################################################
RUN apk add --no-cache tzdata python3 py3-pip curl wget tree htop nano doas supervisor
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -m 0777 -p /root/.config/pip && echo "[global]" > /root/.config/pip/pip.conf && echo "break-system-packages = true" >> /root/.config/pip/pip.conf

#######################################################################################################################################################################
##### BASH
#######################################################################################################################################################################
RUN touch /etc/profile.d/bash_completion.sh
RUN apk add --no-cache bash bash-doc bash-completion ncurses shadow busybox-suid \
    && touch /etc/profile.d/bash_completion.sh \
    && echo "exec /bin/bash" > /root/.profile \
    && echo "source /etc/profile.d/bash_completion.sh" > /root/.bashrc \
    && echo "alias dir='ls --color=never -alh'" >> /root/.bashrc \
    && echo "alias lsa='ls -alh'" >> /root/.bashrc \
    && echo "alias mkdir='mkdir --verbose'" >> /root/.bashrc \
    && echo 'export PS1="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\$ "' >> /root/.bashrc \
    && echo 'export EDITOR="nano"' >> /root/.bashrc \
    && mkdir -p /etc/profile.d/ && touch /etc/profile.d/bash_completion.sh \
    && sed -e 's;/bin/ash$;/bin/bash;g' -i /etc/passwd


#######################################################################################################################################################################
##### USER
#######################################################################################################################################################################
RUN apk add doas
RUN adduser -D waazaa
RUN echo 'waazaa:waazaa' | chpasswd
RUN echo 'permit waazaa as root' > /etc/doas.d/doas.conf
RUN touch /etc/profile.d/bash_completion.sh \
    && echo "exec /bin/bash" > /home/waazaa/.profile \
    && echo "source /etc/profile.d/bash_completion.sh" > /home/waazaa/.bashrc \
    && echo "alias dir='ls --color=never -alh'" >> /home/waazaa/.bashrc \
    && echo "alias lsa='ls -alh'" >> /home/waazaa/.bashrc \
    && echo "alias mkdir='mkdir --verbose'" >> /home/waazaa/.bashrc \
    && echo 'export PS1="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\$ "' >> /home/waazaa/.bashrc \
    && echo 'export EDITOR="nano"' >> /home/waazaa/.bashrc \
    && sed -e 's;/bin/ash$;/bin/bash;g' -i /etc/passwd  \
    && echo 'export PATH=$PATH:/home/waazaa/.local/bin' >> /home/waazaa/.bashrc

RUN mkdir -m 0777 -p /home/waazaa/.config/pip && echo "[global]" > /home/waazaa/.config/pip/pip.conf && echo "break-system-packages = true" >> /home/waazaa/.config/pip/pip.conf


COPY root/ /
RUN chmod a+x /start/*.sh


CMD ["/app/scripts/startup.sh"]
