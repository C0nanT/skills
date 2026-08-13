# Reference — the devcontainer that inherits the host's identity

The pattern behind `setup-devcontainer`: what is a decision, what is a consequence, and where it varies by stack. Everything here exists because the obvious alternative fails in a way whose error message doesn't name the cause.

## 1. The devcontainer is a Compose service

A service named `workspace` in the development override file, behind a profile (`dev-tools`) so a normal `docker compose up` doesn't start it. `.devcontainer/devcontainer.json` points at the Compose files and names that service.

**Why:** inside the Compose network, the workspace reaches every other service by name (`gateway:8080`, `postgres:5432`). It removes the entire class of addressing problems — from inside a standalone devcontainer, `localhost` is not the `localhost` where Compose published its ports.

```jsonc
{
  "name": "<project> (workspace)",
  "dockerComposeFile": ["../compose.yaml", "../compose.override.yaml"],
  "service": "workspace",
  // Naming a profiled service explicitly on `up` enables it without --profile;
  // its depends_on brings the infrastructure up with it.
  "runServices": ["workspace", "<deps>"],
  "workspaceFolder": "/workspace",
  "remoteUser": "dev",
  "shutdownAction": "none"
}
```

`shutdownAction: none` — closing the editor doesn't tear the stack down.

## 2. The two mount mechanics

The whole identity-inheritance story reduces to picking between two:

- **A — direct read-only bind mount.** For anything the process only *reads*.
- **B — seed → copy at boot.** For anything the process *rewrites*. The host file is mounted read-only at a staging path; the entrypoint copies it once into the real path, inside a writable volume.

The two failures that force mechanic B — neither message points at the cause:

| Symptom | Real cause |
|---|---|
| `EBUSY` when saving config | The write is an **atomic rename** over a single-file bind mount. The mount is itself a mount point, so the rename can't replace it. (Claude Code does this on `/model`, `/effort`.) |
| `unable to get credential storage lock` | `git credential approve` (on push) creates a `.lock` **in the file's directory**. A read-only directory forbids it. |

**Derived rule: if the process that owns the file can rewrite it, seed and copy. If it only reads, mount it directly.**

## 3. Mount map

| What | Host | Mechanic | Destination in container |
|---|---|---|---|
| Git identity | `~/.gitconfig` | ro | `$HOME/.gitconfig` |
| Git credentials | `~/.config/git/credentials` | seed → copy, `chmod 600` | `$HOME/.config/git/credentials` |
| `cursor-agent` auth | `~/.cursor/cli-config.json` | seed → copy | `$HOME/.cursor/cli-config.json` |
| Skills | `~/.claude/skills` | ro | `$HOME/.claude/skills` |
| Agents | `~/.agents` | ro | `$HOME/.agents` |
| Hooks | `~/.claude/hooks-lib` | ro | `$HOME/.claude/hooks-lib` |
| Statusline | `~/.claude/statusline-command.sh`, `~/.claude/statusline-reset-hook.sh` — **each file, enumerated** | ro | same path |
| Claude settings | `~/.claude/settings.json` | seed → copy | `$HOME/.claude/settings.json` |
| Claude login | `~/.claude/.credentials.json` | seed → copy, `chmod 600` | `$HOME/.claude/.credentials.json` |

A host path that doesn't exist means the mount is **skipped**, not defaulted. Test each one during exploration.

### Details that aren't obvious

- **Compose does not expand globs in a volume path.** No shell runs over it: `~/.claude/statusline-*.sh` is taken literally, doesn't exist on the host, and Docker helpfully creates a *directory* by that name. Enumerate every file — and since mounting all of `~/.claude` is an anti-pattern, enumerating is the only way in.
- **`credential.helper = store --file=$HOME/.config/git/credentials`** in the host gitconfig works unchanged inside the container, because `$HOME` expands at runtime and resolves to the container's home. That's what makes mechanic B land on the right destination.
- **A remote tracker CLI (`gh`, `glab`) is optional and must be a question.** A project with issues in local markdown has no tracker to authenticate: keep it out of the image and out of the mounts. Install it only when the workflow really leaves the repository.
- **Cursor is two distinct products.** The **editor** runs on the host and enters the container through the devcontainer extension — there is nothing to authenticate inside. Only the **`cursor-agent` CLI** needs auth, and it lives in `~/.cursor/cli-config.json` (key `authInfo`), a file the CLI itself rewrites (model, permissions) → mechanic B. Do **not** mount all of `~/.cursor`: `projects/`, `chats/` and `extensions/` are state indexed by host path.
- **General rule for CLIs: where the token lives determines the mechanic.** Plain-text config file → read-only mount. **System keyring → environment variable**, because a keyring doesn't cross into a container. This is the silent trap: the config mounts, the CLI reports the right user, and every API call still fails. Rewritten-by-the-CLI file → seed → copy.
- **The Claude credential diverges from the host** after the first token refresh. They become two valid, independent copies of the same session. If the inner one expires, recreating the home volume seeds it again.
- **Never mount all of `~/.claude`.** It holds per-project-path state, sessions, history and caches — the container would write over the host's state, with paths that only exist on one side.

