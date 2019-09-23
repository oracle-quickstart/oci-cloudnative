/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

const iconDir = 'images/tech/';
const toArray = obj => Object.keys(obj).map(k => obj[k]);
const iconPrefix = obj => toArray(obj).forEach(row => row.icon = row.icon && iconDir + row.icon);

export const TechType = {
  OCI: {
    name: 'Oracle Cloud Infrastructure',
    icon: 'oci.png',
    color: '#f80000',
  },
  EDGE: {
    name: 'Oracle Edge Services',
    icon: 'cdn.svg',
    color: '#5F5F5F',
  },
  COMPUTE: {
    name: 'Compute',
    icon: 'compute.svg',
    color: '#5F5F5F',
  },
  OKE: {
    name: 'Oracle Container Engine',
    icon: 'k8s.png',
    color: '#00758f',
  },
};
// add icon paths
iconPrefix(TechType);

export const ServiceType = {
  // OCI Stuff
  ATP: {
    name: 'Oracle ATP',
    icon: 'atp.png',
    scale: 1.2,
  },
  BUCKET: {
    name: 'Object Storage',
    icon: 'bucket.svg',
  },
  STREAMING: {
    name: 'Streaming',
    icon: 'streaming.svg',
  },
  // edge/network
  LB: {
    name: 'Load Balancer',
    icon: 'lb.svg',
  },
  VCN: {
    name: 'Virtual Cloud Network',
    icon: 'vcn.svg',
  },
  DNS: {
    name: 'DNS',
    icon: 'dns.svg',
  },
  WAF: {
    name: 'Web Application Firewall',
    icon: 'waf.svg',
  },
  // container technology
  JAVA: {
    name: 'Java',
    icon: 'java.png',
    scale: 1.5,
  },
  NODE: {
    name: 'Node.js',
    icon: 'nodejs.png',
  },
  REDIS: {
    name: 'Redis',
    icon: 'redis.png',
  },
  GO: {
    name: 'Go',
    icon: 'go.svg',
  },
  TRAEFIK: {
    name: 'Traefik',
    icon: 'traefik.svg',
  },
  PYTHON: {
    name: 'Python',
    icon: 'python.svg',
  },
  NGINX: {
    name: 'Nginx',
    icon: 'nginx.png',
  },
  HTML5: {
    name: 'HTML5',
    icon: 'html5.png',
  },
  MONGO: {
    name: 'MongoDB',
    icon: 'mongo.png',
    scale: 1.2,
  },
};
// add icon paths
iconPrefix(ServiceType);


/**
 * Define services in application architecture
 */
export const Services = {
  // OCI Services
  BUCKET: {
    name: 'Bucket',
    type: ServiceType.BUCKET,
    tech: TechType.OCI,
    basic: TechType.OCI,
  },
  ATP: {
    name: 'ATP Database',
    type: ServiceType.ATP,
    tech: TechType.OCI,
    basic: TechType.OCI,
  },
  STREAMING: {
    name: 'OCI Stream',
    type: ServiceType.STREAMING,
    tech: TechType.OCI,
  },
  // Edge
  DNS: {
    name: 'DNS',
    type: ServiceType.DNS,
    tech: TechType.EDGE,
  },
  WAF: {
    name: 'WAF',
    type: ServiceType.WAF,
    tech: TechType.EDGE,
  },
  LB: {
    name: 'LB',
    type: ServiceType.LB,
    tech: TechType.OCI,
    basic: TechType.OCI,
  },
  // OKE Services
  INGRESS: {
    name: 'Ingress',
    type: ServiceType.NGINX,
    tech: TechType.OKE,
  },
  EDGE_ROUTER: {
    name: 'Router',
    type: ServiceType.TRAEFIK,
    tech: TechType.OKE,
  },
  STORE: {
    name: 'Storefront UI',
    type: ServiceType.HTML5,
    tech: TechType.OKE,
    basic: TechType.COMPUTE,
  },
  API: {
    name: 'REST API',
    type: ServiceType.NODE,
    tech: TechType.OKE,
    basic: TechType.COMPUTE,
  },
  SESSION: {
    name: 'Session DB',
    type: ServiceType.REDIS,
    tech: TechType.OKE,
  },
  CATALOG: {
    name: 'Catalog',
    type: ServiceType.GO,
    tech: TechType.OKE,
    basic: TechType.COMPUTE,
  },
  CART: {
    name: 'Carts',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
  },
  ORDERS: {
    name: 'Orders',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
  },
  SHIPPING: {
    name: 'Shipping',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
  },
  STREAM: {
    name: 'Stream Consumer',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
  },
  PAYMENT: {
    name: 'Payment',
    type: ServiceType.GO,
    tech: TechType.OKE,
  },
  USER: {
    name: 'Users',
    type: ServiceType.GO,
    tech: TechType.OKE,
  },
  USERDB: {
    name: 'Users NoSQL',
    type: ServiceType.MONGO,
    tech: TechType.OKE,
  },
};

/**
 * Define service relationships
 */
export const ServiceLinks = [
  // edge
  { source: Services.DNS, target: Services.WAF },
  { source: Services.DNS, target: Services.LB, lineStyle: { type: 'dotted' } }, // insecure
  { source: Services.WAF, target: Services.LB },
  { source: Services.LB, target: Services.INGRESS },
  { source: Services.INGRESS, target: Services.EDGE_ROUTER },
  { source: Services.EDGE_ROUTER, target: Services.STORE },
  { source: Services.EDGE_ROUTER, target: Services.API },
  // ui
  // { source: Services.STORE, target: Services.BUCKET },
  // { source: Services.STORE, target: Services.API },
  // api
  { source: Services.API, target: Services.SESSION },
  { source: Services.API, target: Services.CART },
  { source: Services.API, target: Services.CATALOG },
  { source: Services.API, target: Services.USER },
  { source: Services.API, target: Services.ORDERS },
  // User
  { source: Services.USER, target: Services.USERDB },
  // Catalog
  { source: Services.CATALOG, target: Services.ATP },
  { source: Services.CATALOG, target: Services.BUCKET },
  // Cart
  { source: Services.CART, target: Services.ATP },
  // Orders
  { source: Services.ORDERS, target: Services.ATP },
  { source: Services.ORDERS, target: Services.USER },
  { source: Services.ORDERS, target: Services.CART },
  { source: Services.ORDERS, target: Services.SHIPPING },
  { source: Services.ORDERS, target: Services.PAYMENT },
  // Ship
  { source: Services.SHIPPING, target: Services.STREAMING },
  { source: Services.STREAMING, target: Services.STREAM },

];

/**
 * link definitions for basic mode
 */
export const BasicServiceLinks = [
  { source: Services.LB, target: Services.STORE },
  { source: Services.LB, target: Services.API },
  { source: Services.API, target: Services.CATALOG },
  { source: Services.CATALOG, target: Services.ATP },
  // { source: Services.CATALOG, target: Services.BUCKET },
];