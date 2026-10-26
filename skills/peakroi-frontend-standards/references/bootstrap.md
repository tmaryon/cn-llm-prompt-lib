# Bootstrap Procedure

Set up a new PeakROI frontend, or add the standard configuration to an
existing Next.js repository that lacks it. Templates are in
`assets/templates/` relative to the skill root.

## 1. Confirm inputs

- Target directory and project name.
- New project or existing repository. For an existing repository, inventory
  current configs first and treat every template as a proposed change.
- Router: App Router for new projects unless the user asks for Pages Router.

## 2. Create the app (new projects only)

```bash
yarn create next-app <name> --ts --tailwind --eslint --app --src-dir \
  --import-alias '@/*' --use-yarn --yes
```

Use yarn v1 and keep only `yarn.lock`. Delete any other lockfile the generator
produced.

## 3. Copy the standards documents

Copy these to the repository root:

| Source | Destination |
|---|---|
| `references/AGENTS.md` | `AGENTS.md` |
| `references/SECURITY-STANDARD.md` | `SECURITY-STANDARD.md` |

Recent `create-next-app` versions generate an `AGENTS.md` containing a block
between `<!-- BEGIN:nextjs-agent-rules -->` and
`<!-- END:nextjs-agent-rules -->`, and `next dev` re-adds it if removed. Write
the PeakROI `AGENTS.md` content first and keep that generated block, unchanged,
at the end of the file.

## 4. Apply templates

| Template | Destination | Notes |
|---|---|---|
| `.prettierrc` | `.prettierrc` | |
| `eslint.config.mjs` | `eslint.config.mjs` | Replaces the generated config |
| `tsconfig.json` | `tsconfig.json` | Merge with the generated file; keep `strict: true` and the `@/*` alias. For a repo without `src/`, point `@/*` at `./*` |
| `components.json` | `components.json` | Match `tailwind.css` to the actual global CSS path; set `rsc: false` for Pages Router |
| `lint-staged.config.mjs` | `lint-staged.config.mjs` | |
| `husky-pre-commit` | `.husky/pre-commit` | Created by `husky init`, then replaced |
| `env.example` | `.env.example` | Rename keys to the project's real variables; values stay empty |
| `next.config.security-headers.ts` | merge into `next.config.ts` | Keep existing options; add `headers`, `poweredByHeader`, `productionBrowserSourceMaps` |

Rules:

- Never overwrite an existing file without first showing the user the
  difference and getting agreement.
- Confirm `.gitignore` ignores `.env*` except `.env.example`.

## 5. Install tooling

```bash
yarn add -D prettier eslint-config-prettier husky lint-staged
yarn husky init
```

Then replace `.husky/pre-commit` with the template, and add these scripts to
`package.json` if missing:

```json
{
  "lint": "eslint .",
  "format": "prettier --write .",
  "typecheck": "tsc --noEmit",
  "test": "<project test command>"
}
```

If the project has no test runner yet, set `"test"` to a command that exits
successfully and tell the user tests still need to be added. Do not invent
passing tests.

Optional, when the user asks for the full stack setup:

```bash
yarn add zod react-hook-form @hookform/resolvers zustand
yarn dlx shadcn@latest init
```

Do not add axios.

## 6. Verify

Run, and report the actual results:

```bash
yarn lint
yarn typecheck
yarn build
```

Fix failures caused by the bootstrap changes. Report any that come from the
generator or the existing code without hiding them.

## 7. Report

List the files created or changed, commands run with their results, values the
user must fill in (env vars, CSP origins, Sentry project), and any
"Controls Outside the Code Change" from `SECURITY-STANDARD.md` that the project
still needs (for example CI lockfile installs).
