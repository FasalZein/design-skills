// Load every repo SKILL.md with pi's own skill loader (loadSkillsFromDir, YAML frontmatter parser).
// Exit 0 when each skill folder yields one skill named after its folder; any other result exits 1.
// A missing pi install fails: the check never falls back to a weaker parser.
// Usage: node scripts/check-skill-frontmatter.mjs <repo root>   (PI_DIST overrides the pi dist folder)
import { readdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

async function importSkillLoader(dist) {
  try {
    return (await import(join(dist, "core/skills.js"))).loadSkillsFromDir;
  } catch (error) {
    console.log(`pi skill loader not importable from ${dist}: ${error.message}`);
    process.exit(1);
  }
}

// The failure line for one repo entry, or null when the entry is no skill folder or loads as
// exactly one skill named after its folder.
function skillFolderFailure(loadSkillsFromDir, root, entry) {
  const dir = join(root, entry.name);
  if (!entry.isDirectory() || !existsSync(join(dir, "SKILL.md"))) return null;
  const { skills, diagnostics } = loadSkillsFromDir({ dir, source: "verify" });
  const names = skills.map((s) => s.name);
  if (names.length === 1 && names[0] === entry.name) return null;
  return `${entry.name}/SKILL.md: pi loader returned [${names.join(", ")}]; ${diagnostics.map((d) => d.message).join("; ")}`;
}

const root = process.argv[2];
const dist = process.env.PI_DIST ?? join(homedir(), ".bun/install/global/node_modules/@earendil-works/pi-coding-agent/dist");
const loadSkillsFromDir = await importSkillLoader(dist);
let failures = 0;
for (const entry of readdirSync(root, { withFileTypes: true })) {
  const failure = skillFolderFailure(loadSkillsFromDir, root, entry);
  if (failure === null) continue;
  failures++;
  console.log(failure);
}
process.exit(failures === 0 ? 0 : 1);
