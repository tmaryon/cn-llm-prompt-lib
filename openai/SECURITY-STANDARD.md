# PeakROI Secure Engineering Standard

Read this entire document before implementing a change that matches a trigger in the Security section of `AGENTS.md`. It applies to frontend code and to the Next.js or API boundaries that support the frontend.

This standard uses the OWASP Top 10:2025 and the OWASP Top 10 for LLM Applications 2026 as awareness baselines. It is not proof of compliance and does not replace threat modeling, the OWASP Application Security Verification Standard, expert review, or appropriate security testing.

## How to Use This Document

- Apply controls and verification in proportion to the affected trust boundaries and plausible impact. Not every control applies to every change.
- The controls are requirements for the product code you write. They do not change your own execution rules in `AGENTS.md`.
- Controls owned by platform, operations, or vendor processes are listed under Controls Outside the Code Change. Do not implement them unprompted; report them when a change depends on one that appears missing.
- Record material assumptions, checks performed, and residual risks in your final report. Do not turn every low-risk change into a full security audit.

## Security Workflow

Before implementation:

1. Identify the browser, server, database, file, model, and third-party trust boundaries involved.
2. Identify authentication, authorization, tenant isolation, personal-data, financial-data, and destructive-action implications.
3. Determine plausible misuse cases, failure modes, and the controls that must fail closed.
4. Reuse established identity, validation, logging, cryptography, and security-header infrastructure.

During implementation:

- Treat browser input, URL parameters, cookies, headers, API responses, files, third-party content, logs, tickets, retrieved documents, and model output as untrusted.
- Apply least privilege and minimize the data, permissions, tools, retention, and external access used by the feature.
- Enforce security decisions in deterministic server code. Client checks and natural-language prompts are not security boundaries.
- Preserve safe failure behavior. Do not silently bypass a control to keep a flow working.

## OWASP Web Application Controls

### A01:2025 — Broken Access Control

- Deny by default and authorize every protected read and mutation on the server.
- Derive user, tenant, role, and ownership from trusted server-side identity rather than client input.
- Check access to the requested object to prevent insecure direct object references.
- Allowlist redirect destinations and outbound server requests; block private-network and cloud-metadata access where server fetching is supported.
- Apply appropriate CSRF protection to cookie-authenticated state-changing requests.

### A02:2025 — Security Misconfiguration

- Use secure production defaults and exclude debug routes, verbose errors, internal details, and sensitive source maps.
- Configure and test Content Security Policy, framing restrictions, MIME protection, referrer policy, and permissions policy as applicable.
- Restrict CORS to explicit trusted origins, methods, and headers. Never combine credentialed requests with wildcard origins.
- Use `Secure`, `HttpOnly`, and an appropriate `SameSite` value for session cookies.

### A03:2025 — Software Supply Chain Failures

- Prefer existing dependencies and platform APIs over unnecessary new packages.
- Before adding a dependency, review its provenance, maintenance, license, transitive impact, install scripts, and known vulnerabilities.
- Include lockfile changes whenever dependencies change, and install with the repository's lockfile-based command.
- Do not suppress dependency findings without a documented risk decision or compensating control.

### A04:2025 — Cryptographic Failures

- Never place secrets, private keys, privileged tokens, or confidential configuration in client code, browser storage, URLs, or public build variables.
- Use TLS and approved platform or server cryptographic libraries. Do not create custom encryption, hashing, token, or password schemes.
- Minimize collection and retention of personal, authentication, financial, and customer data.
- Redact sensitive values from logs, analytics, telemetry, traces, and error reports.

### A05:2025 — Injection

- Validate untrusted data at server boundaries using strict runtime schemas. TypeScript types are not runtime validation.
- Use parameterized database operations and structured SDK APIs; never concatenate executable SQL, shell, GraphQL, LDAP, or template expressions.
- Render user content as text. Avoid `dangerouslySetInnerHTML`; when rich HTML is unavoidable, use an established sanitizer configured for the exact use case.
- Never use `eval`, `new Function`, string-based timers, or unsanitized dynamic execution.
- Validate URLs and protocols before links, redirects, images, or fetches. Reject dangerous schemes such as `javascript:`.
- Encode output for its destination context; HTML sanitization does not make data safe for URLs, SQL, CSS, or shell commands.

### A06:2025 — Insecure Design

- Enforce server-side business invariants for state transitions, ownership, limits, totals, prices, eligibility, and approvals.
- Give destructive or high-impact actions a confirmation step and an appropriate recovery path.
- Apply rate limits, quotas, replay protection, and idempotency where abuse or duplicate execution could cause harm.
- Fail closed when a security decision cannot be completed.

