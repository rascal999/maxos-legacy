## 🐋 Docker MCP server

[](https://github.com/ckreiling/mcp-server-docker#-docker-mcp-server)

An MCP server for managing Docker with natural language!

## 🪩 What can it do?

[](https://github.com/ckreiling/mcp-server-docker#-what-can-it-do)

-   🚀 Compose containers with natural language
-   🔍 Introspect & debug running containers
-   📀 Manage persistent data with Docker volumes

## ❓ Who is this for?

[](https://github.com/ckreiling/mcp-server-docker#-who-is-this-for)

-   Server administrators: connect to remote Docker engines for e.g. managing a public-facing website.
-   Tinkerers: run containers locally and experiment with open-source apps supporting Docker.
-   AI enthusiasts: push the limits of that an LLM is capable of!

## Demo

[](https://github.com/ckreiling/mcp-server-docker#demo)

A quick demo showing a WordPress deployment using natural language:

mcp-docker-wp-demo.mp4

## 🏎️ Quickstart

[](https://github.com/ckreiling/mcp-server-docker#%EF%B8%8F-quickstart)

### Install

[](https://github.com/ckreiling/mcp-server-docker#install)

#### Claude Desktop

[](https://github.com/ckreiling/mcp-server-docker#claude-desktop)

On MacOS: `~/Library/Application\ Support/Claude/claude_desktop_config.json`

On Windows: `%APPDATA%/Claude/claude_desktop_config.json`

Install from PyPi with uv

If you don't have `uv` installed, follow the installation instructions for your system: [link](https://docs.astral.sh/uv/getting-started/installation/#installation-methods)

Then add the following to your MCP servers file:

```
"mcpServers": {
  "mcp-server-docker": {
    "command": "uvx",
    "args": [
      "mcp-server-docker"
    ]
  }
}
```
Install with Docker

Purely for convenience, the server can run in a Docker container.

After cloning this repository, build the Docker image:

```shell
docker build -t mcp-server-docker .
```

And then add the following to your MCP servers file:

```
"mcpServers": {
  "mcp-server-docker": {
    "command": "docker",
    "args": [
      "run",
      "-i",
      "--rm",
      "-v",
      "/var/run/docker.sock:/var/run/docker.sock",
      "mcp-server-docker:latest"
    ]
  }
}
```

Note that we mount the Docker socket as a volume; this ensures the MCP server can connect to and control the local Docker daemon.

## 📝 Prompts

[](https://github.com/ckreiling/mcp-server-docker#-prompts)

### 🎻 `docker_compose`

[](https://github.com/ckreiling/mcp-server-docker#-docker_compose)

Use natural language to compose containers. [See above](https://github.com/ckreiling/mcp-server-docker#demo) for a demo.

Provide a Project Name, and a description of desired containers, and let the LLM do the rest.

This prompt instructs the LLM to enter a `plan+apply` loop. Your interaction with the LLM will involve the following steps:

1.  You give the LLM instructions for which containers to bring up
2.  The LLM calculates a concise natural language plan and presents it to you
3.  You either:
    -   Apply the plan
    -   Provide the LLM feedback, and the LLM recalculates the plan

#### Examples

[](https://github.com/ckreiling/mcp-server-docker#examples)

-   name: `nginx`, containers: "deploy an nginx container exposing it on port 9000"
-   name: `wordpress`, containers: "deploy a WordPress container and a supporting MySQL container, exposing Wordpress on port 9000"

#### Resuming a Project

[](https://github.com/ckreiling/mcp-server-docker#resuming-a-project)

When starting a new chat with this prompt, the LLM will receive the status of any containers, volumes, and networks created with the given project `name`.

This is mainly useful for cleaning up, in-case you lose a chat that was responsible for many containers.

## 📔 Resources

[](https://github.com/ckreiling/mcp-server-docker#-resources)

The server implements a couple resources for every container:

-   Stats: CPU, memory, etc. for a container
-   Logs: tail some logs from a container

## 🔨 Tools

[](https://github.com/ckreiling/mcp-server-docker#-tools)

### Containers

[](https://github.com/ckreiling/mcp-server-docker#containers)

-   `list_containers`
-   `create_container`
-   `run_container`
-   `recreate_container`
-   `start_container`
-   `fetch_container_logs`
-   `stop_container`
-   `remove_container`

### Images

[](https://github.com/ckreiling/mcp-server-docker#images)

-   `list_images`
-   `pull_image`
-   `push_image`
-   `build_image`
-   `remove_image`

### Networks

[](https://github.com/ckreiling/mcp-server-docker#networks)

-   `list_networks`
-   `create_network`
-   `remove_network`

### Volumes

[](https://github.com/ckreiling/mcp-server-docker#volumes)

-   `list_volumes`
-   `create_volume`
-   `remove_volume`

## 🚧 Disclaimers

[](https://github.com/ckreiling/mcp-server-docker#-disclaimers)

### Sensitive Data

[](https://github.com/ckreiling/mcp-server-docker#sensitive-data)

**DO NOT CONFIGURE CONTAINERS WITH SENSITIVE DATA.** This includes API keys, database passwords, etc.

Any sensitive data exchanged with the LLM is inherently compromised, unless the LLM is running on your local machine.

If you are interested in securely passing secrets to containers, file an issue on this repository with your use-case.

### Reviewing Created Containers

[](https://github.com/ckreiling/mcp-server-docker#reviewing-created-containers)

Be careful to review the containers that the LLM creates. Docker is not a secure sandbox, and therefore the MCP server can potentially impact the host machine through Docker.

For safety reasons, this MCP server doesn't support sensitive Docker options like `--privileged` or `--cap-add/--cap-drop`. If these features are of interest to you, file an issue on this repository with your use-case.

## 🛠️ Configuration

[](https://github.com/ckreiling/mcp-server-docker#%EF%B8%8F-configuration)

This server uses the Python Docker SDK's `from_env` method. For configuration details, see [the documentation](https://docker-py.readthedocs.io/en/stable/client.html#docker.client.from_env).

### Connect to Docker over SSH

[](https://github.com/ckreiling/mcp-server-docker#connect-to-docker-over-ssh)

This MCP server can connect to a remote Docker daemon over SSH.

Simply set a `ssh://` host URL in the MCP server definition:

```
"mcpServers": {
  "mcp-server-docker": {
    "command": "uvx",
    "args": [
      "mcp-server-docker"
    ],
    "env": {
      "DOCKER_HOST": "ssh://myusername@myhost.example.com"
    }
  }
}
```

## 💻 Development

[](https://github.com/ckreiling/mcp-server-docker#-development)

Prefer using Devbox to configure your development environment.

See the `devbox.json` for helpful development commands.

After setting up devbox you can configure your Claude MCP config to use it:

```
  "docker": {
    "command": "/path/to/repo/.devbox/nix/profile/default/bin/uv",
    "args": [
      "--directory",
      "/path/to/repo/",
      "run",
      "mcp-server-docker"
    ]
  },
```