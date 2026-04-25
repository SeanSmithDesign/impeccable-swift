#!/usr/bin/env node
/**
 * Cleans up deprecated impeccable-swift skill files, symlinks, and
 * skills-lock.json entries left over from previous versions of this fork.
 *
 * Safe to run repeatedly -- it is a no-op when nothing needs cleaning.
 *
 * Default mode is dry-run: the script reports what *would* be cleaned but
 * does not delete anything. Pass `--apply` to actually perform the cleanup.
 *
 * Usage (from the project root):
 *   node impeccable/scripts/cleanup-deprecated.mjs            # dry-run, report only
 *   node impeccable/scripts/cleanup-deprecated.mjs --apply    # actually delete
 *   node impeccable/scripts/cleanup-deprecated.mjs --json     # machine-readable
 *
 * What it does:
 *   1. Finds every harness-specific skills directory (.claude/skills,
 *      .cursor/skills, .agents/skills, etc.).
 *   2. For each deprecated skill name (with and without i- prefix),
 *      checks if the directory exists and its SKILL.md mentions
 *      "impeccable" / "impeccable-swift" (to avoid deleting unrelated
 *      user skills).
 *   3. In --apply mode, deletes confirmed matches (files, directories,
 *      symlinks) and removes the corresponding entries from skills-lock.json.
 *      In dry-run (default) mode, only reports the candidates.
 */

import { existsSync, readFileSync, writeFileSync, rmSync, lstatSync, unlinkSync } from 'node:fs';
import { join, resolve } from 'node:path';

// Skills that were renamed, merged, or folded across this fork's history.
// In Wave 6 of the v0.2.0 port, the standalone `critique` and `polish`
// skill directories are removed; their behavior is reachable via
// `/impeccable-swift critique` and `/impeccable-swift polish` respectively.
const DEPRECATED_NAMES = [
  // v0.1 → v0.2 consolidation: standalone skill dirs removed (U9)
  'critique',
  'polish',
  // Inherited from upstream impeccable v2/v3 cleanup, kept for parity so
  // users migrating from a mixed pbakaus + Swift fork install get a
  // single sweep.
  'frontend-design',    // upstream renamed to impeccable
  'teach-impeccable',   // folded into /impeccable-swift teach
  'arrange',            // renamed to layout
  'normalize',          // merged into polish
  'extract',            // merged into /impeccable-swift extract (still a sub-command)
  // Standalone skill directories that should not exist alongside the
  // dispatcher (they live as sub-commands now).
  'adapt', 'animate', 'audit', 'bolder', 'clarify', 'colorize',
  'delight', 'distill', 'harden', 'layout', 'onboard', 'optimize',
  'overdrive', 'quieter', 'shape', 'typeset',
];

// All known harness directories that may contain a skills/ subfolder.
const HARNESS_DIRS = [
  '.claude', '.cursor', '.gemini', '.codex', '.agents',
  '.trae', '.trae-cn', '.pi', '.opencode', '.kiro', '.rovodev',
];

// Per-skill fingerprints for SKILL.md bodies that never mentioned
// "impeccable" in their v2.x source.
const SKILL_FINGERPRINTS = {
  harden: 'Make interfaces production-ready: error handling, empty states',
  optimize: 'Diagnoses and fixes UI performance across loading speed',
};

// Lock-file source values that mark a skill as belonging to this family.
// Both the upstream pack and the Swift fork are recognized so a fork user
// who once installed the upstream pack still gets a clean sweep.
const KNOWN_SOURCES = new Set([
  'pbakaus/impeccable',
  'SeanSmithDesign/impeccable-swift',
]);

/**
 * Walk up from startDir until we find a directory that looks like a
 * project root (has package.json, .git, or skills-lock.json).
 */
export function findProjectRoot(startDir = process.cwd()) {
  let dir = resolve(startDir);
  const root = '/';
  while (dir !== root) {
    if (
      existsSync(join(dir, 'package.json')) ||
      existsSync(join(dir, '.git')) ||
      existsSync(join(dir, 'skills-lock.json'))
    ) {
      return dir;
    }
    const parent = resolve(dir, '..');
    if (parent === dir) break;
    dir = parent;
  }
  return resolve(startDir);
}

