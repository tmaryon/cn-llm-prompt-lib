# PeakROI House Conventions

Conventions shared across PeakROI frontend repositories. They complement
`AGENTS.md`. A repository's own established conventions win where they differ;
see Legacy stacks in `SKILL.md`.

## Tooling

- Package manager: yarn v1. Commit `yarn.lock`, install with
  `yarn install --frozen-lockfile` in CI, and never create a second lockfile
  (`package-lock.json`, `pnpm-lock.yaml`).
- Pre-commit: husky v9 runs `lint-staged`, then the test suite. Do not bypass
  hooks with `--no-verify`.
- Formatter: Prettier with semicolons, single quotes, trailing commas
  everywhere, 2-space indentation, and the repository's `printWidth` (80 for
  new projects). Do not mix formatting-only churn into functional changes.
- TypeScript: `strict: true` for new projects. Do not disable
  `@typescript-eslint/no-explicit-any` or `react-hooks/exhaustive-deps` in
  new lint configs.
- Path alias: `@/*` maps to the project source root.

## Libraries

| Concern | Use | Notes |
|---|---|---|
| UI | Tailwind CSS, shadcn/ui, Radix UI, lucide icons | Components in `components/ui`; `cn()` from `lib/utils` |
| Forms | react-hook-form + zod | Share the zod schema with the server and re-validate there |
| Client state | zustand | Keep stores small; prefer local state and server data first |
| HTTP | native `fetch` | No axios in new code; see HTTP below |
| Error monitoring | Sentry | No default PII; scrub secrets and personal data |

Prefer existing dependencies and platform APIs before adding a package. New
dependencies follow A03 in `SECURITY-STANDARD.md`.

## HTTP

- Do not add axios to new code or new modules. In existing modules that use
  axios, keep it unless the change already rewrites that module's requests.
- Route requests through one shared typed `fetch` wrapper per project (for
  example `lib/http.ts`) that:
  - applies a timeout with `AbortController` and accepts a caller `signal`
    so stale requests can be cancelled;
  - checks `response.ok` and throws a typed error that carries the status but
    no response body, secrets, or personal data;
  - parses JSON with a zod schema supplied by the caller and returns the
    parsed type, never an unvalidated `any`;
  - sets `credentials` explicitly rather than relying on defaults.
- In Next.js, call privileged or secret-bearing APIs from server code (Route
  Handlers, Server Actions, Server Components, or `pages/api`) and expose only
  what the browser needs.
- Bound retries with backoff; never retry non-idempotent mutations
  automatically.

## State and storage

- Persisted zustand stores (`persist` middleware) and any `localStorage` or
  `sessionStorage` use must not contain tokens, secrets, personal data (names,
  emails, phones, addresses, hashed identifiers), roles, or prices. Use
  `partialize` to allowlist safe fields.
- Client state is never authoritative for authorization, eligibility, or
  totals.

## Environment variables

- Anything prefixed `NEXT_PUBLIC_` (Next.js) or `VITE_` (Vite) is compiled into
  the browser bundle and is public. Only put values there that are safe to
  publish, such as site keys, DSNs, and referrer-restricted keys.
- API tokens, HMAC secrets, CMS tokens, service-role keys, and database URLs
  are server-only.
- Validate env vars at startup with a zod schema, split into server and client
  schemas. Commit `.env.example` with empty or obviously fake values only.

## Errors and logging

- Report unexpected errors to Sentry with context that excludes secrets,
  tokens, request bodies, form values, and personal data. Set
  `sendDefaultPii: false`, identify users by opaque ID only (never email), and
  keep Session Replay masking on.
- Show users safe, actionable messages. Never surface stack traces or raw
  server error text.
- Do not publish client source maps publicly; upload them to Sentry instead.

## Git flow

- Branch from `staging` using `feat/<kebab-case>` or `fix/<kebab-case>`
  (`chore/`, `refactor/`, `docs/`, and `test/` are also fine).
- Open pull requests into `staging`. `staging` is promoted to `master`
  (production) through its own pull request.
- Commit messages use the conventional format in `AGENTS.md`:
  `<type>[optional scope]: <imperative description>`.
