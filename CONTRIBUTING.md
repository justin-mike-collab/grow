# {{info.name}} Developer Edition

The {{info.name}} Developer Edition ``{{info.developer_cli}}`` is a Command Line Interface that provides key components of the developer experience. This CLI wraps docker compose commands, and secret management for local development environments. All developers should install this tooling, create and configure tokens, and review the linked standards before contributing to any repo.

## Prerequisites
- **Docker Desktop** - https://www.docker.com/get-started/
- **zsh shell** - Default on MacOS, https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH otherwise
- **yq** - Yaml Parser, ``brew install yq`` on Mac or https://mikefarah.gitbook.io/yq
- **Mongo Compass** - https://www.mongodb.com/docs/compass/install/
- **Python 3.12^** - https://www.python.org/downloads/
- **Pipenv** - https://pipenv.pypa.io/en/latest/
- **Node npm 11.5^** - https://nodejs.org/en/download 
- **WSL** - For windows users - https://learn.microsoft.com/en-us/windows/wsl/install

## Quick Start
Use these commands to install the Developer Edition ``de`` command line utility. 
```sh
git clone git@{{org.git_host}}:{{org.git_org}}/{{info.slug}}.git
cd {{info.slug}}
make install
cp <YOUR_TOKEN> ~/.{{info.slug}}/GITHUB_TOKEN
make update

```

## Configure access tokens
When local environment values are required (GitHub access tokens, etc.) they are stored in the hidden folder ``~/.{{info.slug}}`` instead of a being replicated across multiple repo level .env files. 

## GITHUB_TOKEN
We are using GitHub to publish the api_utils pypi package, the spa_utils npm package, and GitHub Container Registry to publish containers. You should create a GitHub classic access token with `repo` `workflow`, and `write:packages` privileges. This token should be saved in ``~/.{{info.slug}}/GITHUB_TOKEN``. 

To create a token, login to GitHub and click your Profile Pic -> Settings -> Developer Settings -> Personal access tokens -> Tokens(classic) -> Create New -> ✅ repo, ✅ workflow, ✅ write:packages. For reference: [ghcr and github tokens](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
  
## Finally
After you have everything setup, run update to finish the install.
```sh
## Update Developer Edition configurations
make update
```

---

## Development Standards
- Understand a few simple [Architecture Principles](./DeveloperEdition/standards/ArchitecturePrinciples.md)
- Review the [Data Standards](./DeveloperEdition/standards/data_standards.md) and install prerequisites.
- Review the [SRE Standards](./DeveloperEdition/standards/sre_standards.md) and install prerequisites.
- Review the [API Standards](./DeveloperEdition/standards/api_standards.md) and install prerequisites.
- Review the [SPA Standards](./DeveloperEdition/standards/spa_standards.md) and install prerequisites.

## Developer Workflow
We utilize an Issue–Feature–Branch pattern for the developer workflow:
- Pick up an issue from the code base and assign yourself. If someone else is assigned to the issue you should check with them before starting any work. 
- Create a branch for the feature you are working on, reference the issue # in the branch name. 
- Commit and push your changes frequently while you are working. 
- When your work is feature complete, and **all unit/integration/blackbox testing** is passing with appropriate coverage, open a pull request (PR) from the feature branch back to main. 

These pull requests must be peer reviewed before being merged back into the main branch of the repository. This review process may require additional updates before it is approved. This "merge to main" event is what drives CI automation. If you are asked to review a PR, do your best to accommodate a prompt review.

If you have questions about implementing a feature, create your feature branch and open a draft PR with detailed questions and request a review of that PR, and then post a link to the PR in the General channel on Discord.