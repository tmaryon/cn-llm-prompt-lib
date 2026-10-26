# Review Procedure

Review frontend code against `AGENTS.md`, `SECURITY-STANDARD.md`, and
`house-conventions.md`. Report findings; do not edit code unless the user asks.

## 1. Determine scope

- **Diff review (default)**: the current branch's changes against its base,
  `git diff $(git merge-base HEAD origin/staging)...HEAD`, plus uncommitted
  changes from `git diff HEAD`. Fall back to `origin/master` or the default
  branch if `staging` does not exist. Use the remote-tracking refs already
  present; fetch only if the user allows it, and say which base you used.
- **Named scope**: if the user names files, directories, a commit range, or a
  pull request, review exactly that.
- **Whole-repository audit**: when the scope is an entire repository, do not
  read every file. Work in priority order and say what you sampled:
  1. Grep for the known anti-patterns in section 3.
  2. Review trust boundaries: API clients, forms and their server handlers,
     auth and session code, middleware, webhooks, env and config files,
     custom servers, and security headers.
  3. Skim the rest only as time allows.
  Cap the report at the most significant findings (about 15 per repository)
  and say if more exist.
- **Server code in the same repository**: Route Handlers, Server Actions,
  `pages/api`, custom SSR servers, and backend folders the frontend calls are
  in scope, because they are the frontend's security boundary.
- Read surrounding code only as far as needed to confirm a finding.
- Detect whether the repo is target-stack or legacy-stack (see `SKILL.md`).
  Do not report legacy library choices as findings. Rules phrased as "new
  code" (such as new axios usage) apply only to added lines in a diff review;
  skip them in a whole-repository audit.

## 2. Passes, in order

1. **Security**: walk the OWASP web controls (A01–A10), the Forms, APIs,
   Files, and Data section, and, for AI features, the LLM controls (LLM01–LLM10).
2. **Correctness and data integrity**: logic errors, race conditions,
   missing transactions, unhandled promise rejections, stale state, missing
   call sites.
3. **Accessibility**: labels, accessible names, keyboard and focus, semantics,
   status announcements, contrast (WCAG 2.2 AA).
4. **Code standards**: the `AGENTS.md` Code Standards, React and Next.js, and
   Styling sections, plus async states (loading, empty, error, retry,
   disabled, duplicate submission).
5. **House conventions**: `house-conventions.md`.

## 3. Known PeakROI anti-patterns

Search the scope for these first; they have occurred in PeakROI repos.

| Pattern | Look for | Rule |
|---|---|---|
| Secret in a public env prefix | `NEXT_PUBLIC_*` / `VITE_*` values that are not publishable (see below) | A04 |
| Personal data or tokens in browser storage | `localStorage`, `sessionStorage`, zustand `persist` without `partialize` | A04, A08 |
| Personal data sent to Sentry or analytics | `sendDefaultPii: true`, `setUser({ email })`, form values or response bodies in `extra`/`context`, unmasked Session Replay | A04, A09 |
| Unvalidated link, media, or redirect URLs | `href={...}`, `src={...}`, `window.location`, `router.push` fed by CMS, API, or user data without a protocol and host allowlist | A05, A01 |
| Raw HTML rendering | `dangerouslySetInnerHTML`, `innerHTML`, Markdown renderers with raw HTML enabled | A05 |
| Wildcard CORS with credentials | `origin: '*'` with `credentials: true`, reflected origins | A02 |
| Optional webhook signatures | signature check skipped when the header is missing, stubbed verifiers, non-constant-time comparison | A08 |
| Client-only validation or authorization | forms posting to handlers with no server schema; role checks only in UI | A01, A05 |
| Mass assignment | request bodies spread into inserts or updates (`...body`) | A01 |
| Leaky errors | `error.message`, `String(e)`, `e.stack` returned in responses, SSR error pages, or shown in UI | A10, A02 |
| Missing security headers | custom Express or SSR servers and `next.config` without CSP, `nosniff`, framing, referrer, and permissions policies | A02 |
| Public source maps | `sourcemap: true` / `productionBrowserSourceMaps: true` with maps served publicly | A02 |
| Client-trusted state | prices, totals, roles, or "has submitted" flags read from cookies or storage and trusted for a decision | A08, A06 |
| Non-lockfile installs | `npm install` in a yarn repo, `yarn install` without `--frozen-lockfile` in CI | A03 |
| New axios usage | `import axios` on added lines | House conventions › HTTP |

**Publishable versus secret values.** Usually safe in public env vars:
Supabase anon or `sb_publishable_` keys (with RLS enforced), Sentry DSNs,
Turnstile or reCAPTCHA site keys, analytics measurement IDs, and API keys that
the provider restricts by referrer. Never public: CMS or API tokens
(`*_API_TOKEN`), Supabase service-role or `sb_secret_` keys, HMAC or webhook
secrets, database URLs, and unrestricted third-party keys. When the scope of a
key cannot be confirmed, report it at the lower level and state the condition
that would raise it.

## 4. Severity

Rate each finding by its realistic impact and exploitability in this
codebase. The patterns in section 3 do not have fixed levels.

- **Critical**: exploitable now with serious impact. An exposed secret with
  write or privileged scope, missing or bypassable authentication or
  authorization on a protected action (including a webhook that triggers
  writes without a verified signature), exploitable injection or XSS,
  cross-tenant or cross-user data access.
- **High**: likely exposure or integrity loss that needs another condition to
  become critical. Personal data in browser storage, logs, Sentry, or
  analytics; mass assignment or missing server validation behind
  authentication; unvalidated URL protocols from external data; a public token
  of unknown scope; public source maps.
- **Medium**: real defect with limited or indirect impact. Leaky error
  details, missing security headers, wildcard CORS when auth is bearer-only,
  missing error, loading, or retry states, duplicate submission, accessibility
  failures that block a task, `any` at a trust boundary, new axios usage,
  unbounded lists or requests.
- **Low**: maintainability and convention. Naming, the `handle` prefix,
  needless `useEffect`, minor accessibility polish, formatting outside the
  formatter.

When a finding sits between two levels, pick the level that matches its
current exploitability and state the condition that would change it.

## 5. Output format

Group by repository when reviewing more than one. Use paths relative to the
repository root. Within each repository, list findings most severe first:

```text
[Severity] path/to/file.tsx:42 — Rule ID or section
What is wrong, in one or two sentences, with the concrete failure scenario.
Fix: the specific change to make.
```

- For a finding that spans several places, cite the primary location and list
  the others in the description (`also: path/a.ts:10, path/b.ts:88`).
- Use rule IDs such as `A01`, `A05`, `LLM10` for security findings, and section
  names such as `AGENTS.md › Code Standards`, `AGENTS.md › Styling and
  Accessibility`, or `House conventions › HTTP` for others.

After the findings for each repository, add:

- **Stack**: target or legacy stack, and, for legacy stacks, one line on the
  main gaps against the target stack (not counted as findings).
- **Not checked**: checks you could not run or areas you did not cover.
- **Residual risk**: assumptions and remaining risks.
- **Controls outside the code**: any control from "Controls Outside the Code
  Change" in `SECURITY-STANDARD.md` that appears missing.

If there are no findings, say so and still list what was checked. Never claim
the code is "OWASP compliant".
