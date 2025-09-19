## Traefik as reverse proxy & load balancer locally

[

![SOURABH MANDAL](https://miro.medium.com/v2/da:true/resize:fill:56:56/0*HzLTEOusS9EaC2jE)



](https://medium.com/@bitsofmandal?source=post_page---byline--2b566825f94f---------------------------------------)

Press enter or click to view image in full size

![](https://miro.medium.com/v2/resize:fit:1235/1*KkFHs0YZtgzkJvKcrsnDWQ.jpeg)

Find this video on youtube.com/@bitsofmandal

In the modern microservices architecture, reverse proxies play a crucial role in managing traffic and securing applications. Traefik has emerged as a popular choice due to its Docker-native integration and ease of configuration. This guide will walk you through setting up Traefik locally for development purposes.

> If you like content about fullstack engineering you can, make sure to subscribe my youtube channel

## What is Traefik?

Traefik is a modern HTTP reverse proxy and load balancer designed to seamlessly deploy microservices. Its standout features include:  
\- Automatic service discovery  
\- Built-in Let’s Encrypt support  
\- Real-time configuration updates  
\- Docker integration  
\- Dynamic load balancing

## Prerequisites

Before we begin, ensure you have:

-   Docker and Docker Compose installed
-   Basic understanding of YAML configuration
-   Admin access to modify system files
-   A text editor

## Setting Up Traefik Locally

### Network Configuration

First, we need to configure our local network. Create a Docker Compose file and create a `localhost_net` network like shown below.

starter docker-compose for traefik proxy definition

Please note that the network is defined as external so we have to manually create it before we run docker-compose command

To create a network use `docker network create localhost_net`

Press enter or click to view image in full size

![Create a localhost network for traefik](https://miro.medium.com/v2/resize:fit:1235/1*ebzE6px3qLK-bQtc76SeYA.png)

### Domain Configuration

We’ll use two local domains to expose our application endpoints. Traefik has a builtin dashboard which can be exposed to the internet via http endpoint so we will be doing that for local development (not recomended in production setup) and our App on separate endpoint, both of these endpoints will be hosted behind traefik reverse proxy, following are the urls to setup:

1.  Traefik dashboard - [**https://proxy.localhost**](https://proxy.localhost/)
2.  Your application - [**https://app.localhost**](https://app.localhost/)

We need to point both these urls to our local loopback address (127.0.0.1) for them to access our locally served up traefik from docker-compose file

Edit `/etc/hosts` (mac) file in administrator mode. you can check where your host file setup are based on your OS, however configuration are same across OS.

Add the following 2 lines at the end of your host file

![](https://miro.medium.com/v2/resize:fit:918/1*M-rz6x49lDDng-03dG2kJg.png)

add custom urls for traefik to localhost

## Traefik Service Configuration

Add the Traefik service to your Docker Compose file. Please note that we have mounted a configuration file for traefik instead of defining all configurations in single docker-compose file. We will define these configuration later in the article:

### Local Certificate Setup

Generate local SSL certificates using OpenSSL at the root of your project:

## Get SOURABH MANDAL’s stories in your inbox

Join Medium for free to get updates from this writer.

`openssl req -x509 -nodes -days 365 -newkey rsa:2048 \   -keyout localhost.key -out localhost.crt`  
This will generate 2 files `localhost.crt` and `localhost.key`

## Traefik Configuration file

Create `config/configuration.yml` with the following settings:

Traefik configurations in config/configurations.yml

### Defining a Sample Application proxied by traefik proxy

Let’s deploy a sample NGINX application behind Traefik:

## Advanced Configuration Options

### Middleware Configuration

Traefik supports various middleware options for enhanced functionality:

```
labels:   - "traefik.http.middlewares.auth.basicauth.users=admin:$$apr1$$xyz123"   - "traefik.http.routers.app.middlewares=auth@docker"
```

### Rate Limiting

Protect your services with rate limiting:

```
labels:  - "traefik.http.middlewares.ratelimit.ratelimit.average=100"  - "traefik.http.middlewares.ratelimit.ratelimit.burst=50"
```

### Health Checks

Configure health checks for your services:

```
labels:   traefik.http.services.app.loadbalancer.healthcheck.path=/health   traefik.http.services.app.loadbalancer.healthcheck.interval=10s
```

## Security Considerations

When setting up Traefik locally, consider these security best practices:

1.  **SSL/TLS Configuration**: Always use HTTPS, even locally
2.  **Access Control:** Secure the Traefik dashboard
3.  **Docker Socket:** Be cautious with Docker socket mounting
4.  **Network Isolation:** Use separate networks for different environments

## Troubleshooting Common Issues

1.  **Certificate Issues  
    **Ensure certificates are properly mounted  
    Check certificate permissions  
    Verify domain names match certificates
2.  **Network Problems**  
    Confirm Docker network exists  
    Check host file configurations  
    Verify port mappings
3.  **Service Discovery Issues**  
    Ensure labels are correctly configured  
    Check Docker network connectivity  
    Verify service ports

## Conclusion

Setting up Traefik locally provides a powerful development environment that mirrors production configurations. This setup allows you to:

-   Test microservices architecture locally
-   Develop with HTTPS enabled
-   Experiment with various Traefik features
-   Prepare for production deployment

Remember to check Traefik’s official documentation for the latest features and best practices as you build upon this basic setup.