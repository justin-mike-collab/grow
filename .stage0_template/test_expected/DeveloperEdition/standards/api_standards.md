# API Standards

## Technology Stack
- Python v3.12^
- pipenv v2026.0.2
- Flask v
- pymongo v4.15.5
- PyJWT v
- prometheus-flask-exporter v
- pytest for unit testing
- pytest-cov for code coverage
- requests for E2E testing

## Dependency Management
- All dependencies are managed via `Pipfile` and `Pipfile.lock`
- The `api_utils` shared library is installed via HTTPS from GitHub using Personal Access Tokens (PATs)
- Docker builds use `GITHUB_TOKEN` build argument for authentication
- Local development requires git credential configuration (see Developer Edition [README](../README.md))

## Standard Developer Commands
- pipenv run build (package code for deployment)
- pipenv run dev (run dev server)
- pipenv run db (start backing db container)
- pipenv run api (start db + api containers)
- pipenv run service (start db, api, spa containers)
- pipenv run container (build API container)

## API Design
- Create, Retrieve, Patch design pattern
- API's work with a model-less document management approach
- Open API Specification (swagger) is a Design Specification, NOT a code build artifact
- Route blueprints use factory functions (e.g., `create_*_routes()`) that return Flask Blueprints
- Route registration should be grouped together in `server.py` for clarity

## Separation of Concerns
- `server.py` is the standard API entry point
- `command.py` is the standard CLI entry point
- `/routes/*domain*_routes.py` handle HTTP request/response logic
- `/services/*domain*_service.py` handles business logic/RBAC for domain

# api_utils standards
The api_utils library implements standard API features and functions, with a goal of making it easy to comply with standards. 

### Required Endpoints
All APIs must implement the following standard endpoints:

- **`/metrics`** - Prometheus metrics endpoint (use api_utils metric_routes`)
  - **Note**: `create_metric_routes()` is middleware that wraps the Flask app directly, not a blueprint.
- **`/api/config`** - Configuration endpoint (use api_utils config routes`)
- **`/dev-login`** - Development JWT token issuance (use ap_utils dev_login routes`)
- **`/docs/*`** - API explorer/OpenAPI documentation (use api_utils explorer routes`)
  - **OpenAPI Spec**: All API's must maintain `docs/openapi.yaml` specification

## Server.py Organization Pattern
All API servers should follow the organizational pattern established in api_utils/server.py:

1. **Module docstring** - Describe the server purpose and capabilities
2. **Imports** - `sys`, `os`, `signal`, `api_utils`, Flask imports
3. **Config singleton initialization** - Initialize before logging
4. **MongoIO singleton and configuration** - Set enumerators and versions
5. **Flask app initialization** - Create app with MongoJSONEncoder
6. **Route registration** - Register all routes
7. **Logging summary** - Clear summary of registered routes
8. **Signal handlers** - SIGTERM and SIGINT for graceful shutdown
9. **Main entry point** - `if __name__ == "__main__"` block

- **Config Singleton**: Use `Config.get_instance()` for all configuration values
  - Configuration follows precedence: Config File → Environment Variable → Default Value
  - Non-secret values are exposed via `/api/config` endpoint
  
- **MongoIO Singleton**: Use `MongoIO.get_instance()` for all MongoDB operations
  - Provides connection pooling and error handling
  - Thin wrapper around MongoDB pymongo library
  - Supports enumerators and versions on initialization
  - Responsible for all MongoDB IO operations

- **Flask Utilities**:
  - `create_flask_token()` - Extract and validate JWT tokens from Authorization header
  - `create_flask_breadcrumb(token)` - Generate request breadcrumbs for logging
  - `handle_route_exceptions` - Decorator for consistent exception handling
  - `MongoJSONEncoder` - Custom JSON encoder for MongoDB document types
  - Custom exceptions: `HTTPUnauthorized`, `HTTPForbidden`, `HTTPNotFound`, `HTTPInternalServerError`
  - **Security**: Do not include PII or User Data in exceptions

- **Protected Routes**: Use `@handle_route_exceptions` decorator and `create_flask_token()` to protect routes:
  ```python
  @route.route('/protected', methods=['GET'])
  @handle_route_exceptions
  def protected_route():
      token = create_flask_token()  # Validates JWT signature, raises HTTPUnauthorized if invalid
      breadcrumb = create_flask_breadcrumb(token)
      # ... route logic
  ```