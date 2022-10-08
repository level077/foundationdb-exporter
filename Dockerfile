FROM node:16 as builder

# install FoundationDB client library
RUN wget -q https://github.com/apple/foundationdb/releases/download/7.1.5/foundationdb-clients_7.1.5-1_amd64.deb \
  && dpkg -i foundationdb-clients_7.1.5-1_amd64.deb \
  && rm foundationdb-clients_7.1.5-1_amd64.deb

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn

COPY . .
RUN yarn build

FROM node:16

# install FoundationDB client library
RUN wget -q https://github.com/apple/foundationdb/releases/download/7.1.5/foundationdb-clients_7.1.5-1_amd64.deb \
  && dpkg -i foundationdb-clients_7.1.5-1_amd64.deb \
  && rm foundationdb-clients_7.1.5-1_amd64.deb

# set up multi-version FoundationDB client
ENV FDB_NETWORK_OPTION_EXTERNAL_CLIENT_DIRECTORY /usr/lib/foundationdb/multiversion

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn --prod

COPY --from=builder /app/build /app/build

ENTRYPOINT ["node", "build/index.js"]
