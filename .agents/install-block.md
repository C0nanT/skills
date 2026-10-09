# The canonical install block

One install story, one wording. `README.md` and every page under `docs/` must say **this** and nothing else. Change it here first, then propagate. `README.md` carries it in Portuguese; the commands stay verbatim.

## skills.sh first

The documented route is skills.sh: it copies the skills into `~/.agents/skills/<skill>/` and symlinks each into every agent's skills directory (`~/.claude/skills/<skill>` on Claude Code). The files are yours to edit. Hooks and configs that point at a skill asset at runtime reference that install location, never this clone (see `CLAUDE.md`).

<canonical-block name="skills-sh">

```bash
npx skills@latest add C0nanT/skills
```

When the installer asks which skills to take, include `setup-skills`. To update, run `npx skills@latest update`, and re-run `add` to pick up new skills.

</canonical-block>

Use the single-skill form wherever one skill is named on its own, including the unpromoted ones in `misc/` and `in-progress/`. `docs/` pages don't use this block. See [writing-docs.md](./writing-docs.md).

<canonical-block name="skills-sh-one-skill">

```bash
npx skills@latest add C0nanT/skills --skill=<name>
```

```bash
npx skills@latest update <name>
```

</canonical-block>

<canonical-block name="skills-sh-remove">

```bash
npx skills@latest remove              # interactive menu
npx skills@latest remove <name>       # one skill
npx skills@latest remove --all -g     # all of them (global scope)
```

Without `-g` the command acts on the current project; with `-g`, on `~/.agents/skills/` and each agent's symlinks.

</canonical-block>

`skills@latest` is the pinned spelling everywhere.

## Claude Code plugin (fallback)

`.claude-plugin/marketplace.json` makes this repo its own single-plugin marketplace, shipping exactly the promoted set listed in `.claude-plugin/plugin.json`. It is a fallback for people who want a read-only bundle, not the documented route.

<canonical-block name="claude-code-plugin">

```text
/plugin marketplace add C0nanT/skills
/plugin install conan-skills@conan-skills
```

Update with `claude plugin update conan-skills`, then `/reload-plugins`.

</canonical-block>

## The two routes are exclusive

The plugin is a read-only bundle you subscribe to. skills.sh writes files you own and edit. Installing both leaves the user with every skill twice: always say "pick one".

## Hooks

Hooks are not part of this repo. They ship as the `conan-mods` plugin from [C0nanT/claude-hooks](https://github.com/C0nanT/claude-hooks), installed separately on either route.

<canonical-block name="hooks">

```text
/plugin install conan-mods --marketplace C0nanT/claude-hooks
```

Update with `claude plugin update conan-mods`, then `/reload-plugins`. Remove with `/plugin uninstall conan-mods`.

</canonical-block>
