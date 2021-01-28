FROM elixir:1.11.2

WORKDIR /code

COPY . /code

RUN apt-get install -y openssh-client \
    git && \
    mix local.hex --force && \
    mix local.rebar --force && \
    groupadd -g 1000 app && \
    useradd -g 1000 -u 1000 --system --create-home app && \
    cp -rp /root/.mix /home/app/ && \
    chown -R app:app /home/app/.mix


ENTRYPOINT ["/code/entrypoint"]