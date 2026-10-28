---
name: peakroi-frontend-standards
description: Apply PeakROI's frontend coding and security standards (React, Next.js, TypeScript, Tailwind, shadcn/ui, OWASP Top 10:2025 and OWASP LLM 2026 controls). Use when writing, changing, or refactoring frontend code in a PeakROI repository; when asked to "review against PeakROI standards", "audit this diff", or "security review this frontend change"; or when asked to "bootstrap", "scaffold", or "set up a new PeakROI frontend project".
---

# PeakROI Frontend Standards

Guide frontend work so it follows PeakROI's coding, accessibility, and security
standards. The skill has three modes: **Guide** (default), **Review**, and
**Bootstrap**.

## Reference files

| File | Contents | When to read |
|---|---|---|
| `references/AGENTS.md` | Priorities, execution, code standards, React/Next.js, styling, accessibility, security triggers, verification, commit format | Always |
| `references/house-conventions.md` | Tooling, libraries, HTTP, state, env, and git flow used across PeakROI repos | Always |
| `references/SECURITY-STANDARD.md` | Full secure engineering standard (OWASP web + LLM controls) | When a Security trigger in `AGENTS.md` applies, and always in Review mode |
| `references/review.md` | Review procedure, severity rubric, output format, known anti-patterns | Review mode |
| `references/bootstrap.md` | New-project setup steps and template mapping | Bootstrap mode |

`references/AGENTS.md` and `references/SECURITY-STANDARD.md` are verbatim
copies of the canonical PeakROI files. When `AGENTS.md` refers to
"`SECURITY-STANDARD.md` in the repository root", use the target repository's
own copy if it has one; otherwise use `references/SECURITY-STANDARD.md`.
Maintainers keep the copies in sync with `scripts/check-sync.sh`.

## Precedence

1. The user's explicit instructions.
2. The target repository's own `AGENTS.md`, nested instruction files, and
   established conventions (formatter, folder layout, libraries).
3. This skill's references.

Lower levels never weaken security, privacy, accessibility, or data integrity
rules from a higher level, and no level may weaken the security standard.

### Legacy stacks

The target stack for new work is Next.js, strict TypeScript, Tailwind CSS,
shadcn/ui and Radix UI, react-hook-form with zod, and native `fetch`.

Some PeakROI repos predate it (for example Vite with plain JSX, MUI, Formik/Yup,
or axios). In those repos:

- Follow the repository's existing patterns, libraries, and quote style.
- Do not migrate frameworks, UI libraries, or form libraries unless asked.
- Still apply every security rule and the accessibility rules.
- Mention notable gaps against the target stack in the final report, briefly.

## Mode selection

- **Review**: the user asks to review, audit, or check code, a diff, a PR, or
  files against the standards.
- **Bootstrap**: the user asks to create, scaffold, or set up a new frontend
  project, or to add the standard config to a repo that lacks it.
- **Guide**: everything else involving frontend code. This is the default.
- **No task given**: the skill was invoked on its own, with no request to act
  on. See below.

## Invoked without a task

Do not stop at "standards loaded". Inspect the repository read-only, then reply
briefly with:

1. **Stack**: target or legacy stack, with the main framework, UI, and form
   libraries detected.
2. **Git state**: current branch and whether there are uncommitted or
   unpushed changes. Flag work happening directly on `master` or `staging`;
   the git flow in `references/house-conventions.md` expects a `feat/` or
   `fix/` branch.
3. **Options**: offer the three modes in one line each, recommending the most
   useful one first:
   - uncommitted or branch changes exist → **Review** those changes;
   - no `AGENTS.md`, `SECURITY-STANDARD.md`, or standard config in the repo →
     **Bootstrap** the missing pieces;
   - otherwise → **Guide**, asking what to build or fix.

Do not edit files, create branches, or run a review until the user chooses.

## Guide mode

1. Read `references/AGENTS.md` and `references/house-conventions.md`.
2. Inspect the target repo: lockfile, `package.json` scripts, formatter and
   lint config, existing instruction files, and the code near the change.
   Decide whether it is a target-stack or legacy-stack repo.
3. Check the change against the Security triggers in `AGENTS.md`. If any
   applies, read `references/SECURITY-STANDARD.md` in full before writing code
   and follow its Security Workflow.
4. Implement following the `AGENTS.md` Execution, Code Standards, React and
   Next.js, and Styling and Accessibility sections.
5. Verify as the `AGENTS.md` Verification section describes, using the
   repository's own scripts and package manager.
6. Report changes, verification actually run, assumptions, and residual
   security risks.

## Review mode

Read `references/AGENTS.md`, `references/house-conventions.md`,
`references/SECURITY-STANDARD.md`, and `references/review.md`, then follow the
procedure in `references/review.md`. Report findings only; do not edit code
unless the user asks.

## Bootstrap mode

Follow `references/bootstrap.md`. Templates live in `assets/templates/`.
Never overwrite an existing file without showing the user the difference
first.
