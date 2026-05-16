# AGENTS.md

## Communication
  - ユーザーとは日本語で会話してください.
  - Refrain from using emojis.

## Coding
  - Prioritize the simplest readable implementation that satisfies the current requirement.
    - Do not add abstractions, extension points, or configurability for hypothetical future changes unless the user explicitly asks for them.
    - Keep the main execution path easy to trace across as few files and layers as practical.
  - Do not edit tool-generated files unless explicitly permitted.
  - If an absolute path is necessary, ask the user before writing it.

## Bug Troubleshooting
  - When the user reports an error, identify and report the cause before fixing any code.
  - For complex issues, add temporary debug logging to observe behavior, mark it with `TODO: Remove debug code before commit`, and remove it after resolution.

## Web search
  - Prefer English for search queries; use Japanese when needed.
  - Prefer official documentation and primary sources for technical information.

## Sub-agents
  - Spawn sub-agents when parallel exploration would materially help, or when a second-perspective review is needed (design, risk, testing).
  - Keep narrow, immediately actionable work local when delegation would not materially improve speed or quality.

## Dependency Installation Security
  - When adding or running dependencies or tools with Node.js/npm or Python/uv, use a 7-day cooldown to reduce supply-chain attack risk.
  - Before adding packages for project development, check the project-level configuration first.
    - npm: If `.npmrc` does not contain both `min-release-age=7` and `ignore-scripts=true`, report it to the user, add the missing setting(s), then reinstall the package.
    - uv: If `pyproject.toml` or `uv.toml` does not contain `exclude-newer = "7 days"` under `[tool.uv]`, report it to the user, add the setting, then reinstall the package.
  - When using `npm`, `npx`, `uv`, or `uvx` temporarily from a Skill or one-off command, do not rely on persistent configuration; always pass the cooldown option explicitly.
    - npm: `npm install --min-release-age=7 --ignore-scripts <package>`
    - npx: `npx --min-release-age=7 --ignore-scripts <package>`
    - uv: `uv add --exclude-newer "7 days" <package>`
    - uvx: `uvx --exclude-newer "7 days" <tool>`
  - For npm, default to `ignore-scripts=true` to avoid install-time malware triggered by lifecycle scripts.
    - If `preinstall`, `install`, `postinstall`, or another lifecycle script is required, explain the reason and risk to the user, get confirmation, then use `--ignore-scripts=false` only for that command.
    - Use `--foreground-scripts=true` only when script output needs to be inspected. This is for visibility, not protection.
  - For npm, restrict dependencies sourced from git, remote tarballs, local files, or local directories where possible.
    - Prefer `allow-git=root`, `allow-remote=root`, `allow-file=root`, and `allow-directory=root`.
    - If these settings break dependency resolution, report the cause to the user before relaxing them, and relax only the minimum necessary setting.
  - If cooldown or script protections must be bypassed, explain the reason, risk, and safer alternative to the user before running the command.
