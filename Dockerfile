# Dockerfile
# Verwende Postgres 17 als Basis
ARG PG_MAJOR=17
FROM postgres:${PG_MAJOR}

# Leg dein Maintainer-Label etc. fest
LABEL maintainer="Dein Name <[email protected]>"
LABEL description="PostgreSQL with pgvector extension"

# Kopiere den Source-Code von pgvector ins Image
COPY . /tmp/pgvector

# Baue & installiere pgvector
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      postgresql-server-dev-${PG_MAJOR} && \
    cd /tmp/pgvector && \
    make clean && \
    make OPTFLAGS="" && \
    make install && \
    # Kopiere Doku
    mkdir /usr/share/doc/pgvector && \
    cp LICENSE README.md /usr/share/doc/pgvector && \
    # Aufräumen
    rm -r /tmp/pgvector && \
    apt-get remove -y \
      build-essential \
      postgresql-server-dev-${PG_MAJOR} && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# OPTIONAL: Setze Environment-Variablen für Postgres (falls gewünscht)
# ACHTUNG: Passwörter nicht fest in Dockerfile packen!
ENV POSTGRES_USER=pgvector
ENV POSTGRES_DB=pgvector
#ENV POSTGRES_PASSWORD=mein_geheimes_passwort

# Erstelle bei Bedarf Verzeichnisse oder setze weitere Defaults
# Volume für die Daten
VOLUME ["/var/lib/postgresql/data"]

# Port freigeben (für Info, Docker Compose regelt das Mapping)
EXPOSE 5432

# Starte Postgres
CMD ["postgres"]
