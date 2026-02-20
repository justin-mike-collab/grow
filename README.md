# Umbrella Project Template

## Quick Start
This is a template to create the Umbrella Repo for your system. To use this template, first create a ~/temp/Specifications/product.yaml file, fill in the data below:
```yaml
info:
  name: A Short Name for your Product
  description: A paragraph length description of the idea.
  slug: A version of the short name without any spaces

organization:
  name: The organization make
  founded: now()
  slug: Organization name without spaces
  git_host: https://github.com 
  git_org: typically the same as the slug
  docker_host: ghcr.io
  docker_org: typically the same as the slug

```

Then, create a new repo using this template and clone it down, and use the ``make merge`` command as shown below. 
```sh
## Merge your specifications with the template
make merge ~/temp/Specifications
```

## Contributing
See [Template Guide](https://github.com/agile-learning-institute/stage0_runbook_merge/blob/main/TEMPLATE_GUIDE.md) for information about stage0 merge templates. See the [Processing Instructions](./.stage0_template/process.yaml) for details about this template, and [Test Specifications](./.stage0_template/Specifications/) for sample context data required.

Template Commands
```sh
## Test the Template using test_expected output
## Creates ~/tmp folders 
make test
## Successful output looks like
...
Checking output...
Only in /Users/you/tmp/testRepo: .git
Only in /Users/you/tmp/testRepo/configurator: .DS_Store
Done.

## Clean up temp files from testing
## Removes tmp folders
make clean

## Process this merge template using the provided context path
## NOTE: Destructive action, will remove .stage0_template 
## Context path typically ends with ``.Specifications``
make merge {context path}
```
