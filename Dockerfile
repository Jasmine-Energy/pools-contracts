FROM node:18.15.0 as base

WORKDIR /srv

COPY src ./src
COPY hardhat ./hardhat
COPY tasks ./tasks
COPY deploy ./deploy
COPY utils ./utils
COPY types ./types
COPY scripts ./scripts
COPY contracts ./contracts
COPY tsconfig.build.json ./tsconfig.build.json
COPY tsconfig.json ./tsconfig.json
COPY hardhat.config.ts ./hardhat.config.ts
COPY package.json ./package.json

# Install deps
RUN yarn

RUN ["yarn", "build"]

CMD ["yarn", "start"]
