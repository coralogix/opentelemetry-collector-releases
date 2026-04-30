# OpAMP Supervisor Release

This document describes the release flow for the `opampsupervisor` binary in
this repository.

## Bringing updates from upstream

See [UPSTREAM_UPDATE.md](UPSTREAM_UPDATE.md) for instructions on how to bring updates
from the upstream.

## Tag Model

OpAMP releases use two different tags:

- Public trigger tag: `cx-opampsupervisor/vX.Y.Z`
- Internal GoReleaser tag: `cmd/opampsupervisor/X.Y.Z`

The public tag is the one you create and push manually. The internal tag is
created by GitHub Actions so GoReleaser can run with the monorepo tag layout
defined in `cmd/opampsupervisor/.goreleaser.yaml`.

Example:

- You push `cx-opampsupervisor/v0.147.0`
- The workflow creates `cmd/opampsupervisor/0.147.0`

## How To Release

1. Make sure the desired OpAMP changes are merged in this repository.
2. Make sure the matching version exists in
   `coralogix/opentelemetry-collector-contrib`, because the release workflow
   checks out that repository during the build.
3. Update your local `main` branch.
4. Create and push the public release tag:

```bash
git checkout main
git pull --ff-only origin main
git tag -a cx-opampsupervisor/v0.147.0 -m "Release OpAMP supervisor v0.147.0"
git push origin cx-opampsupervisor/v0.147.0
```

5. Watch the `Release OpAMP supervisor` GitHub Actions workflow.
6. Confirm the run succeeds.
7. Verify the expected release outputs were published.

## What The Workflow Does

The entrypoint is `.github/workflows/release-opampsupervisor.yaml`.

At a high level, the workflow:

1. Triggers when a tag matching `cx-opampsupervisor/v*` is pushed.
2. Calls the reusable workflow in `.github/workflows/base-binary-release.yaml`
   with `binary=opampsupervisor`.
3. Normalizes the pushed tag into a clean version string by:
   - taking the last path segment
   - removing a leading `v`
4. Creates and pushes the internal tag `cmd/opampsupervisor/<version>`.
5. Checks out `coralogix/opentelemetry-collector-contrib` into `.contrib`.
6. Copies the OpAMP Dockerfile and Windows MSI assets into that checkout.
7. Installs the release tooling needed by GoReleaser.
8. Runs GoReleaser with `cmd/opampsupervisor/.goreleaser.yaml`.

## Expected Outputs

The GoReleaser configuration builds and publishes:

- Linux binaries
- macOS binaries
- Windows binaries
- Linux `.deb` and `.rpm` packages
- Windows MSI installers
- checksums, signatures, and SBOMs
- multi-arch container images and a manifest list for `cx-opampsupervisor`

## Important Detail

The public tag is only the trigger. GoReleaser does not release directly from
`cx-opampsupervisor/vX.Y.Z`. The workflow translates that tag into the internal
`cmd/opampsupervisor/X.Y.Z` tag before invoking GoReleaser.