## 4. Persistent home

A **named** volume mounted at the container's `$HOME` — not a bind mount.

- Login, sessions and history survive `docker compose down`.
- `CLAUDE_CONFIG_DIR` **must** point inside that volume; otherwise Claude writes to the image's home (outside the volume) and loses the login on every recreate. The same reasoning applies to any other agent CLI with a configurable state directory.
- The image creates the user and `chown`s the home **before** the volume is mounted: a named volume inherits owner and permissions from the directory at first initialisation.
- **The toolchain's caches belong inside it too.** Their defaults already do (`$HOME/go`, `$HOME/.cache/go-build`, `~/.npm`, `~/.cache/pip`) — but the official images *relocate* them out of `$HOME`: `golang` sets `GOPATH=/go`, `rust` sets `CARGO_HOME=/usr/local/cargo`. Left there they live in the container layer, and every recreate re-downloads the whole dependency set. Check what the base image sets and point it back inside the home volume (or give that path its own named volume).

## 5. User identity and permissions

- The container runs as `${DOCKER_UID:-1000}:${DOCKER_GID:-1000}` — the host's UID/GID — so anything written into the bind-mounted checkout stays host-owned.
- The image creates a real user with uid/gid 1000 (`useradd -u 1000 -g 1000 -m -d /home/dev`). Without it `HOME` falls back to `/` (not writable) and git and the shell don't resolve.
- `git config --system --add safe.directory <workspace>` — the host UID is rarely the one that built the image.
- **Check first:** if `id -u` on the host isn't 1000, the defaults have to be passed. Nothing needs fixing in the checkout when its owner is already the host user.

## 6. Docker socket access (optional, decide explicitly)

Needed only if the developer or agent will run `docker compose` from **inside**.

- Mount `/var/run/docker.sock`; containers come up as **siblings**, not children.
- The socket is `root:docker`, so the service needs the `docker` group's GID as a supplementary group (`group_add`) — and that number **varies per machine**, so parameterise it.
- **Trade-off to state out loud:** socket access is equivalent to root on the host. Fine on a personal machine, not fine on a shared runner.
- Without the socket the workspace still reaches every service over the network — it just can't control them.

## 7. `PATH` has to survive a login shell

`ENV PATH=...` in the Dockerfile only covers **non-login** shells. The editor's terminal opens `bash -l`, which sources `/etc/profile` — and on Debian bookworm, the base of the official `golang`, `node` and `rust` images, that file **assigns** `PATH` instead of prefixing it:

```sh
# /etc/profile — debian bookworm
if [ "`id -u`" -eq 0 ]; then PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
else PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"; fi
export PATH
```

Everything outside those directories is gone: `/usr/local/go/bin`, `$GOPATH/bin`, and `$HOME/.local/bin` — which is where §8 puts the self-updating CLI.

| Symptom | Real cause |
|---|---|
| `go: command not found` in the editor's terminal, while the same binary runs fine under `docker compose exec` | The editor's shell is a login shell. `/etc/profile` overwrote the `PATH` that `ENV` set. |

Ship it both ways — `ENV` for `exec` and the entrypoint, a `profile.d` drop-in for the login shell (`/etc/profile` sources `profile.d/*.sh` *after* the assignment above, so the drop-in wins):

```dockerfile
ENV PATH=/home/dev/.local/bin:/usr/local/go/bin:$PATH
RUN printf 'export PATH=/home/dev/.local/bin:/usr/local/go/bin:$PATH\n' \
      > /etc/profile.d/10-workspace-path.sh
```

## 8. Self-updating CLIs installed in the image

Applies to Claude Code and any CLI the user expects to update itself:

