---
name: setup-devcontainer
description: Set up a Compose-based devcontainer that inherits the host's git, CLI and agent identity, toolchain in the container, host stays clean, nothing to re-authenticate. User-invoked.
disable-model-invocation: true
---

# Setup Devcontainer

Give this repo a development container that satisfies two wishes that normally fight:

1. **Clean host**: no toolchain installed on the machine (compiler, runtime, generators, database clients, linters).
2. **Zero relogin**: git, the agent CLIs and any tracker CLI work *inside* the container under the identity that already exists on the host.

The naive route: a standalone devcontainer image with a `postCreateCommand` that installs everything: fails both: it re-authenticates on every recreate and can't reach the project's services.

**The structuring decision: the devcontainer is a service of the project's Compose stack**, not a standalone image. It is called `workspace`, sits behind a profile so a normal `docker compose up` doesn't start it, and `.devcontainer/devcontainer.json` points at the Compose files and names it. Being in the Compose network is what lets it reach `postgres:5432` and `gateway:8080` by name, from inside a standalone devcontainer, `localhost` is not the `localhost` where Compose published the ports, and that discovery costs an afternoon.

Read [REFERENCE.md](./REFERENCE.md) before drafting anything. It holds the two mount mechanics, the failure table that forces them, the full mount map, and the anti-patterns. This file is the process; that file is the reasoning you need to adapt it.

Run this **before** the rest of the project. Retrofitted later, the toolchain has already been installed on the host "just this once".

## Process

### 1. Explore

Read the repo and the host before asking anything. Every question you can answer by looking is a question you don't ask.

**In the repo:**

- Is there already a Compose file (`compose.yaml`, `docker-compose.yml`) and an override? → add the `workspace` service to the override. If not → create the pair.
- Is there a `Dockerfile`? Does it have stages you can add a `workspace` stage beside, reusing the same base image?
- **Greenfield: no application service exists yet.** Expected, since this runs first. The stack you create is infrastructure-only: `workspace` plus what it talks to (database, cache, tracing). Application services get added as they gain an entrypoint; don't invent placeholders for them. Same in the Dockerfile, write a `base` stage that `workspace` builds on, so the app's stages have something to inherit later.
- Language and toolchain: `go.mod`, `composer.json`, `package.json`, `pyproject.toml`, `Cargo.toml`, `*.csproj`, `Gemfile`. Read them for the *version* too, not just the language.
- Working-directory convention: an existing `WORKDIR` in the Dockerfile, or the framework's own (`/var/www/html`, `/app`, `/workspace`).
- Extra tooling the project actually invokes: code generators (`protoc`, `sqlc`, `buf`), migration tools, database clients, linters. Look in the Makefile / task runner / scripts, not at what the language "usually" needs.
- Is there a Makefile or task runner? → the lifecycle targets go **into it**; a second entry point is worse than none. If not, you'll create one (REFERENCE.md §11): the profile that hides `workspace` is unusable without a named command.
- **Database clients: match the major to the running service, not to what the distro ships.** The distro package lags, bookworm's `postgresql-client` is 15, and `pg_dump` refuses a 17 server outright. Read the version off the Compose service, then add the vendor repository (PGDG and its equivalents) when the distro can't reach it.
- Existing `.devcontainer/`: if one exists, this is a migration, not a greenfield setup. Say so and show the diff before replacing it.
- How the project's tests reach infrastructure. If they already run inside the Compose network, do **not** pull in testcontainers.

**On the host:**

| What | How |
| --- | --- |
| UID / GID | `id -u`, `id -g`: if not 1000, the defaults must be passed |
| Docker socket group | `getent group docker`: the GID varies per machine, so parameterise it |
| Which host configs exist | Test each path in REFERENCE.md's mount map; a missing path means the mount is skipped, not defaulted |
| Where a CLI keeps its token | Plain config file → mount it. System keyring → it can't cross into the container; carries by environment variable only |
| …without reading the secret | `test -f`, `ls -l`, `grep -l oauth_token`: you need the *location and shape*, never the value. `cat` on a credential file can be denied by the permission layer, and a denial there must not stall the setup: fall back to the file's existence and size, or ask |

Done when you can name the base image, the working directory, every host path that exists, and every service the workspace must depend on.

### 2. Ask only what branches

Present what you found first, then ask. Lead with the recommended answer so the user can accept it in one word. Everything exploration settled is stated, not asked.

**A: Docker socket access.** The only question with a security trade-off, so ask it explicitly, never assume.

> Should the workspace be able to run `docker compose` from inside? (recommended: **no** unless you know you need it)

> Mounting `/var/run/docker.sock` makes containers started from inside **siblings**, not children, and it is equivalent to root on the host: fine on a personal machine, not fine on a shared runner. Without it the workspace still reaches every service over the network; it just can't control them.

**B: Remote tracker CLI.** Ask; never install by reflex.

> Does the workflow leave the repository: issues or MRs on GitHub / GitLab? (recommended: **no** when issues are local markdown)

