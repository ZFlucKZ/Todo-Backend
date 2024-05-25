FROM golang:1.22.3-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod tidy

COPY . ./

RUN CGO_ENABLED=0 GOOS=linux go build -o app .

FROM alpine:3.19 AS runner

WORKDIR /app

COPY --from=builder /app/app /

CMD ["/app"]