- `npm install -g` fails this twice. It creates **root-owned** files, so uid 1000 can't update them (`claude update` → `no_permissions`) and the CLI goes stale **silently** — and it presupposes Node, which a Go / Rust / PHP base image doesn't have. Adding a whole runtime to host one CLI is the wrong trade.
- Fix: the entrypoint provisions the **native** build into the persistent home once — `curl -fsSL https://claude.ai/install.sh | bash`, the recommended install path, which works on any base image and lands in `$HOME/.local/bin`. Files are uid-1000-owned inside the volume, so self-update keeps working.
- `claude install latest` is the *upgrade* command of an existing native install, not a way to bootstrap one. Don't reach for it as the first step.
- Idempotent (no-op if the binary is already in the volume) and best-effort: offline on the first boot must not fail the boot.
- The install is worth nothing if `$HOME/.local/bin` isn't on the login shell's `PATH` — see §7.

## 9. Entrypoint responsibilities

Only this, then `exec "$@"`:

1. Copy each seed to its writable destination, **if not already there** (idempotent).
2. Fix the mode of sensitive files (`600`).
3. Provision the CLI's native build, if absent.

```bash
seed() {  # seed_path dest_path [mode]
    [ -f "$1" ] && [ ! -s "$2" ] || return 0
    mkdir -p "$(dirname "$2")"
    cp "$1" "$2" 2>/dev/null || true
    [ -n "$3" ] && chmod "$3" "$2" 2>/dev/null || true
}
```

The service command is `sleep infinity` — the container exists to be inhabited, not to run a process.

## 10. Worked example — the service

Adapt paths, base image and dependencies; the shape is the point.

```yaml
  workspace:
    profiles: ['dev-tools']
    build:
      context: .
      target: workspace
    env_file:
      # Always the guarded form. This skill runs *before* the rest of the
      # project, so .env frequently doesn't exist yet — and the bare `- .env`
      # form fails the up with a file-not-found the user has no way to read as
      # "you haven't written this file yet".
      - path: .env
        required: false
      # Same guard, other reason: a token for a CLI whose auth lives in the host
      # keyring and so cannot be mounted.
      - path: ${HOME}/.config/<cli>/token.env
        required: false
    # Match the host user so anything written into the bind-mounted checkout
    # stays host-owned. Override with DOCKER_UID / DOCKER_GID if id -u isn't 1000.
    user: '${DOCKER_UID:-1000}:${DOCKER_GID:-1000}'
    environment:
      HOME: /home/dev
      # Without this, Claude writes its config to the image's home (outside the
      # volume) and loses the login on every recreate.
      CLAUDE_CONFIG_DIR: /home/dev/.claude
    entrypoint: ['bash', '/workspace/docker/entrypoint.workspace.sh']
    command: ['sleep', 'infinity']
    volumes:
      - .:/workspace
      # Persistent writable home: login and sessions survive recreation.
      - workspace_home:/home/dev
      # --- git ---
      - ~/.gitconfig:/home/dev/.gitconfig:ro
      # Staged read-only; the entrypoint copies it to the path the helper
      # expects, so `git credential approve` on push can take its lock.
      - ${HOME}/.config/git/credentials:/home/dev/.git-credentials-seed:ro
      # --- agent config, read-only from the host ---
      - ~/.claude/skills:/home/dev/.claude/skills:ro
      - ~/.agents:/home/dev/.agents:ro
      # Staged, then copied by the entrypoint — a single-file bind mount is a
      # mount point, so the atomic-rename save would EBUSY on it.
      - ~/.claude/settings.json:/home/dev/.claude-seed/settings.json:ro
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  workspace_home:
```

## 11. Anti-patterns

What this skill exists to prevent:

- Standalone devcontainer image + mounted socket → brings the network problem back.
- Mounting `settings.json` read-only at its final path → `EBUSY` on the first `/model`.
- Mounting the git credentials directory read-only → push breaks on the lock.
- Mounting all of `~/.claude` → state collision with the host.
- Running as root → root-owned files in the checkout, `sudo` to edit them afterwards.
- Baking a secret into the image → everything comes in by mount at runtime.
- Home on a bind mount inside the checkout → container state polluting the repo.
- `PATH` set only via `ENV` → works under `exec`, broken in the editor's terminal.
- The toolchain's cache left where the base image put it (`/go`, `/usr/local/cargo`) → every recreate re-downloads everything.
- Pulling in testcontainers when the tests already run inside the Compose network.