### A07:2025 — Authentication Failures

- Use the established identity provider and session library; do not implement custom authentication without explicit review.
- Rotate session identifiers after authentication or privilege changes and invalidate sessions when appropriate.
- Avoid account-enumeration differences in login, recovery, and invitation flows unless the product has accepted that risk.
- Never log passwords, authorization headers, cookies, session tokens, one-time codes, or reset links.
- Use recent or step-up authentication for high-risk security and account changes when supported.

### A08:2025 — Software or Data Integrity Failures

- Do not trust hidden fields, local storage, cached roles, unsigned client state, prices, feature flags, webhook bodies, or client-calculated totals.
- Verify webhook signatures and replay protections before processing data.
- Strictly validate imported and deserialized content and reject unexpected fields when practical.
- Keep privileged feature decisions authoritative on the server.

### A09:2025 — Security Logging and Alerting Failures

- Record relevant authentication failures, authorization denials, role changes, sensitive exports, destructive actions, and security-configuration changes.
- Use structured logs and correlation identifiers where available.
- Exclude secrets, tokens, sensitive request bodies, unnecessary personal data, and payment information.

### A10:2025 — Mishandling of Exceptional Conditions

- Handle malformed data, timeouts, cancellation, dependency failures, expired sessions, partial responses, races, and duplicate submissions explicitly.
- Never treat failed validation, missing authorization, or an unexpected exception as success.
- Show safe user-facing errors while retaining non-sensitive diagnostics on the server.
- Ensure stale or failed states cannot expose data or enable privileged actions.
- Clean up subscriptions, timers, object URLs, and pending asynchronous work.

## Forms, APIs, Files, and Data

- Validate forms on the client for feedback and again on the server for security.
- Allowlist writable fields to prevent mass assignment of roles, ownership, approval state, and other protected attributes.
- Recheck authorization and mutable business conditions when each mutation executes.
- Use safe decimal or integer handling for authoritative money calculations.
- Treat file names, extensions, MIME types, and client size checks as untrusted; validate content and limits on the server.
- Limit pagination, filtering, batch operations, and exports to prevent unrestricted data access or resource use.
- Use cancellation when stale requests could overwrite newer state.

## OWASP LLM Application Controls

Apply this section to AI features in the product: chat, RAG, embeddings, model APIs, agents, AI-generated content, and AI tool integrations. These controls govern what you build, not your own behavior as a coding agent. A model is neither an authorization system nor an authoritative source of truth. Keep credentials, policy enforcement, and privileged execution in deterministic server code. For tool-using autonomous agents, also threat-model the agent's identity, memory, tools, delegation, and external effects.

### LLM01:2026 — Prompt Injection

- Treat prompts, uploads, webpages, emails, retrieved documents, memory, tool responses, metadata, images, audio, video, and model output as untrusted content rather than authoritative instructions.
- Separate instructions from content using structured roles, provenance labels, and fields, but do not rely on prompt wording as a security boundary.
- Enforce permissions, data access, business rules, tool eligibility, and output handling in deterministic code before and after model calls.
- Allowlist tools, strictly validate arguments, and test direct, indirect, multimodal, cross-session, and tool-mediated injection.
- Treat writes to persistent memory, RAG corpora, prompts, and indexes as privileged, auditable operations.

### LLM02:2026 — Sensitive Information Disclosure

- Send only the minimum authorized data required; redact or tokenize sensitive values when they are not essential.
- Never store secrets or authorization decisions in prompts or assume hidden context, reasoning, memory, or tool output cannot be exposed.
- Authorize context before model calls and authorize generated results before disclosure.
- Keep sensitive prompts and responses out of client logs, analytics, traces, errors, and long-lived caches.

### LLM03:2026 — Excessive Agency

- Grant the minimum tools, permissions, data, duration, and autonomy required for the specific task.
- Prefer narrow task-specific tools over general shell, browser, database, filesystem, email, or administrative access.
- Scope credentials to the user, tenant, action, and environment; reauthorize at execution time.
- Bound calls, delegation, recursion, runtime, affected records, transaction value, and external recipients.
- Show the end user the exact action and require confirmation immediately before destructive, financial, externally visible, permission-changing, or irreversible execution, unless the user's instruction named that exact action.
- Make consequential actions auditable, idempotent when possible, reversible when practical, and stoppable.

### LLM04:2026 — Supply Chain

- Before adding a provider, model, SDK, plugin, MCP server, or tool integration, review its provenance, license, integrity, privacy terms, maintenance, installation behavior, and known risks.
- Pin and verify versions, model identifiers, packages, and tool definitions where supported.
- Provide a safe-disable or fallback path for compromised, unavailable, or materially changed dependencies.

