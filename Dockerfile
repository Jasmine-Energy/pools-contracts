FROM node:16.13.1 as base

WORKDIR /srv

COPY src ./src
COPY hardhat ./hardhat
COPY tasks ./tasks
COPY deploy ./deploy
COPY utils ./utils
COPY types ./types
COPY scripts ./scripts
COPY contracts ./contracts
COPY tsconfig.json ./tsconfig.json
COPY hardhat.config.ts ./hardhat.config.ts
COPY package.json ./package.json

# Install deps
RUN yarn

CMD ["yarn", "build"]
