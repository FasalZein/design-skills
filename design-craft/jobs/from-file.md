# Surface: from-file

A Figma file, a design image or a .pen file is the source. Read this file once, whole.

## Skills

| Source | Skill | Notes |
|---|---|---|
| A Figma file or a design image | build-design | Load while you gather facts; it runs the build |
| A .pen or .lib.pen file | pencil-design (optional) | Needs the Pen MCP server |

## Decisions

The file closes every decision it shows. DIRECTION names the file path or URL. Map its values to the project's tokens and components. A value with no matching token is an open primitive decision: attended, it joins the frontier; headless, it goes into OPEN.

## Rules

- No Figma or Pen MCP tool in this session: write the skill's MCP as missing, build from an exported image when the brief provides one, else report PARTIAL (scope).

Done when DIRECTION names the source file and every unmapped value is in OPEN or DESIGN.md.
