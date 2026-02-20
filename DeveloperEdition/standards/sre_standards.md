# SRE Standards

## Tech Stack
- Source Control: Github 
- CI Automation: Github Actions
- Private Container Registry: GitHub Container Registry till AWS refactor
- Private PyPi Registry: GitHub via https+token till JFrog refactor
- Private NPM Registry: GitHub Packages till JFrog refactor
- Infrastructure Automation: Docker Compose till Terraform refactor
- Container Hosting: AWS EKS?
- Container Configuration: Helm? 
- Container Orchestration: Argo CD?
- Monitoring: Prometheus, Grafana, ELK
- Runbook Automation: [stage0 runbooks](https://github.com/agile-learning-institute/stage0_runbooks)

## Developer Experience
The ``{{info.developer_cli}}`` Developer Edition script is how the SRE's provide a strong developer experience. 
This script manages developer environment values (keys, secrets, etc.) and wraps the services configured in this [docker-compose](../docker-compose.yaml) file. Developers are always able to run services in isolation on local hardware, and the ``de`` command makes it easy.

**Authentication Security**: The `de` script automatically generates a timestamp-based `JWT_SECRET` on each execution, ensuring authentication tokens are invalidated after server restarts. This security pattern is implemented for runbook services and will be extended to other services as they are refactored. 

## SRE Automation 
SRE Automation is done using the [stage0 runbooks](https://github.com/agile-learning-institute/stage0_runbooks) system. Our custom runbook is [runbook_api]({{org.git_host}}/{{org.git_org}}/{{info.slug}}_runbook_api) which is available for use with ``de up runbook`` and accessing http://localhost and following the runbooks link. 

## Continuous Integration
The developer workflow follows the feature branch pattern. A developer creates a branch to work on a feature, and submit a pull request (PR) when the feature is ready to be deployed. When a PR is approved by a reviewer and merged to the main branch, the CI automation will build and push a new container with a :latest tag to the system's container registry. These containers are deployed to a cloud DEV environment, and available for developers to use for local development.

NOTE: We are using ``ghcr`` as our container registry at this time. We will shift to an AWS container registry when we are ready to start cloud based deployments. 

## Continuous Deployment
Infrastructure provisioning is automated using ?Terraform?. Deployment of code through different environments is managed using container tagging. TBD Run book automation implements continuous deployment actions such as "Provision a Training Environment", "Run Regression Testing in the TEST environment", "Promote all containers from TEST to STAGING" or "Restore Production Database backups to Staging Database"

## API Reverse Proxy
All SPA's are served by NGINX with reverse proxy configuration for API endpoints. This allows for secure networking configurations that do not expose the API to external access, establishing a clear separation between the front end and back end networks.

### NGINX Configuration Pattern
SPA containers use an NGINX configuration template (`nginx.conf.template`) that is processed at container startup using `envsubst`. The template supports the following environment variables:

- **`API_HOST`**: Hostname of the API server (default: `localhost`)
- **`API_PORT`**: Port of the API server (default: `8083`)
- **`IDP_LOGIN_URI`**: Full URI for IdP login redirect (default: `http://localhost:8084/login`)

### Reverse Proxy Routes
The NGINX configuration proxies the following routes to the API server:

- **`/api/*`**: All API endpoints are proxied to `http://${API_HOST}:${API_PORT}/api/`
- **`/dev-login`**: Development login endpoint is proxied to `http://${API_HOST}:${API_PORT}/dev-login`
  - The API controls access via `ENABLE_LOGIN` configuration (returns 404 if disabled)
  - This allows the SPA to use a consistent `/dev-login` path regardless of deployment environment

### Authentication Redirect Pattern
Protected routes in the SPA redirect unauthenticated users to `/auth/login`, which NGINX then redirects to the configured `IDP_LOGIN_URI`:

- **Local Development**: Defaults to `http://localhost:8084/login` (same-origin)
- **Remote Deployment**: Can be configured to external IdP (e.g., `http://spark-478a.tailb0d293.ts.net:8084/login`)
- The redirect preserves query parameters (e.g., `return_url`) for post-login navigation

This pattern ensures consistent authentication flow across all deployment environments while maintaining security boundaries. 

## Service Configurability
All API's are configured using a shared [Config singleton]({{org.git_host}}/{{org.git_org}}/api_utils/blob/main/py_utils/config/config.py). The Config object manages all configuration items for all API and SPA code. Configuration values are read from the first of: Config File, Environment Var, Default Value. The configuration items and non-secret values are exposed through the Config API endpoint, which is used by the SPA to get runtime configuration values.

## Service Observability
All API's expose a /metrics endpoint which exposes a text-based exposition format that Prometheus understands. This endpoint exposes detailed, real-time metrics about the API's performance, latency, error rates, and internal health.

## API Security Standards

### Production Requirements

Before deploying any API to production, ensure:

- [ ] `JWT_SECRET` is set to a strong, randomly generated value (not default)
- [ ] `ENABLE_LOGIN` is set to `false` or not set (default is false)
- [ ] MongoDB connection uses authentication and encryption
- [ ] HTTPS/TLS is configured via reverse proxy
- [ ] Monitoring and logging are enabled
- [ ] All dependencies are up to date

### JWT Security

- **Signature Verification**: api_utils validates JWT signatures when `JWT_SECRET` is configured
- **Fail-Fast Validation**: Applications will not start with default `JWT_SECRET` value
- **Token Requirements**: All tokens must include `iss`, `aud`, `sub`, `exp` claims
- **Secret Rotation**: Plan for regular secret rotation in production environments

### Development vs Production

| Feature | Development | Production |
|---------|-------------|------------|
| `ENABLE_LOGIN` | `true` (set by de script) | `false` (never enable) |
| `JWT_SECRET` | Timestamp-based | Strong random value |
| Token Validation | Full signature verification | Full signature verification |
| `/dev-login` | Available at localhost | 404 (disabled) |
| Logging | INFO or DEBUG | WARNING or ERROR |

## API Container Configuration
- Dockerfile must define `API_HOST` and `API_PORT` environment variables
- NGINX configuration template (`nginx.conf.template` or `default.conf.template`) must use `${API_HOST}` and `${API_PORT}` in proxy_pass directive
- Template pattern: `proxy_pass http://${API_HOST}:${API_PORT}/api/;`
- NGINX automatically substitutes environment variables from templates in `/etc/nginx/templates/`
- Container exposes port 80 by default (or `SPA_PORT` if specified)