FROM node:22-alpine

WORKDIR /server

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8000

CMD ["sh", "-c", "npx prisma generate && npx prisma migrate deploy && npx prisma db seed && npm run start"]