/**
 * Load skills-lock.json from the project root, or null if missing/unreadable.
 */
export function loadLock(projectRoot) {
  const lockPath = join(projectRoot, 'skills-lock.json');
  if (!existsSync(lockPath)) return null;
  try {
    return JSON.parse(readFileSync(lockPath, 'utf-8'));
  } catch {
    return null;
  }
}

/**
 * Check whether a skill directory belongs to impeccable / impeccable-swift.
 * Three layered signals, in order of reliability:
 *   1. Lock source equals "pbakaus/impeccable" or
 *      "SeanSmithDesign/impeccable-swift" (authoritative).
 *   2. SKILL.md body contains the word "impeccable".
 *   3. SKILL.md body contains a per-skill fingerprint (legacy).
 */
export function isImpeccableSkill(skillDir, { skillName, lock } = {}) {
  if (skillName) {
    const lockSource = lock?.skills?.[skillName]?.source;
    if (lockSource && KNOWN_SOURCES.has(lockSource)) return true;
  }
  const skillMd = join(skillDir, 'SKILL.md');
  if (!existsSync(skillMd)) return false;
  let content;
  try {
    content = readFileSync(skillMd, 'utf-8');
  } catch {
    return false;
  }
  if (/impeccable/i.test(content)) return true;
  const unprefixed = skillName?.startsWith('i-') ? skillName.slice(2) : skillName;
  const fingerprint = unprefixed && SKILL_FINGERPRINTS[unprefixed];
  if (fingerprint && content.includes(fingerprint)) return true;
  return false;
}

export function buildTargetNames() {
  const names = [];
  for (const name of DEPRECATED_NAMES) {
    names.push(name);
    names.push(`i-${name}`);
  }
  return names;
}

export function findSkillsDirs(projectRoot) {
  const dirs = [];
  for (const harness of HARNESS_DIRS) {
    const candidate = join(projectRoot, harness, 'skills');
    if (existsSync(candidate)) dirs.push(candidate);
  }
  return dirs;
}

/**
 * Find candidate skills (paths that match a deprecated name and look like
 * they belong to impeccable). Does not delete anything. Used by both
 * dry-run and apply modes — apply mode then deletes the returned paths.
 */
export function findDeprecatedCandidates(projectRoot, lock) {
  if (lock === undefined) lock = loadLock(projectRoot);
  const targets = buildTargetNames();
  const skillsDirs = findSkillsDirs(projectRoot);
  const candidates = [];

  for (const skillsDir of skillsDirs) {
    for (const name of targets) {
      const skillPath = join(skillsDir, name);
      let stat;
      try {
        stat = lstatSync(skillPath);
      } catch {
        continue;
      }
      if (stat.isSymbolicLink()) {
        const targetAlive = existsSync(skillPath);
        const isMatch = targetAlive
          ? isImpeccableSkill(skillPath, { skillName: name, lock })
          : true;
        if (isMatch) {
          candidates.push({ path: skillPath, kind: 'symlink', name });
        }
        continue;
      }
      if (isImpeccableSkill(skillPath, { skillName: name, lock })) {
        candidates.push({ path: skillPath, kind: 'directory', name });
      }
    }
  }
  return candidates;
}

/**
 * Find skills-lock.json entries that would be removed.
 */
export function findDeprecatedLockEntries(projectRoot) {
  const lockPath = join(projectRoot, 'skills-lock.json');
  if (!existsSync(lockPath)) return [];
  let lock;
  try {
    lock = JSON.parse(readFileSync(lockPath, 'utf-8'));
  } catch {
    return [];
  }
  if (!lock.skills || typeof lock.skills !== 'object') return [];
  const targets = buildTargetNames();
  const out = [];
  for (const name of targets) {
    const entry = lock.skills[name];
    if (!entry) continue;
    if (entry.source && KNOWN_SOURCES.has(entry.source)) {
      out.push({ name, source: entry.source });
    }
  }
  return out;
}

/**
 * Apply mode: actually delete deprecated skill paths and lock entries.
 */
