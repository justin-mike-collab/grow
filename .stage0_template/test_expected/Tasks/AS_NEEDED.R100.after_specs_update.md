# R100 – Update files after architecture.yaml changes

**Status**: Planned  
**Task Type**: Updates
**Run Mode**: Run as needed

## Goal

Update the Developer Edition docker-compose.yaml, and the welcome page index.html with changes after the architecture.yaml file has been updated with new services.

## Context / Input files

These files must be treated as **inputs** and read before implementation:

- `Specifications/architecture.yaml`

**Target files** (to be updated):

- `DeveloperEdition/docker-compose.yaml`
- `index.html` (welcome page)

## Requirements

Update `DeveloperEdition/docker-compose.yaml` and the welcome page `index.html` to match the services defined in `Specifications/architecture.yaml`.

### docker-compose.yaml

- Add or update service definitions for each domain in the architecture (runbook, schema/mongodb, profile, mentor, member, etc.).
- **For each microservice domain, define two profiles:**
  - `{domain}-api` – API service only (e.g. `profile-api` → profile_api)
  - `{domain}` – API + SPA (e.g. `profile` → profile_api + profile_spa)
- Ensure backing services (e.g. mongodb) are included in the profiles of any service that depends on them.

### index.html

- Add links for each service SPA (with correct ports from the architecture).
- Add an API Explorer link for each backing API (e.g. `/docs/index.html` or `/docs/explorer.html` as appropriate for each service type).

## Testing expectations

- **None**

## Packaging / build checks

Before marking this task as completed:
- Run ``make container`` and ensure that the container builds cleanly.

## Dependencies / Ordering

- Should run **after**:
  - **None**
- Should run **before**:
  - **None**

## Implementation notes (to be updated by the agent)

**Summary of changes**
- Updated files: _high‑level summary of changes_

**Testing results**
- Packaging/build: _command(s) run, high‑level outcome_

**Follow‑up tasks**
- _e.g., "Publish updated container images."_

