FROM node:lts-alpine AS base
WORKDIR /app

FROM node:lts-alpine AS install
WORKDIR /init
# CMD ["npm", "create", "astro@latest", "app", "-y", "--", "--template", "minimal", "--typescript", "relaxed", "--no-install", "--no-git"]
CMD ["npm", "create", "astro@latest", "app", "--", "--template", "minimal", "--typescript", "strict", "--install", "--no-git"]

FROM base AS init
COPY ./app/package*.json ./

FROM init AS prod-deps
RUN npm install --production

FROM init AS build-deps
RUN npm install --production=false

FROM init as dev-deps
RUN npm install

FROM build-deps AS build
COPY ./app .
RUN npm run build


# FROM base AS dev-base
# ARG INSTALL
# WORKDIR /
# RUN mkdir from_install
# COPY --from=install /app/astro ./from_install
# RUN mkdir from_repo
# COPY ./ ./from_repo
# RUN mkdir -p ./from_repo/src
# RUN if [ "$INSTALL" == "yes" ] ; \ 
#     then cp -R ./from_install/* ./app ; \
#     cp -R from_repo/src/ ./app ; \
#     fi

FROM base AS dev-build
COPY --from=dev-deps /app/node_modules ./node_modules
COPY ./app .

FROM dev-build AS develop
CMD ["npm", "run", "dev", "--", "--host" ]


FROM base AS prod
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist


