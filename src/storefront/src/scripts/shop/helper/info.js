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
  NETWORK: {
    name: 'Networking',
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
  EMAIL: {
    name: 'Email Delivery',
    icon: 'email.svg',
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
  // cloud native
  APIGW: {
    name: 'API Gateway',
    icon: 'apigw.svg',
  },
  FN: {
    name: 'Function',
    icon: 'fn.png',
  },
  NATS: {
    name: 'NATS',
    icon: 'nats.png',
  },
  // container technologies
  JAVA: {
    name: 'Java',
    icon: 'java.png',
    scale: 1.5,
  },
  HELIDON: {
    name: 'Helidon',
    icon: 'helidon.svg',
  },
  NODE: {
    name: 'Node.js',
    icon: 'nodejs.png',
  },
  TYPESCRIPT: {
    name: 'TypeScript/Node.js',
    icon: 'ts.svg',
    scale: 0.9,
  },
  REDIS: {
    name: 'Redis',
    icon: 'redis.png',
  },
  GO: {
    name: 'Go',
    icon: 'go.png',
    scale: 1.8,
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
  MICRONAUT: {
    name: 'Micronaut',
    icon: 'micronaut.png',
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
    desc: `Internet scale storage for product media assets`
  },
  ATP: {
    name: 'ATP Database',
    type: ServiceType.ATP,
    tech: TechType.OCI,
    basic: TechType.OCI,
    desc: `Data persistence, separated by service`
  },
  STREAMING: {
    name: 'Stream',
    type: ServiceType.STREAMING,
    tech: TechType.OCI,
    desc: `Application level event records`,
  },
  APIGW: {
    name: 'API Gateway',
    type: ServiceType.APIGW,
    tech: TechType.OCI,
    desc: `Application API gateway`,
  },
  SUBSCRIBE: {
    name: 'Subscribe',
    type: ServiceType.FN,
    tech: TechType.OCI,
    desc: `Newsletter subscription serverless function`,
  },
  EMAIL: {
    name: 'Email',
    type: ServiceType.EMAIL,
    tech: TechType.OCI,
    desc: `Managed email delivery SMTP configuration`,
  },
  // Edge
  DNS: {
    name: 'DNS',
    type: ServiceType.DNS,
    tech: TechType.NETWORK,
    desc: `Managed DNS Zone`,
  },
  WAF: {
    name: 'WAF',
    type: ServiceType.WAF,
    tech: TechType.NETWORK,
    desc: `OWASP, DDoS, and access control management`,
  },
  LB: {
    name: 'LB',
    type: ServiceType.LB,
    tech: TechType.NETWORK,
    basic: TechType.OCI,
    desc: `Public application load balancer`,
  },
  // OKE Services
  INGRESS: {
    name: 'Ingress',
    type: ServiceType.NGINX,
    tech: TechType.OKE,
    desc: `Kubernetes nginx ingress controller`,
  },
  EDGE_ROUTER: {
    name: 'Router',
    type: ServiceType.TRAEFIK,
    tech: TechType.OKE,
    desc: `Application level routing for exposed services`,
  },
  STORE: {
    name: 'Storefront',
    type: ServiceType.HTML5,
    tech: TechType.OKE,
    basic: TechType.COMPUTE,
    desc: `Responsive HTML/CSS/JavaScript client`,
  },
  API: {
    name: 'REST API',
    type: ServiceType.NODE,
    tech: TechType.OKE,
    basic: TechType.COMPUTE,
    desc: `Session management and service gateway`,
  },
  ASSETS: {
    name: 'Media',
    type: ServiceType.NODE,
    tech: TechType.OKE,
    desc: `Product media source, integrating with Object Storage`,
  },
  EVENTS: {
    name: 'Tracking',
    type: ServiceType.GO,
    tech: TechType.OKE,
    desc: `Streaming message producer for application level events`,
  },
  SESSION: {
    name: 'Session DB',
    type: ServiceType.REDIS,
    tech: TechType.OKE,
    desc: `Client session management`,
  },
  CATALOG: {
    name: 'Catalogue',
    type: ServiceType.GO,
    tech: TechType.OKE,
    basic: TechType.COMPUTE,
    desc: `Product catalogue services`,
  },
  CART: {
    name: 'Carts',
    type: ServiceType.HELIDON,
    tech: TechType.OKE,
    desc: `Shopping cart services`,
  },
  ORDERS: {
    name: 'Orders',
    type: ServiceType.JAVA,
    tech: TechType.OKE,
    desc: `Order management services`,
  },
  FULFILLMENT: {
    name: 'Fulfillment',
    type: ServiceType.MICRONAUT,
    tech: TechType.OKE,
    desc: `Order fulfillment/processing service`,
  },
  PAYMENT: {
    name: 'Payment',
    type: ServiceType.GO,
    tech: TechType.OKE,
    desc: `Checkout payment verification`,
  },
  USER: {
    name: 'Users',
    type: ServiceType.TYPESCRIPT,
    tech: TechType.OKE,
    desc: `Customer profile services`,
  },
  NATS: {
    name: 'NATS',
    type: ServiceType.NATS,
    tech: TechType.OKE,
    desc: `Cloud native messaging service`,
  },
};

/**
 * Define service relationships
 */
export const ServiceLinks = [
  // edge
  { source: Services.DNS, target: Services.WAF },
  { source: Services.DNS, target: Services.LB, lineStyle: { type: 'dotted', curveness: 0.2 } }, // insecure
  { source: Services.WAF, target: Services.LB },
  { source: Services.LB, target: Services.INGRESS },
  { source: Services.INGRESS, target: Services.EDGE_ROUTER },
  { source: Services.EDGE_ROUTER, target: Services.STORE },
  { source: Services.EDGE_ROUTER, target: Services.API },
  { source: Services.EDGE_ROUTER, target: Services.ASSETS },
  // ui
  // { source: Services.STORE, target: Services.BUCKET },
  // { source: Services.STORE, target: Services.API },
  // api
  { source: Services.API, target: Services.SESSION },
  { source: Services.API, target: Services.CART },
  { source: Services.API, target: Services.CATALOG },
  { source: Services.API, target: Services.USER },
  { source: Services.API, target: Services.ORDERS },
  // events
  { source: Services.API, target: Services.EVENTS },
  { source: Services.EVENTS, target: Services.STREAMING },
  // User
  { source: Services.USER, target: Services.ATP, edgeSymbol: ['arrow', 'arrow'] }, // read/write
  // Catalog
  { source: Services.CATALOG, target: Services.ATP }, // read
  { source: Services.ASSETS, target: Services.BUCKET },
  // Cart
  { source: Services.CART, target: Services.ATP, edgeSymbol: ['arrow', 'arrow'] }, // read/write
  // Orders
  { source: Services.ORDERS, target: Services.ATP, edgeSymbol: ['arrow', 'arrow'] }, // read/write
  { source: Services.ORDERS, target: Services.USER },
  { source: Services.ORDERS, target: Services.CART },
  { source: Services.ORDERS, target: Services.PAYMENT },
  { source: Services.ORDERS, target: Services.NATS },
  // Fulfillment
  { source: Services.NATS, target: Services.FULFILLMENT },
  { source: Services.NATS, target: Services.ORDERS },
  { source: Services.FULFILLMENT, target: Services.NATS },
  // Gateway
  { source: Services.API, target: Services.APIGW },
  { source: Services.APIGW, target: Services.SUBSCRIBE },
  { source: Services.SUBSCRIBE, target: Services.EMAIL },

];

/**
 * link definitions for basic mode
 */
export const BasicServiceLinks = [
  { source: Services.LB, target: Services.STORE },
  { source: Services.LB, target: Services.API },
  { source: Services.API, target: Services.CATALOG },
  { source: Services.CATALOG, target: Services.ATP },
  { source: Services.STORE, target: Services.BUCKET },
];