
# MuShop Storefront API

---
Storefront backend written in [Node.js](https://nodejs.org/en/) orchestrating
services for consumption by the microservices [web application](../storefront)

> Modified from original source by Weaveworks [microservices-demo](https://github.com/microservices-demo/front-end)

## Build

### Dependencies

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Version</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://docker.com">Docker</a></td>
      <td>>= 1.12</td>
    </tr>
    <tr>
      <td><a href="https://docs.docker.com/compose/">Docker Compose</a></td>
      <td>>= 1.8.0</td>
    </tr>
    <tr>
      <td><a href="gnu.org/s/make">Make</a>&nbsp;(optional)</td>
      <td>>= 4.1</td>
    </tr>
  </tbody>
</table>

### Node

`npm install`

### Docker

`make up`

## Run

### Node

`npm start`

### Docker

`make up`

## Use

### Node

`curl http://localhost:3000`

### Docker Compose

`curl http://localhost:8080`
