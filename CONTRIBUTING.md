# Contributing

## Updating the documentation

If you make changes to documented parameters, you can generate and include the
documentation with your commit via

```bash
pdk release prep --skip-changelog --skip-dependency --version="$(jq --raw-output .version metadata.json)" --force
```

The above command provides a version that matches the current version so that
release prep does not modify the `metadata.json` version, but this does mean
that you need to have `jq` available. If you do not, run the following command
and opt-out of setting the module version during the command line interview.

```bash
pdk release prep --skip-changelog --skip-dependency
```

Due to a bug in the `pdk release` command, we cannot provide
`--skip-validation` or opt-out of validation because the Gem dependencies would
not be found, so if the module fails validation, the above command will also
fail.

## Releases

To release a new version of the module, run the Auto release Github
Action. It will generate new documentation, update the changelogs, and bump the
version based on the labels on the PRs included in the release. It will open a
PR, which should be reviewed and merged.

Once the release prep has been merged to the main branch, run the Publish
module action to tag the release and release it to the Forge.