> A project tracking work in markdown files has nothing to authenticate: `gh` / `glab` stay out of the image and out of the mounts. If yes, find out where that CLI keeps its token before promising it will work, a keyring-backed token needs an environment variable, and the silent failure mode is that the CLI shows the right username while every API call fails.

**C: Extra tools in the image.** Confirm the list exploration produced, and ask what it missed. This is a checklist to accept, not an open question.

**D: Agent CLIs to carry in.** Confirm which of the ones found on the host should be wired in (Claude Code, `cursor-agent`, others). Each one only costs its mounts; a CLI the user doesn't use is noise in the config. Ask it, a list assumed here and merely *announced* in the draft is the easiest question in this skill to skip, and its mounts and installer are the parts hardest to unpick later.

Anything exploration left genuinely ambiguous (two plausible base images, an unclear working directory) is asked here too, with your recommendation first.

### 3. Draft and confirm

Show the full set of files before writing any of them:

- The `workspace` service to add to the Compose override (or the new override).
- The `workspace` image stage.
- `.devcontainer/devcontainer.json`.
- The entrypoint script.
- The Makefile lifecycle targets (`dev`, `up`, `down`, `shell`, `ps`, `logs`, `clean`): added to the existing Makefile, or a new one.

**Verify every pinned image tag before it goes into the draft**: `docker manifest inspect <image>:<tag>` or the registry's tag list. A plausible-looking tag is not a tag: `jaegertracing/all-in-one:1.62` doesn't exist, only `1.62.0` does, and unverified it fails at `up`, after the whole stack is written and the failure looks like a Compose problem.

Let the user edit the draft. Name explicitly, in one line each: which host paths you're mounting, whether the socket is in, and which services `depends_on` will drag up.

### 4. Write

Follow this order: each step depends on the one before it:

1. `workspace` service in the override + image stage with a real uid-1000 user and the toolchain: `PATH` written both as `ENV` and as a `/etc/profile.d` drop-in.
2. `.devcontainer/devcontainer.json` pointing at the Compose files.
3. Named home volume + `CLAUDE_CONFIG_DIR` (and any equivalent for other agent CLIs).
4. Direct read-only mounts.
5. Entrypoint + writable seeds.
6. Docker socket, only if step 2A said yes.
7. Makefile lifecycle targets: every start with `--wait`, the dev target with `--build`, every teardown naming the profile, and the `/.dockerenv` host guard on the Docker-facing ones unless 2A said yes. Lifecycle only: no `test` / `lint` / `proto` target while there's no code for it to run.

Every construct here: why the home volume must be named, why `useradd` runs in the image, why some files are seeded instead of mounted: is in REFERENCE.md. Do not improvise a variant of one without reading its rationale; each is there because the obvious alternative fails in a way whose error message doesn't name the cause.

### 5. Verify

Build, start, and run the acceptance script from *inside* the container. Report the actual output: a step you couldn't run is reported as not run.

Every step has to be runnable non-interactively: a check that needs a TUI is a check that never runs.

```sh
id                              # host uid/gid
git config user.email           # host email
git ls-remote                   # credentials work (read)
ls ~/.claude/skills             # skills visible
cp F F.tmp && mv F.tmp F        # for each seeded file F: the atomic rename itself
findmnt -T F                    # …and F is not a mount point → no EBUSY
bash -lc 'go version'           # login shell, not exec: catches the /etc/profile PATH reset
touch <file> in the repo        # on the host, owner is your user
curl <service>:<port>           # Compose network reachable
docker compose ps               # only if the socket was mounted
```

Two of them need a fallback:

- **`git ls-remote` presupposes a remote.** A greenfield repo has none. Then prove the helper instead: `git credential fill` fed the host and protocol, piped straight into `grep '^username='`. Never print its raw output, it contains the password line.
- **The rename test replaces "open the CLI and run `/model`".** It exercises the same mechanic (the atomic rename that `EBUSY`s over a single-file bind mount) without a human at a TUI.

Then the real test: the one that proves the persistence layer, and the one most likely to be skipped:

```bash
docker compose ps -q workspace                                   # note the container ID
docker compose --profile dev-tools down                          # the profile is not optional
docker compose --profile dev-tools up -d workspace --wait
docker compose ps -q workspace                                   # must be a *different* ID
```

**Without `--profile`, `down` leaves the profiled container running**: the following `up` recreates nothing and the test proves nothing while appearing to pass. The changed container ID is the evidence that it really died; if the ID is the same, you tested nothing. Run it through the Makefile targets instead once they exist, that's what the targets are for.

Agent login and sessions must still be there afterwards. If they aren't, the home volume isn't named, isn't mounted at the container's `$HOME`, or the CLI is configured to write outside it.

### 6. Done

Tell the user:

- Which files you created or changed, and which host paths are now mounted into the container.
- The two commands that are now the entry point: `make dev` for the working environment, `make up` for the system alone, and that `make shell` is how you get in.
- Whether the Docker socket is mounted, and if it is, restate the trade-off once so the decision is on record.
- Which acceptance checks passed, and any that failed or you couldn't run.
- That the toolchain now belongs to the container: new tools go into the image stage, not onto the host.
