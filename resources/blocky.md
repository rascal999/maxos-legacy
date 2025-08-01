This chapter describes all configuration options in `config.yaml`. You can download a reference file with all configuration properties as [JSON](https://0xerr0r.github.io/blocky/latest/config.yml).

reference configuration file

```
upstreams:
  init:
    # Configure startup behavior.
    # accepted: blocking, failOnError, fast
    # default: blocking
    strategy: fast
  groups:
    # these external DNS resolvers will be used. Blocky picks 2 random resolvers from the list for each query
    # format for resolver: [net:]host:[port][/path]. net could be empty (default, shortcut for tcp+udp), tcp+udp, tcp, udp, tcp-tls or https (DoH). If port is empty, default port will be used (53 for udp and tcp, 853 for tcp-tls, 443 for https (Doh))
    # this configuration is mandatory, please define at least one external DNS resolver
    default:
      # example for tcp+udp IPv4 server (https://digitalcourage.de/)
      - 5.9.164.112
      # Cloudflare
      - 1.1.1.1
      # example for DNS-over-TLS server (DoT)
      - tcp-tls:fdns1.dismail.de:853
      # example for DNS-over-HTTPS (DoH)
      - https://dns.digitale-gesellschaft.ch/dns-query
    # optional: use client name (with wildcard support: * - sequence of any characters, [0-9] - range)
    # or single ip address / client subnet as CIDR notation
    laptop*:
      - 123.123.123.123
  # optional: Determines what strategy blocky uses to choose the upstream servers.
  # accepted: parallel_best, strict, random
  # default: parallel_best
  strategy: parallel_best
  # optional: timeout to query the upstream resolver. Default: 2s
  timeout: 2s
  # optional: HTTP User Agent when connecting to upstreams. Default: none
  userAgent: "custom UA"

# optional: Determines how blocky will create outgoing connections. This impacts both upstreams, and lists.
# accepted: dual, v4, v6
# default: dual
connectIPVersion: dual

# optional: custom IP address(es) for domain name (with all sub-domains). Multiple addresses must be separated by a comma
# example: query "printer.lan" or "my.printer.lan" will return 192.168.178.3
customDNS:
  customTTL: 1h
  # optional: if true (default), return empty result for unmapped query types (for example TXT, MX or AAAA if only IPv4 address is defined).
  # if false, queries with unmapped types will be forwarded to the upstream resolver
  filterUnmappedTypes: true
  # optional: replace domain in the query with other domain before resolver lookup in the mapping
  rewrite:
    example.com: printer.lan
  mapping:
    printer.lan: 192.168.178.3,2001:0db8:85a3:08d3:1319:8a2e:0370:7344

# optional: definition, which DNS resolver(s) should be used for queries to the domain (with all sub-domains). Multiple resolvers must be separated by a comma
# Example: Query client.fritz.box will ask DNS server 192.168.178.1. This is necessary for local network, to resolve clients by host name
conditional:
  # optional: if false (default), return empty result if after rewrite, the mapped resolver returned an empty answer. If true, the original query will be sent to the upstream resolver
  # Example: The query "blog.example.com" will be rewritten to "blog.fritz.box" and also redirected to the resolver at 192.168.178.1. If not found and if `fallbackUpstream` was set to `true`, the original query "blog.example.com" will be sent upstream.
  # Usage: One usecase when having split DNS for internal and external (internet facing) users, but not all subdomains are listed in the internal domain.
  fallbackUpstream: false
  # optional: replace domain in the query with other domain before resolver lookup in the mapping
  rewrite:
    example.com: fritz.box
  mapping:
    fritz.box: 192.168.178.1
    lan.net: 192.168.178.1,192.168.178.2

# optional: use allow/denylists to block queries (for example ads, trackers, adult pages etc.)
blocking:
  # definition of denylist groups. Can be external link (http/https) or local file
  denylists:
    ads:
      - https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
      - https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
      - http://sysctl.org/cameleon/hosts
      - https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
      - |
        # inline definition with YAML literal block scalar style
        someadsdomain.com
        *.example.com
    special:
      - https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts
  # definition of allowlist groups.
  # Note: if the same group has both allow/denylists, allowlists take precedence. Meaning if a domain is both blocked and allowed, it will be allowed.
  # If a group has only allowlist entries, only domains from this list are allowed, and all others be blocked.
  allowlists:
    ads:
      - allowlist.txt
      - |
        # inline definition with YAML literal block scalar style
        # hosts format
        allowlistdomain.com
        # this is a regex
        /^banners?[_.-]/
  # definition: which groups should be applied for which client
  clientGroupsBlock:
    # default will be used, if no special definition for a client name exists
    default:
      - ads
      - special
    # use client name (with wildcard support: * - sequence of any characters, [0-9] - range)
    # or single ip address / client subnet as CIDR notation
    laptop*:
      - ads
    192.168.178.1/24:
      - special
  # which response will be sent, if query is blocked:
  # zeroIp: 0.0.0.0 will be returned (default)
  # nxDomain: return NXDOMAIN as return code
  # comma separated list of destination IP addresses (for example: 192.100.100.15, 2001:0db8:85a3:08d3:1319:8a2e:0370:7344). Should contain ipv4 and ipv6 to cover all query types. Useful with running web server on this address to display the "blocked" page.
  blockType: zeroIp
  # optional: TTL for answers to blocked domains
  # default: 6h
  blockTTL: 1m
  # optional: Configure how lists, AKA sources, are loaded
  loading:
    # optional: list refresh period in duration format.
    # Set to a value <= 0 to disable.
    # default: 4h
    refreshPeriod: 24h
    # optional: Applies only to lists that are downloaded (HTTP URLs).
    downloads:
      # optional: timeout for list download (each url). Use large values for big lists or slow internet connections
      # default: 5s
      timeout: 60s
      # optional: timeout for list write to disk (each url). Use larger values for big lists or in constrained environments
      # default: 20s
      writeTimeout: 60s
      # optional: timeout for reading the download (each url). Use large values for big lists or in constrained environments
      # To disable this timeout, set to 0.
      # default: 20s
      readTimeout: 60s
      # optional: timeout for reading request headers for the download (each url). Use large values for slow internet connections
      # to disable, set to -1.
      # default: 20s
      readHeaderTimeout: 60s
      # optional: Maximum download attempts
      # default: 3
      attempts: 5
      # optional: Time between the download attempts
      # default: 500ms
      cooldown: 10s
    # optional: Maximum number of lists to process in parallel.
    # default: 4
    concurrency: 16
    # Configure startup behavior.
    # accepted: blocking, failOnError, fast
    # default: blocking
    strategy: failOnError
    # Number of errors allowed in a list before it is considered invalid.
    # A value of -1 disables the limit.
    # default: 5
    maxErrorsPerSource: 5

# optional: configuration for caching of DNS responses
caching:
  # duration how long a response must be cached (min value).
  # If <=0, use response's TTL, if >0 use this value, if TTL is smaller
  # Default: 0
  minTime: 5m
  # duration how long a response must be cached (max value).
  # If <0, do not cache responses
  # If 0, use TTL
  # If > 0, use this value, if TTL is greater
  # Default: 0
  maxTime: 30m
  # Max number of cache entries (responses) to be kept in cache (soft limit). Useful on systems with limited amount of RAM.
  # Default (0): unlimited
  maxItemsCount: 0
  # if true, will preload DNS results for often used queries (default: names queried more than 5 times in a 2-hour time window)
  # this improves the response time for often used queries, but significantly increases external traffic
  # default: false
  prefetching: true
  # prefetch track time window (in duration format)
  # default: 120
  prefetchExpires: 2h
  # name queries threshold for prefetch
  # default: 5
  prefetchThreshold: 5
  # Max number of domains to be kept in cache for prefetching (soft limit). Useful on systems with limited amount of RAM.
  # Default (0): unlimited
  prefetchMaxItemsCount: 0
  # Time how long negative results (NXDOMAIN response or empty result) are cached. A value of -1 will disable caching for negative results.
  # Default: 30m
  cacheTimeNegative: 30m

# optional: configuration of client name resolution
clientLookup:
  # optional: this DNS resolver will be used to perform reverse DNS lookup (typically local router)
  upstream: 192.168.178.1
  # optional: some routers return multiple names for client (host name and user defined name). Define which single name should be used.
  # Example: take second name if present, if not take first name
  singleNameOrder:
    - 2
    - 1
  # optional: custom mapping of client name to IP addresses. Useful if reverse DNS does not work properly or just to have custom client names.
  clients:
    laptop:
      - 192.168.178.29

# optional: configuration for prometheus metrics endpoint
prometheus:
  # enabled if true
  enable: true
  # url path, optional (default '/metrics')
  path: /metrics

# optional: write query information (question, answer, client, duration etc.) to daily csv file
queryLog:
  # optional one of: mysql, postgresql, timescale, csv, csv-client. If empty, log to console
  type: mysql
  # directory (should be mounted as volume in docker) for csv, db connection string for mysql/postgresql
  target: db_user:db_password@tcp(db_host_or_ip:3306)/db_name?charset=utf8mb4&parseTime=True&loc=Local
  #postgresql target: postgres://user:password@db_host_or_ip:5432/db_name
  # if > 0, deletes log files which are older than ... days
  logRetentionDays: 7
  # optional: Max attempts to create specific query log writer, default: 3
  creationAttempts: 1
  # optional: Time between the creation attempts, default: 2s
  creationCooldown: 2s
  # optional: Which fields should be logged. You can choose one or more from: clientIP, clientName, responseReason, responseAnswer, question, duration. If not defined, it logs all fields
  fields:
    - clientIP
    - duration
  # optional: Interval to write data in bulk to the external database, default: 30s
  flushInterval: 30s

# optional: Blocky can synchronize its cache and blocking state between multiple instances through redis.
redis:
  # Server address and port or master name if sentinel is used
  address: redismaster
  # Username if necessary
  username: usrname
  # Password if necessary
  password: passwd
  # Database, default: 0
  database: 2
  # Connection is required for blocky to start. Default: false
  required: true
  # Max connection attempts, default: 3
  connectionAttempts: 10
  # Time between the connection attempts, default: 1s
  connectionCooldown: 3s
  # Sentinal username if necessary
  sentinelUsername: usrname
  # Sentinal password if necessary
  sentinelPassword: passwd
  # List with address and port of sentinel hosts(sentinel is activated if at least one sentinel address is configured)
  sentinelAddresses:
    - redis-sentinel1:26379
    - redis-sentinel2:26379
    - redis-sentinel3:26379

# optional: Mininal TLS version that the DoH and DoT server will use
minTlsServeVersion: 1.3

# if https port > 0: path to cert and key file for SSL encryption. if not set, self-signed certificate will be generated
#certFile: server.crt
#keyFile: server.key

# optional: use these DNS servers to resolve denylist urls and upstream DNS servers. It is useful if no system DNS resolver is configured, and/or to encrypt the bootstrap queries.
bootstrapDns:
  - tcp+udp:1.1.1.1
  - https://1.1.1.1/dns-query
  - upstream: https://dns.digitale-gesellschaft.ch/dns-query
    ips:
      - 185.95.218.42

# optional: drop all queries with following query types. Default: empty
filtering:
  queryTypes:
    - AAAA

# optional: return NXDOMAIN for queries that are not FQDNs.
fqdnOnly:
  # default: false
  enable: true

# optional: if path defined, use this file for query resolution (A, AAAA and rDNS). Default: empty
hostsFile:
  # optional: Hosts files to parse
  sources:
    - /etc/hosts
    - https://example.com/hosts
    - |
      # inline hosts
      127.0.0.1 example.com
  # optional: TTL, default: 1h
  hostsTTL: 30m
  # optional: Whether loopback hosts addresses (127.0.0.0/8 and ::1) should be filtered or not
  # default: false
  filterLoopback: true
  # optional: Configure how sources are loaded
  loading:
    # optional: file refresh period in duration format.
    # Set to a value <= 0 to disable.
    # default: 4h
    refreshPeriod: 24h
    # optional: Applies only to files that are downloaded (HTTP URLs).
    downloads:
      # optional: timeout for file download (each url). Use large values for big files or slow internet connections
      # default: 5s
      timeout: 60s
      # optional: Maximum download attempts
      # default: 3
      attempts: 5
      # optional: Time between the download attempts
      # default: 500ms
      cooldown: 10s
    # optional: Maximum number of files to process in parallel.
    # default: 4
    concurrency: 16
    # Configure startup behavior.
    # accepted: blocking, failOnError, fast
    # default: blocking
    strategy: failOnError
    # Number of errors allowed in a file before it is considered invalid.
    # A value of -1 disables the limit.
    # default: 5
    maxErrorsPerSource: 5

# optional: ports configuration
ports:
  # optional: DNS listener port(s) and bind ip address(es), default 53 (UDP and TCP). Example: 53, :53, "127.0.0.1:5353,[::1]:5353"
  dns: 53
  # optional: Port(s) and bind ip address(es) for DoT (DNS-over-TLS) listener. Example: 853, 127.0.0.1:853
  tls: 853
  # optional: Port(s) and optional bind ip address(es) to serve HTTPS used for prometheus metrics, pprof, REST API, DoH... If you wish to specify a specific IP, you can do so such as 192.168.0.1:443. Example: 443, :443, 127.0.0.1:443,[::1]:443
  https: 443
  # optional: Port(s) and optional bind ip address(es) to serve HTTP used for prometheus metrics, pprof, REST API, DoH... If you wish to specify a specific IP, you can do so such as 192.168.0.1:4000. Example: 4000, :4000, 127.0.0.1:4000,[::1]:4000
  http: 4000

# optional: logging configuration
log:
  # optional: Log level (one from trace, debug, info, warn, error). Default: info
  level: info
  # optional: Log format (text or json). Default: text
  format: text
  # optional: log timestamps. Default: true
  timestamp: true
  # optional: obfuscate log output (replace all alphanumeric characters with *) for user sensitive data like request domains or responses to increase privacy. Default: false
  privacy: false

# optional: add EDE error codes to dns response
ede:
  # enabled if true, Default: false
  enable: true

# optional: configure optional Special Use Domain Names (SUDN)
specialUseDomains:
  # optional: block recomended private TLDs
  # default: true
  rfc6762-appendixG: true
  enable: true

# optional: configure extended client subnet (ECS) support
ecs:
  # optional: if the request ecs option with a max sice mask the address will be used as client ip
  useAsClient: true
  # optional: if the request contains a ecs option it will be forwarded to the upstream resolver
  forward: true

```

## Basic configuration

Example

```
minTlsServeVersion: 1.1
connectIPVersion: v4

```

## Ports configuration

All logging port are optional.

Example

```
ports:
  dns: 53
  http: 4000
  https: 443

```

## Logging configuration

All logging options are optional.

Example

```
log:
  level: debug
  format: json
  timestamp: false
  privacy: true

```

## Init Strategy

A couple of features use an "init/loading strategy" which configures behavior at Blocky startup.  
This applies to all of them. The default strategy is blocking.

## Upstreams configuration

For `init.strategy`, the "init" is testing the given resolvers for each group. The potentially fatal error, depending on the strategy, is if a group has no functional resolvers.

### Upstream Groups

To resolve a DNS query, blocky needs external public or private DNS resolvers. Blocky supports DNS resolvers with following network protocols (net part of the resolver URL):

-   tcp+udp (UDP and TCP, dependent on query type)
-   https (aka DoH)
-   tcp-tls (aka DoT)

Hint

You can (and should!) configure multiple DNS resolvers. Per default blocky uses the `parallel_best` upstream strategy where blocky picks 2 random resolvers from the list for each query and returns the answer from the fastest one.

Each resolver must be defined as a string in following format: `[net:]host:[port][/path][#commonName]`.

The `commonName` parameter overrides the expected certificate common name value used for verification.

Note

Blocky needs at least the configuration of the **default** group with at least one upstream DNS server. This group will be used as a fallback, if no client specific resolver configuration is available.

See [List of public DNS servers](https://0xerr0r.github.io/blocky/latest/additional_information/#list-of-public-dns-servers) if you need some ideas, which public free DNS server you could use.

You can specify multiple upstream groups (additional to the `default` group) to use different upstream servers for different clients, based on client name (see [Client name lookup](https://0xerr0r.github.io/blocky/latest/configuration/#client-name-lookup)), client IP address or client subnet (as CIDR).

Tip

You can use `*` as wildcard for the sequence of any character or `[0-9]` as number range

Example

```
upstreams:
  groups:
    default:
      - 5.9.164.112
      - 1.1.1.1
      - tcp-tls:fdns1.dismail.de:853
      - https://dns.digitale-gesellschaft.ch/dns-query
    laptop*:
      - 123.123.123.123
    10.43.8.67/28:
      - 1.1.1.1
      - 9.9.9.9

```

The above example results in:

-   `123.123.123.123` as the only upstream DNS resolver for clients with a name starting with "laptop"
-   `1.1.1.1` and `9.9.9.9` for all clients in the subnet `10.43.8.67/28`
-   4 resolvers (default) for all others clients.

The logic determining what group a client belongs to follows a strict order: IP, client name, CIDR

If a client matches multiple client name or CIDR groups, a warning is logged and the first found group is used.

### Upstream connection timeout

Blocky will wait 2 seconds (default value) for the response from the external upstream DNS server. You can change this value by setting the `timeout` configuration parameter (in **duration format**).

Example

```
upstreams:
  timeout: 5s
  groups:
    default:
      - 46.182.19.48
      - 80.241.218.68

```

### Upstream strategy

Blocky supports different upstream strategies (default `parallel_best`) that determine how and to which upstream DNS servers requests are forwarded.

Currently available strategies:

-   `parallel_best`: blocky picks 2 random (weighted) resolvers from the upstream group for each query and returns the answer from the fastest one.  
    If an upstream failed to answer within the last hour, it is less likely to be chosen for the race.  
    This improves your network speed and increases your privacy - your DNS traffic will be distributed over multiple providers.  
    (When using 10 upstream servers, each upstream will get on average 20% of the DNS requests)
-   `random`: blocky picks one random (weighted) resolver from the upstream group for each query and if successful, returns its response.  
    If the selected resolver fails to respond, a second one is picked to which the query is sent.  
    The weighting is identical to the `parallel_best` strategy.  
    Although the `random` strategy might be slower than the `parallel_best` strategy, it offers more privacy since each request is sent to a single upstream.
-   `strict`: blocky forwards the request in a strict order. If the first upstream does not respond, the second is asked, and so on.

Example

```
upstreams:
  strategy: strict
  groups:
    default:
      - 1.2.3.4
      - 9.8.7.6

```

## Bootstrap DNS configuration

These DNS servers are used to resolve upstream DoH and DoT servers that are specified as host names, and list domains. It is useful if no system DNS resolver is configured, and/or to encrypt the bootstrap queries.

When using an upstream specified by IP, and not by hostname, you can write only the upstream and skip `ips`.

Note

Works only on Linux/\*nix OS due to golang limitations under Windows.

Example

```
    bootstrapDns:
      - upstream: tcp-tls:dns.example.com
        ips:
        - 123.123.123.123
      - upstream: https://234.234.234.234/dns-query

```

## Filtering

Under certain circumstances, it may be useful to filter some types of DNS queries. You can define one or more DNS query types, all queries with these types will be dropped (empty answer will be returned).

Example

```
filtering:
  queryTypes:
    - AAAA

```

This configuration will drop all 'AAAA' (IPv6) queries.

## FQDN only

In domain environments, it may be useful to only response to FQDN requests. If this option is enabled blocky respond immediately with NXDOMAIN if the request is not a valid FQDN. The request is therefore not further processed by other options like custom or conditional. Please be aware that by enabling it your hostname resolution will break unless every hostname is part of a domain.

## Custom DNS

You can define your own domain name mappings for local DNS resolution. This is useful for creating user-friendly names for network devices, defining domain names for local services, or creating your own DNS zone.

Custom DNS supports multiple record types (A, AAAA, CNAME, TXT, SRV) and provides automatic reverse DNS lookups for defined IP addresses.

### Simple Mapping

The `mapping` parameter allows you to define simple domain-to-IP mappings. You can specify multiple IP addresses for a single domain by separating them with commas.

Example

```
customDNS:
  customTTL: 1h
  mapping:
    printer.lan: 192.168.178.3
    otherdevice.lan: 192.168.178.15,2001:0db8:85a3:08d3:1319:8a2e:0370:7344

```

This configuration will resolve: - `printer.lan` to IPv4 address `192.168.178.3` - `otherdevice.lan` to both IPv4 address `192.168.178.15` and IPv6 address `2001:0db8:85a3:08d3:1319:8a2e:0370:7344`

### Subdomain Resolution

Custom DNS automatically resolves subdomains of defined domains. For example, with the above configuration, queries for `my.printer.lan` or `any.subdomain.of.printer.lan` will also resolve to `192.168.178.3`.

### Domain Rewriting

With the optional `rewrite` parameter, you can replace part of a domain query with another string before resolution is performed:

Example

```
customDNS:
  rewrite:
    home: lan
    example.com: example-rewrite.com
  mapping:
    printer.lan: 192.168.178.3
    example-rewrite.com: 1.2.3.4

```

With this configuration: - A query for `printer.home` will be rewritten to `printer.lan` and return `192.168.178.3` - A query for `sub.example.com` will be rewritten to `sub.example-rewrite.com` and return `1.2.3.4`

### Zone File

For more complex configurations, you can use the `zone` parameter to define a DNS zone file:

Example

```
customDNS:
  zone: |
    $ORIGIN example.com.
    www 3600 A 1.2.3.4
    www 3600 AAAA 2001:db8:85a3::8a2e:370:7334
    @ 3600 CNAME www

```

The zone file supports standard DNS zone file syntax including: - `$ORIGIN` - sets the origin for relative domain names - `$TTL` - sets the default TTL for records in the zone - `$INCLUDE` - includes another zone file relative to the blocky executable - `$GENERATE` - generates a range of records

For records defined using the `zone` parameter, the `customTTL` parameter is unused. Instead, the TTL is defined in the zone directly.

### CNAME Resolution

When a CNAME record is defined and a query matches that record, blocky will: 1. Return the CNAME record in the answer 2. Additionally resolve the target of the CNAME and include those records in the answer 3. Protect against CNAME loops (where CNAMEs point to each other in a loop)

### Reverse DNS

Blocky automatically creates reverse DNS (PTR) records for all defined A and AAAA records. This allows reverse lookups from IP addresses to domain names.

### Filtering Unmapped Types

With `filterUnmappedTypes = true` (default), blocky will filter all queries with unmapped types. For example, if you only define an A record for `printer.lan`, an AAAA query for the same domain will return an empty result.

With `filterUnmappedTypes = false`, unmapped type queries will be forwarded to the upstream DNS server. For example, an AAAA query for `printer.lan` (when only an A record is defined) will be sent to the upstream resolver.

## Conditional DNS resolution

You can define, which DNS resolver(s) should be used for queries for the particular domain (with all subdomains). This is for example useful, if you want to reach devices in your local network by the name. Since only your router know which hostname belongs to which IP address, all DNS queries for the local network should be redirected to the router.

The optional parameter `rewrite` behaves the same as with custom DNS.

The optional parameter `fallbackUpstream`, if false (default), return empty result if after rewrite, the mapped resolver returned an empty answer. If true, the original query will be sent to the upstream resolver.

**Usage:** One usecase when having split DNS for internal and external (internet facing) users, but not all subdomains are listed in the internal domain

Example

```
conditional:
  fallbackUpstream: false
  rewrite:
    example.com: fritz.box
    replace-me.com: with-this.com
  mapping:
    fritz.box: 192.168.178.1
    lan.net: 192.170.1.2,192.170.1.3
    # for reverse DNS lookups of local devices
    178.168.192.in-addr.arpa: 192.168.178.1
    # for all unqualified hostnames
    .: 168.168.0.1

```

Tip

You can use `.` as wildcard for all non full qualified domains (domains without dot)

In this example, a DNS query "client.fritz.box" will be redirected to the router's DNS server at 192.168.178.1 and client.lan.net to 192.170.1.2 and 192.170.1.3. The query "client.example.com" will be rewritten to "client.fritz.box" and also redirected to the resolver at 192.168.178.1.

If not found and if `fallbackUpstream` was set to `true`, the original query "blog.example.com" will be sent upstream.

All unqualified host names (e.g. "test") will be redirected to the DNS server at 168.168.0.1.

One usecase for `fallbackUpstream` is when having split DNS for internal and external (internet facing) users, but not all subdomains are listed in the internal domain.

## Client name lookup

Blocky can try to resolve a user-friendly client name from the IP address or server URL (DoT and DoH). This is useful for defining of blocking groups, since IP address can change dynamically.

### Resolving client name from URL/Host

If DoT or DoH is enabled, you can use a subdomain prefixed with `id-` to provide a client name (wildcard ssl certificate recommended).

Example: domain `example.com`

DoT Host: `id-bob.example.com` -> request's client name is `bob` DoH URL: `https://id-bob.example.com/dns-query` -> request's client name is `bob`

For DoH you can also pass the client name as url parameter:

DoH URL: `https://blocky.example.com/dns-query/alice` -> request's client name is `alice`

### Resolving client name from IP address

Blocky uses rDNS to retrieve client's name. To use this feature, you can configure a DNS server for client lookup ( typically your router). You can also define client names manually per IP address.

#### Single name order

Some routers return multiple names for the client (host name and user defined name). With parameter `clientLookup.singleNameOrder` you can specify, which of retrieved names should be used.

#### Custom client name mapping

You can also map a particular client name to one (or more) IP (ipv4/ipv6) addresses. Parameter `clientLookup.clients` contains a map of client name and multiple IP addresses.

Example

```
clientLookup:
  upstream: 192.168.178.1
  singleNameOrder:
    - 2
    - 1
  clients:
    laptop:
      - 192.168.178.29

```

Use `192.168.178.1` for rDNS lookup. Take second name if present, if not take first name. IP address `192.168.178.29` is mapped to `laptop` as client name.

## Blocking and allowlisting

Blocky can use lists of domains and IPs to block (e.g. advertisement, malware, trackers, adult sites). You can group several list sources together and define the blocking behavior per client. Blocking uses the [DNS sinkhole](https://en.wikipedia.org/wiki/DNS_sinkhole) approach. For each DNS query, the domain name from the request, IP address from the response, and any CNAME records will be checked to determine whether to block the query or not.

To avoid over-blocking, you can use allowlists.

### Definition allow/denylists

Lists are defined in groups. This allows using different sets of lists for different clients.

Each list in a group is a "source" and can be downloaded, read from a file, or inlined in the config. See [Sources](https://0xerr0r.github.io/blocky/latest/configuration/#sources) for details and configuring how those are loaded and reloaded/refreshed.

The supported list formats are:

1.  the well-known [Hosts format](https://en.wikipedia.org/wiki/Hosts_(file))
2.  one domain per line (plain domain list)
3.  one wildcard per line
4.  one regex per line

Example

```
blocking:
  denylists:
    ads:
      - https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
      - https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
      - |
        # inline definition using YAML literal block scalar style
        # content is in plain domain list format
        someadsdomain.com
        anotheradsdomain.com
        *.wildcard.example.com # blocks wildcard.example.com and all subdomains
      - |
        # inline definition with a regex
        /^banners?[_.-]/
    special:
      - https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts
  allowlists:
    ads:
      - allowlist.txt
      - /path/to/file.txt
      - |
        # inline definition with YAML literal block scalar style
        allowlistdomain.com

```

In this example you can see 2 groups: **ads** and **special** with one list. The **ads** group includes 2 inline lists.

Warning

If the same group has **both** allow/denylists, allowlists take precedence. Meaning if a domain is both blocked and allowed, it will be allowed. If a group has **only allowlist** entries, only domains from this list are allowed, and all others be blocked.

Warning

You must also define a client group mapping, otherwise the allow/denylist definitions will have no effect.

#### Wildcard support

You can use wildcards to block a domain and all its subdomains. Example: `*.example.com` will block `example.com` and `any.subdomains.example.com`.

#### Regex support

You can use regex to define patterns to block. A regex entry must start and end with the slash character (`/`). Some Examples:

-   `/baddomain/` will block `www.baddomain.com`, `baddomain.com`, but also `mybaddomain-sometext.com`
-   `/^baddomain/` will block `baddomain.com`, but not `www.baddomain.com`
-   `/^apple\.(de|com)$/` will only block `apple.de` and `apple.com`

Warning

Regexes use more a lot more memory and are much slower than wildcards, you should use them as a last resort.

### Client groups

In this configuration section, you can define, which blocking group(s) should be used for which client in your network. Example: All clients should use the **ads** group, which blocks advertisement and kids devices should use the **adult** group, which blocky adult sites.

Clients without an explicit group assignment will use the **default** group.

You can use the client name (see [Client name lookup](https://0xerr0r.github.io/blocky/latest/configuration/#client-name-lookup)), client's IP address, client's full-qualified domain name or a client subnet as CIDR notation.

If full-qualified domain name is used (for example "myclient.ddns.org"), blocky will try to resolve the IP address (A and AAAA records) of this domain. If client's IP address matches with the result, the defined group will be used.

Example

```
blocking:
  clientGroupsBlock:
  # default will be used, if no special definition for a client name exists
    default:
      - ads
      - special
    laptop*:
      - ads
    192.168.178.1/24:
      - special
    kid-laptop:
      - ads
      - adult

```

All queries from network clients, whose device name starts with `laptop`, will be filtered against the **ads** group's lists. All devices from the subnet `192.168.178.1/24` against the **special** group and `kid-laptop` against **ads** and **adult**. All other clients: **ads** and **special**.

Tip

You can use `*` as wildcard for the sequence of any character or `[0-9]` as number range

### Block type

You can configure, which response should be sent to the client, if a requested query is blocked (only for A and AAAA queries, NXDOMAIN for other types):

Example

```
blocking:
  blockType: nxDomain

```

### Block TTL

TTL for answers to blocked domains can be set to customize the time (in **duration format**) clients ask for those domains again. Default Block TTL is **6hours**. This setting only makes sense when `blockType` is set to `nxDomain` or `zeroIP`, and will affect how much time it could take for a client to be able to see the real IP address for a domain after receiving the custom value.

Example

```
blocking:
  blockType: 192.100.100.15, 2001:0db8:85a3:08d3:1319:8a2e:0370:7344
  blockTTL: 10s

```

### Lists Loading

See [Sources Loading](https://0xerr0r.github.io/blocky/latest/configuration/#sources-loading).

## Caching

Each DNS response has a TTL (Time-to-live) value. This value defines, how long is the record valid in seconds. The values are maintained by domain owners, server administrators etc. Blocky caches the answers from all resolved queries in own cache in order to avoid repeated requests. This reduces the DNS traffic and increases the network speed, since blocky can serve the result immediately from the cache.

With following parameters you can tune the caching behavior:

Warning

Wrong values can significantly increase external DNS traffic or memory consumption.

Example

```
caching:
  minTime: 5m
  maxTime: 30m
  prefetching: true
  exclude:
    - /.*\.lan$/
    - /.*\.local$/
    - /.*\.host\.com\.(jp|fr)$/

```

## Redis

Blocky can synchronize its cache and blocking state between multiple instances through redis. Synchronization is disabled if no address is configured.

Example

```
redis:
  address: redismaster
  username: usrname
  password: passwd
  database: 2
  required: true
  connectionAttempts: 10
  connectionCooldown: 3s
  sentinelUsername: sentUsrname
  sentinelPassword: sentPasswd
  sentinelAddresses:
    - redis-sentinel1:26379
    - redis-sentinel2:26379
    - redis-sentinel3:26379

```

## Prometheus

Blocky can expose various metrics for prometheus. To use the prometheus feature, the HTTP listener must be enabled ( see [Basic Configuration](https://0xerr0r.github.io/blocky/latest/configuration/#basic-configuration)).

Example

```
prometheus:
  enable: true
  path: /metrics

```

## Query logging

You can enable the logging of DNS queries (question, answer, client, duration etc.) to a daily CSV file (can be opened in Excel or OpenOffice Calc) or MySQL/MariaDB database.

Warning

Query file/database contains sensitive information. Please ensure to inform users, if you log their queries.

### Query log types

You can select one of following query log types:

-   `mysql`: log each query in the external MySQL/MariaDB database
-   `postgresql`: log each query in the external PostgreSQL database
-   `timescale`: log each query in the external Timescale database
-   `csv`: log into CSV file (one per day)
-   `csv-client`: log into CSV file (one per day and per client)
-   `console`: log into console output
-   `none`: do not log any queries

### Query log fields

You can choose which information from processed DNS request and response should be logged in the target system. You can define one or more of following fields:

-   `clientIP`: origin IP address from the request
-   `clientName`: resolved client name(s) from the origins request
-   `responseReason`: reason for the response (e.g. from which upstream resolver), response type and code
-   `responseAnswer`: returned DNS answer
-   `question`: DNS question from the request
-   `duration`: request processing time in milliseconds

Hint

If not defined, blocky will log all available information

Configuration parameters:

Hint

Please ensure, that the log directory is writable or database exists. If you use docker, please ensure, that the directory is properly mounted (e.g. volume)

### Database URLs

To connect to a database, you must provide a URL like value for `target`. The exact format and supported parameters depends on the DB type. Parsing is handled not by Blocky, but third-party libraries, therefore the full documentation is external.

Note

For increased security, it is recommended to configure the password for a PostgreSQL/Timescale connection via the `PGPASSFILE` environment variable.

### Examples

Example

**CSV format with limited logging information**

```
```yaml
queryLog:
  type: csv
  target: /logs
  logRetentionDays: 7
  fields:
  - clientIP
  - duration
  flushInterval: 30s
```

```

Example

**MySQL Database**

```
queryLog:
  type: mysql
  target: 'username:password@tcp(localhost:3306)/blocky_query_log?charset=utf8mb4&parseTime=True&loc=Local&timeout=15s'
  logRetentionDays: 7

```

## Hosts file

You can enable resolving of entries, located in local hosts file.

Configuration parameters:

Example

```
hostsFile:
  filePath: /etc/hosts
  hostsTTL: 1h
  refreshPeriod: 30m
  loading:
    strategy: fast

```

## Deliver EDE codes as EDNS0 option

DNS responses can be extended with EDE codes according to [RFC8914](https://datatracker.ietf.org/doc/rfc8914/).

Configuration parameters:

## EDNS Client Subnet options

EDNS Client Subnet (ECS) configuration parameters:

Example

```
ecs:
  ipv4Mask: 32
  ipv6Mask: 128

```

## Special Use Domain Names

SUDN (Special Use Domain Names) are always enabled by default as they are required by various RFCs.  
Some RFCs have optional recommendations, which are configurable as described below. However, you can completely deactivate the blocking of SUDN by setting enable to false. Warning! You should only disable this if your upstream DNS server is local, as it shouldn't be disabled for remote upstreams.

Configuration parameters:

Example

```
specialUseDomains:
  rfc6762-appendixG: true

```

Example

```
specialUseDomains:
  enable: false

```

## SSL certificate configuration (DoH / TLS listener)

See [Wiki - Configuration of HTTPS](https://github.com/0xERR0R/blocky/wiki/Configuration-of-HTTPS-for-DoH-and-Rest-API) for detailed information, how to create and configure SSL certificates.

DoH url: `https://host:port/dns-query`

## Sources

Sources are a concept shared by the blocking and hosts file resolvers. They represent where to load the files for each resolver.

The supported source types are:

-   HTTP(S) URL (any source starting with `http`)
-   inline configuration (any source containing a newline)
-   local file path (any source not matching the above rules)

Note

The format/content of the sources depends on the context: lists and hosts files have different, but overlapping, supported formats.

Example

```
- https://example.com/a/source # blocky will download and parse the file
- /a/file/path # blocky will read the local file
- | # blocky will parse the content of this multi-line string
  # inline configuration

```

### Sources Loading

This sections covers `loading` configuration that applies to both the blocking and hosts file resolvers. These settings apply only to the resolver under which they are nested.

Example

```
blocking:
  loading:
    # only applies to allow/denylists

hostsFile:
  loading:
    # only applies to hostsFile sources

```

#### Refresh / Reload

To keep source contents up-to-date, blocky can periodically refresh and reparse them. Default period is **4 hours**. You can configure this by setting the `refreshPeriod` parameter to a value in **duration format**.  
A value of zero or less will disable this feature.

Example

```
loading:
  refreshPeriod: 1h

```

Refresh every hour.

### Downloads

Configures how HTTP(S) sources are downloaded:

Example

```
loading:
  downloads:
    timeout: 4m
    attempts: 5
    cooldown: 10s

```

### Strategy

See [Init Strategy](https://0xerr0r.github.io/blocky/latest/configuration/#init-strategy).  
In this context, "init" is loading and parsing each source, and an error is a single source failing to load/parse.

Example

```
loading:
  strategy: failOnError

```

### Max Errors per Source

Number of errors allowed when parsing a source before it is considered invalid and parsing stops.  
A value of -1 disables the limit.

Example

```
loading:
  maxErrorsPerSource: 10

```

### Concurrency

Blocky downloads and processes sources concurrently. This allows limiting how many can be processed in the same time.  
Larger values can reduce the overall list refresh time at the cost of using more RAM. Please consider reducing this value on systems with limited memory.  
Default value is 4.

Note

As with other settings under `loading`, the limit applies to the blocking and hosts file resolvers separately. The total number of concurrent sources concurrently processed can reach the sum of both values. For example if blocking has a limit set to 8 and hosts file's is 4, there could be up to 12 concurrent jobs.