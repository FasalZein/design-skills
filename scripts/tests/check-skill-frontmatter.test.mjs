// Behavior tests for scripts/check-skill-frontmatter.mjs. Run: node --test scripts/tests/
// Each case builds a temporary repo root and runs the checker as verify.sh does (check 13).
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, mkdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const checker = join(dirname(fileURLToPath(import.meta.url)), "..", "check-skill-frontmatter.mjs");

function repoWith(files) {
  const root = mkdtempSync(join(tmpdir(), "fm-check-"));
  for (const [path, text] of Object.entries(files)) {
    mkdirSync(dirname(join(root, path)), { recursive: true });
    writeFileSync(join(root, path), text);
  }
  return root;
}

function check(root, env = {}) {
  const run = spawnSync(process.execPath, [checker, root], { encoding: "utf8", env: { ...process.env, ...env } });
  return { status: run.status, out: run.stdout };
}

const skill = (name) => `---\nname: ${name}\ndescription: Use when testing the checker.\n---\n\n# ${name}\n`;

test("a folder whose SKILL.md names the folder passes; files and folders without SKILL.md are ignored", () => {
  const root = repoWith({ "alpha/SKILL.md": skill("alpha"), "docs/notes.md": "# notes\n", "README.md": "# repo\n" });
  assert.deepEqual(check(root), { status: 0, out: "" });
});

test("a SKILL.md whose name differs from its folder fails and names the folder", () => {
  const root = repoWith({ "alpha/SKILL.md": skill("alpha"), "beta/SKILL.md": skill("gamma") });
  const { status, out } = check(root);
  assert.equal(status, 1);
  assert.match(out, /^beta\/SKILL\.md: pi loader returned \[gamma\]; /);
  assert.doesNotMatch(out, /alpha/);
});

test("a SKILL.md the loader rejects (no description) fails with an empty name list", () => {
  const root = repoWith({ "beta/SKILL.md": "---\nname: beta\n---\n\n# beta\n" });
  const { status, out } = check(root);
  assert.equal(status, 1);
  assert.match(out, /^beta\/SKILL\.md: pi loader returned \[\]; \S/);
});

test("every failing folder is reported, one line each", () => {
  const root = repoWith({ "beta/SKILL.md": skill("x"), "delta/SKILL.md": skill("y") });
  const { status, out } = check(root);
  assert.equal(status, 1);
  assert.deepEqual(out.trim().split("\n").map((l) => l.split(":")[0]).sort(), ["beta/SKILL.md", "delta/SKILL.md"]);
});

test("a missing pi install fails instead of falling back to another parser", () => {
  const root = repoWith({ "alpha/SKILL.md": skill("alpha") });
  const { status, out } = check(root, { PI_DIST: "/nonexistent/pi-dist" });
  assert.equal(status, 1);
  assert.match(out, /^pi skill loader not importable from \/nonexistent\/pi-dist: /);
});