### LLM05:2026 — Data and Model Poisoning

- Record provenance for content written to memory or retrieval stores.
- Validate, scan, deduplicate, and review content before ingestion or promotion to trusted sources.
- Separate user submissions from trusted knowledge and prevent cross-tenant modification.
- Restrict and log dataset, prompt, model-configuration, memory, and index changes.

### LLM06:2026 — Unbounded Consumption

- Enforce authenticated server-side limits and quotas by user, tenant, model, key, tool, and operation as appropriate.
- Cap prompt length, uploads, retrieved context, output tokens, batch size, tool calls, recursion, concurrency, retries, and execution time.
- Use cancellation, timeouts, bounded retry with backoff, circuit breakers, queues, and idempotency controls.
- Enforce hard usage and cost limits in server code.
- Degrade safely when limits are reached. Client-side limits are usability features, not security controls.

### LLM07:2026 — Misinformation

- Do not present generated claims as verified facts merely because the model expresses confidence.
- Ground consequential answers in approved sources and expose inspectable citations when the use case supports them.
- Verify calculations, eligibility, pricing, policies, dates, identifiers, and irreversible decisions against authoritative systems.
- Provide human review or escalation for high-impact, ambiguous, or low-confidence outcomes.
- Test stale knowledge, conflicting sources, fabricated citations, and misleadingly confident answers.

### LLM08:2026 — Hidden Context Exposure

- Assume system prompts, hidden instructions, reasoning, memory, retrieved context, and tool metadata may be inferred or exposed.
- Keep secrets, credentials, authorization, and sensitive business rules out of model context and enforce them in server code.
- Minimize hidden context and avoid unnecessary internal details or data.
- Treat prompt-concealment and instruction-separation techniques as defense in depth, not security controls.

### LLM09:2026 — Vector and Embedding Weaknesses

- Authorize documents before ingestion and authorize each result before adding it to model context.
- Isolate data by tenant, user, sensitivity, and environment using server-enforced filters.
- Do not treat similarity as proof of trust, relevance, safety, provenance, or authorization.
- Limit result counts and document sizes, validate filters, and protect against enumeration, bulk export, poisoning, and cross-tenant retrieval.
- When source documents are deleted, delete their embeddings and cached derivatives.

### LLM10:2026 — Improper Output Handling

- Treat model output as untrusted input to every downstream system.
- Validate structured output against strict schemas and reject invalid, extra, or out-of-range fields.
- Render generated content as text by default and sanitize approved rich content for its destination context.
- Never execute model output as code, queries, commands, templates, URLs, or tool calls without deterministic validation and authorization.
- Separate proposal, review, authorization, and execution; generated content must not silently trigger side effects.

## Security Verification

Select checks proportionate to the affected risk:

- Expected, malformed, boundary, and oversized input
- Unauthenticated, unauthorized, wrong-role, wrong-owner, and cross-tenant access
- Direct-object-reference and mass-assignment attempts
- Injection through forms, URLs, files, external content, retrieval, and model output
- Duplicate requests, replay, concurrency, timeout, dependency failure, and partial completion
- Sensitive-data exposure through UI, responses, client bundles, caches, logs, analytics, and errors
- Dependency, configuration, security-header, cookie, and CORS review
- Direct and indirect prompt injection, unauthorized tool use, context leakage, misinformation, and resource exhaustion for AI features

Document what was tested and any residual risk. Never claim that an implementation is “OWASP compliant” solely because this checklist was followed.

## Controls Outside the Code Change

These controls are usually owned by platform, operations, security, or vendor-management processes. Do not implement them unprompted. If a change depends on one that appears missing, say so in your report.

- CI enforces reproducible, lockfile-based installation. (A03)
- Important security events have actionable alerts, risk-appropriate retention, and a response owner. (A09)
- Model provider retention, training, region, and enterprise privacy terms are approved before sensitive data is sent. (LLM02)
- Providers, models, adapters, datasets, embedding models, vector stores, SDKs, prompts, plugins, MCP servers, and tool integrations are inventoried and approved, and material or silent changes are evaluated. (LLM04)
- Training, evaluation, and fine-tuning data has documented provenance; datasets, prompts, and model configurations are versioned with rollback and deletion, and behavior is re-evaluated after changes. (LLM05)
- Usage and cost budgets have alerts, and tokens, latency, errors, tool activity, and spend are monitored. (LLM06)
- Retention, deletion, and rebuild procedures exist for source documents, embeddings, caches, and derived indexes. (LLM09)
