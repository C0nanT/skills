#!/usr/bin/env bash
# Interactively link (for local testing) or unlink a skill between this clone
# and the runtime skill locations (~/.agents/skills, ~/.claude/skills). See
# .agents/testing-skills-locally.md for the full explanation of the chain
# this script sets up and tears down.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_SKILLS="$HOME/.agents/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"

usage() {
    cat <<EOF
Usage: $(basename "$0") [skill-name] [--link|--unlink]

No arguments: list every skill in the repo, pick one, then pick link/unlink.
skill-name given: skip the skill picker.
--link / --unlink given: skip the action picker.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

skill_arg=""
action_arg=""
for arg in "$@"; do
    case "$arg" in
        --link) action_arg="link" ;;
        --unlink) action_arg="unlink" ;;
        *) skill_arg="$arg" ;;
    esac
done

# List every skill as "bucket/name" -> full repo path, sorted by name.
mapfile -t skill_paths < <(find "$REPO/skills" -maxdepth 2 -mindepth 2 -type d -not -path '*/node_modules/*' | sort)

names=()
paths=()
for p in "${skill_paths[@]}"; do
    [ -f "$p/SKILL.md" ] || continue
    names+=("$(basename "$p")")
    paths+=("$p")
done

status_of() {  # skill-name repo-path -> "linked-here" | "linked-elsewhere" | "absent"
    local name="$1" want_path="$2" link="$CLAUDE_SKILLS/$1" agents_link="$AGENTS_SKILLS/$1"
    if [ -L "$agents_link" ] && [ -L "$link" ]; then
        local target
        target="$(readlink -f "$agents_link" 2>/dev/null || true)"
        if [ "$target" = "$want_path" ]; then
            echo "linked-here"
            return
        fi
        echo "linked-elsewhere"
        return
    fi
    if [ -e "$agents_link" ] || [ -e "$link" ]; then
        echo "linked-elsewhere"
        return
    fi
    echo "absent"
}

pick_skill() {
    echo "Skills in this repo:" >&2
    local i=1
    for name in "${names[@]}"; do
        local st
        st="$(status_of "$name" "${paths[$((i - 1))]}")"
        local tag=""
        case "$st" in
            linked-here) tag=" [dev-linked]" ;;
            linked-elsewhere) tag=" [installed]" ;;
        esac
        printf '%3d) %s%s\n' "$i" "$name" "$tag" >&2
        i=$((i + 1))
    done
    local choice
    read -rp "Pick a skill (number): " choice >&2
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#names[@]}" ]; then
        echo "Invalid choice." >&2
        exit 1
    fi
    echo "${names[$((choice - 1))]}"
}

if [ -n "$skill_arg" ]; then
    idx=-1
    for j in "${!names[@]}"; do
        [ "${names[$j]}" = "$skill_arg" ] && idx=$j && break
    done
    if [ "$idx" -lt 0 ]; then
        echo "No skill named '$skill_arg' found under skills/*/." >&2
        exit 1
    fi
    skill="$skill_arg"
else
    skill="$(pick_skill)"
fi

idx=-1
for j in "${!names[@]}"; do
    [ "${names[$j]}" = "$skill" ] && idx=$j && break
done
skill_path="${paths[$idx]}"
current_status="$(status_of "$skill" "$skill_path")"

if [ -z "$action_arg" ]; then
    echo "Skill: $skill ($current_status)"
    case "$current_status" in
        linked-here)
            echo "Already dev-linked to this clone."
            read -rp "Unlink it? [y/N] " confirm
            [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
            action_arg="unlink"
            ;;
        linked-elsewhere)
            echo "A skill is already installed at ~/.claude/skills/$skill (not this clone)."
            read -rp "Replace it with a dev link to this clone? [y/N] " confirm
            [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
            action_arg="link"
            ;;
        absent)
            read -rp "Not installed. Dev-link it to this clone? [y/N] " confirm
            [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
            action_arg="link"
            ;;
    esac
fi

case "$action_arg" in
    link)
        rm -f "$CLAUDE_SKILLS/$skill" "$AGENTS_SKILLS/$skill"
        mkdir -p "$AGENTS_SKILLS" "$CLAUDE_SKILLS"
        ln -s "$skill_path" "$AGENTS_SKILLS/$skill"
        ln -s "../../.agents/skills/$skill" "$CLAUDE_SKILLS/$skill"
        echo "Linked: ~/.claude/skills/$skill -> ~/.agents/skills/$skill -> $skill_path"
        echo "Edits in the clone now take effect on the next /$skill run."
        ;;
    unlink)
        rm -f "$CLAUDE_SKILLS/$skill" "$AGENTS_SKILLS/$skill"
        echo "Unlinked: $skill removed from ~/.claude/skills and ~/.agents/skills."
        echo "Run 'npx skills@latest add C0nanT/skills --skill=$skill' to get the real install back."
        ;;
    *)
        echo "No action taken."
        ;;
esac
