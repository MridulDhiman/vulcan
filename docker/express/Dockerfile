#Build stage
FROM node:16-alpine AS build
WORKDIR /app
COPY package*.json .
RUN npm ci ## clean install the dependencies
COPY . .
EXPOSE 3000
CMD [ "npm", "run", "start" ]
