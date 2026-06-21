# Security Policy

## Supported Versions

Security fixes are handled on the default branch. Until `reportilo` has
a stable release series, only the current development version is
supported.

## Reporting a Vulnerability

Please do not open a public issue for a suspected security
vulnerability.

Report privately to the maintainer email listed in `DESCRIPTION`.
Include:

- affected package or app surface: R package, Shiny app, browser app,
  data pipeline, documentation site, or GitHub Actions;
- steps to reproduce;
- expected and observed behavior;
- whether the issue can expose local files, execute code, exfiltrate
  data, corrupt exports, or misrepresent checklist data;
- package version, commit SHA, browser, operating system, and R or Node
  version.

The maintainer will acknowledge the report when practical, assess
severity, and coordinate a fix before public disclosure when warranted.

## Security-Sensitive Areas

Please take extra care with:

- browser save/load JSON validation;
- SVG, Graphviz DOT, Word, Excel, CSV, and image exports;
- CSV formula neutralization;
- Shiny file downloads and rendered HTML;
- downloaded guideline source files and data-pipeline caches;
- GitHub Actions credentials and deployment workflows.

## Dependency Reports

For browser dependency advisories, distinguish production dependencies
from development toolchain advisories. Production dependency
vulnerabilities should block deployment until resolved or explicitly
assessed.
