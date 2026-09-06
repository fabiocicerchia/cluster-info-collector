# cluster-info-collector

[![CI](https://github.com/fabiocicerchia/cluster-info-collector/actions/workflows/ci.yml/badge.svg)](https://github.com/fabiocicerchia/cluster-info-collector/actions/workflows/ci.yml)
[![Security](https://github.com/fabiocicerchia/cluster-info-collector/actions/workflows/security.yml/badge.svg)](https://github.com/fabiocicerchia/cluster-info-collector/actions/workflows/security.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/fabiocicerchia/cluster-info-collector/badge)](https://securityscorecards.dev/viewer/?uri=github.com/fabiocicerchia/cluster-info-collector)
[![CI carbon](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/fabiocicerchia/cluster-info-collector/gh-pages/badge.json)](.github/workflows/carbon-badge.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/fabiocicerchia/cluster-info-collector)](https://github.com/fabiocicerchia/cluster-info-collector/releases)

A **support-bundle collector** for incident snapshots: nodes, events,
resource dumps, `describe`s, per-container logs (current + previous crash),
`kubectl top`, all tarred with a UTC timestamp — optionally shipped straight
to S3. Secret **names** are listed; secret **data is never collected**.

When production is on fire, nobody remembers the fifteen kubectl commands.
This is the one command.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/fabiocicerchia/cluster-info-collector/main/install.sh | bash
```

Or pull the image directly: `docker pull ghcr.io/fabiocicerchia/cluster-info-collector:latest`.

## Usage

During an incident (RBAC included in the manifest):

```sh
kubectl apply -f manifests/job.yaml
kubectl logs -f job/cluster-info-collector
```

Scoped + shipped to S3 from your laptop — `docker-collect.sh` wraps
`docker run` against your current kubectl context, working out the fiddly
bits (kubeconfig permissions, `--network` for local clusters like minikube/
kind/k3d, getting the bundle back out) for you:

```sh
./docker-collect.sh --s3 s3://incidents/2026-07-10-api-outage/ payments checkout
```

Bundle lands in `./out` by default; add `--output DIR` to change that, or
`--dry-run` to print the `docker run` command without executing it. See
`./docker-collect.sh --help` for all options.

Equivalent by hand, for the manual/no-wrapper form:

```sh
docker run --rm -v ~/.kube:/home/collector/.kube:ro \
  -e BUNDLE_S3_URI=s3://incidents/2026-07-10-api-outage/ \
  fabiocicerchia/cluster-info-collector payments checkout
```

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `NAMESPACES` / args | all | namespaces to collect |
| `LOG_TAIL_LINES` | `2000` | log lines per container |
| `INCLUDE_PREVIOUS` | `true` | crashed-container logs |
| `REDACT_ENV` | `true` | redact secret-like env var values in describe/resource dumps |
| `SINCE` | – | only fetch logs newer than this (`kubectl logs --since`, e.g. `1h`, `30m`) |
| `MAX_BUNDLE_MB` | `0` (unlimited) | truncate the biggest `*.log` files first until the bundle fits |
| `OUTPUT_DIR` | `/tmp` | bundle destination |
| `BUNDLE_S3_URI` | – | upload target |

## Development

Full docs live in [`docs/`](docs/); runnable examples in
[`examples/`](examples/).

### Make targets

`make help` lists them. Every repository in this estate exposes the same eight
verbs, so you do not have to read a Makefile to find out how to build or test it
(FC-GEN-057).

| Verb      | What it does here                                       |
| --------- | ------------------------------------------------------- |
| `setup`   | Install the pre-commit hook                             |
| `install` | `docker pull` the published image                       |
| `build`   | Build the image locally                                 |
| `test`    | Build, then run the smoke tests                         |
| `lint`    | `pre-commit run --all-files` — the whole gate           |
| `run`     | Run the collector from the image; `ARGS` are its arguments |
| `format`  | Rewrite what the gate can fix: whitespace, endings, EOF |
| `analyze` | `trivy fs` — the same scan CI runs                      |

`make push` and `make release` publish the image; the release workflow is what
normally runs them.

`make test-unit` runs the `lib.sh` unit tests alone — no docker, no cluster.


## Documentation

Full docs live in [`docs/`](docs/). Runnable examples live in [`examples/`](examples/).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). By participating you agree to the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Security

Found a vulnerability? See [SECURITY.md](SECURITY.md) — please don't open a
public issue.

## Support

Need help implementing this? [Get in touch](https://fabiocicerchia.it/contact).

## License

[Apache 2.0](LICENSE) © 2026 Fabio Cicerchia.
