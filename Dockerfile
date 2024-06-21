FROM python:3.10-alpine as builder

# Install system dependencies
RUN apk update && \
    apk add --no-cache rsync git nodejs npm && \
    rm -rf /var/cache/apk/*

WORKDIR /mkdocs/
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt --no-cache-dir
COPY overrides /mkdocs/overrides
COPY docs /mkdocs/docs
COPY mkdocs.yml /mkdocs/mkdocs.yml
COPY extra.js /mkdocs/docs/javascripts/extra.js
RUN mkdocs build

FROM bitnami/nginx:1.19
COPY nginx.conf /opt/bitnami/nginx/conf/server_blocks/site.conf
COPY --from=builder /mkdocs/site /app
CMD ["nginx", "-g", "daemon off;"]