# MuShop Assets

## Configure

- Obtain an Object Storage Bucket Pre-Authenticated Request (PAR)
- Set environment variable `BUCKET_PAR`

## Optimize and Deploy

Build with `BUCKET_PAR`

```text
docker build --build-arg BUCKET_PAR=$BUCKET_PAR -t mushop/assets .
```

Optimize and deploy to Object Storage

```text
docker run -t --rm -v $(pwd)/products:/usr/src/app/products mushop/assets
```
