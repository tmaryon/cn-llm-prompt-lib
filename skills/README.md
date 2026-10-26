# Skills

Reusable agent skills in the open Agent Skills format: a folder with a
`SKILL.md` (YAML frontmatter with `name` and `description`, then instructions)
plus optional `references/`, `assets/`, and `scripts/`. The same folder works
in any agent that supports the format.

| Skill | Purpose |
|---|---|
| [`peakroi-frontend-standards`](peakroi-frontend-standards/SKILL.md) | Apply PeakROI frontend coding and security standards while coding, review diffs against them, and bootstrap new Next.js projects |

## peakroi-frontend-standards

Modes, chosen from the request:

- **Guide** (default): applies `AGENTS.md`, the house conventions, and, when a
  security trigger applies, the full security standard while implementing.
- **Review**: "review this diff against PeakROI standards". Produces a
  severity-ranked list of findings with `file:line`, rule ID, and fix.
- **Bootstrap**: "set up a new PeakROI frontend". Copies `AGENTS.md` and
  `SECURITY-STANDARD.md` into the repo and applies config templates (Prettier,
  ESLint, strict tsconfig, shadcn, husky + lint-staged, `.env.example`,
  security headers).

## Install

Copy (or symlink) the whole `peakroi-frontend-standards/` folder into your
agent's skills directory. Use the repository-level path to share it with
everyone working in a repo, or the user-level path for all your projects.

| Agent | Repository-level | User-level |
|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` |
| Codex CLI | `.agents/skills/` | `~/.agents/skills/` or `~/.codex/skills/` |
| Gemini CLI | `.gemini/skills/` (or `.agents/skills/`) | `~/.gemini/skills/` |

Example, user-level for every agent above:

```bash
for dir in ~/.claude/skills ~/.codex/skills ~/.gemini/skills; do
  mkdir -p "$dir" && cp -R skills/peakroi-frontend-standards "$dir/"
done
```

Skill directory locations change between agent releases; check your agent's
documentation if the skill is not discovered.

For agents without skill support, copy `references/AGENTS.md` and
`references/SECURITY-STANDARD.md` into the repository root instead (see
[`openai/README.md`](../openai/README.md)).

## Keeping the standards in sync

`openai/AGENTS.md` and `openai/SECURITY-STANDARD.md` are the canonical files.
The skill holds verbatim copies in `peakroi-frontend-standards/references/`.

1. Edit the canonical file in `openai/`.
2. Copy it into `skills/peakroi-frontend-standards/references/`.
3. Run the check, which exits non-zero on drift:

   ```bash
   bash skills/peakroi-frontend-standards/scripts/check-sync.sh
   ```