export function applyCleanup(projectRoot) {
  const lock = loadLock(projectRoot);
  const candidates = findDeprecatedCandidates(projectRoot, lock);
  const deleted = [];
  for (const c of candidates) {
    try {
      if (c.kind === 'symlink') {
        unlinkSync(c.path);
      } else {
        rmSync(c.path, { recursive: true, force: true });
      }
      deleted.push(c.path);
    } catch {
      // best-effort
    }
  }

  // Strip lock entries.
  const lockPath = join(projectRoot, 'skills-lock.json');
  const removedLockEntries = [];
  if (existsSync(lockPath)) {
    let parsed;
    try {
      parsed = JSON.parse(readFileSync(lockPath, 'utf-8'));
    } catch {
      parsed = null;
    }
    if (parsed?.skills && typeof parsed.skills === 'object') {
      const targets = buildTargetNames();
      for (const name of targets) {
        const entry = parsed.skills[name];
        if (entry && entry.source && KNOWN_SOURCES.has(entry.source)) {
          delete parsed.skills[name];
          removedLockEntries.push(name);
        }
      }
      if (removedLockEntries.length > 0) {
        writeFileSync(lockPath, JSON.stringify(parsed, null, 2) + '\n', 'utf-8');
      }
    }
  }

  return { deletedPaths: deleted, removedLockEntries, projectRoot };
}

/**
 * Dry-run report: returns what *would* be cleaned without touching disk.
 */
export function reportCleanup(projectRoot) {
  const root = projectRoot || findProjectRoot();
  const lock = loadLock(root);
  const candidates = findDeprecatedCandidates(root, lock);
  const lockEntries = findDeprecatedLockEntries(root);
  return { candidates, lockEntries, projectRoot: root };
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

function cli() {
  const args = process.argv.slice(2);
  const apply = args.includes('--apply');
  const json = args.includes('--json');
  const help = args.includes('--help') || args.includes('-h');
  if (help) {
    console.log('Usage: node cleanup-deprecated.mjs [--apply] [--json]');
    console.log('');
    console.log('Default mode is dry-run: candidates are reported but nothing');
    console.log('is deleted. Pass --apply to actually perform the cleanup.');
    process.exit(0);
  }

  const root = findProjectRoot();

  if (apply) {
    const result = applyCleanup(root);
    if (json) {
      console.log(JSON.stringify(result, null, 2));
      return;
    }
    if (result.deletedPaths.length === 0 && result.removedLockEntries.length === 0) {
      console.log('No deprecated impeccable-swift skills found. Nothing to clean up.');
    } else {
      if (result.deletedPaths.length > 0) {
        console.log(`Removed ${result.deletedPaths.length} deprecated skill(s):`);
        for (const p of result.deletedPaths) console.log(`  - ${p}`);
      }
      if (result.removedLockEntries.length > 0) {
        console.log(`Cleaned ${result.removedLockEntries.length} entry/entries from skills-lock.json:`);
        for (const name of result.removedLockEntries) console.log(`  - ${name}`);
      }
    }
    return;
  }

  const report = reportCleanup(root);
  if (json) {
    console.log(JSON.stringify(report, null, 2));
    return;
  }
  if (report.candidates.length === 0 && report.lockEntries.length === 0) {
    console.log('No deprecated impeccable-swift skills found. Nothing to clean up.');
    return;
  }
  console.log('Dry-run report (pass --apply to perform deletion):');
  console.log('');
  if (report.candidates.length > 0) {
    console.log(`Would remove ${report.candidates.length} skill path(s):`);
    for (const c of report.candidates) {
      console.log(`  - [${c.kind}] ${c.path}`);
    }
  }
  if (report.lockEntries.length > 0) {
    console.log(`Would clean ${report.lockEntries.length} entry/entries from skills-lock.json:`);
    for (const e of report.lockEntries) console.log(`  - ${e.name} (source: ${e.source})`);
  }
}

const _running = process.argv[1];
if (_running?.endsWith('cleanup-deprecated.mjs') || _running?.endsWith('cleanup-deprecated.mjs/')) {
  cli();
}
