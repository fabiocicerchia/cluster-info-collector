# Contributing

Thanks for taking the time to contribute to cluster-info-collector!

## Getting started

You need Docker (with buildx for multi-arch), `make`, and `shellcheck`.

1. Fork and clone the repo.
1. Install git hooks and dev tooling: `make setup`.
1. Create a branch: `git checkout -b feat/short-description`.

```sh
make build   # build the image locally
make lint    # hadolint + shellcheck
make test    # build + smoke test (./test.sh)
```

## Making changes

- Keep changes focused; one logical change per PR, matching existing style.
- Update `docs/` and `examples/` when behavior changes.
- Keep the README config table and the RBAC in `manifests/job.yaml` in sync
  with the script.
- Ensure CI (`code-quality` + `security` + `CI`) passes.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`,
`fix:`, `docs:`, `chore:`, etc. This drives the version bump: `fix:` → patch,
`feat:` → minor, `feat!:` or a `BREAKING CHANGE:` footer → major. Don't edit
`CHANGELOG.md` by hand — release-please generates it.

## Releases

Releases are automated by [release-please](.github/workflows/release.yml):

1. Merge `feat:`/`fix:` PRs into `main` as normal — **no tag is created**.
1. release-please keeps an open **release PR** ("chore: release X.Y.Z"),
   recalculating the version and `CHANGELOG.md` on every merge.
1. **Merge the release PR** to ship — that (and only that) creates the
   `vX.Y.Z` tag + GitHub Release, and then builds and pushes the multi-arch
   image to GHCR.

So `main` isn't released per-commit: changes accumulate into the release PR,
and merging it is the deliberate release step.

## Pull requests

Fill out the PR template, link related issues, and request review. By
participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md). Your
contributions are licensed under [Apache 2.0](LICENSE).
