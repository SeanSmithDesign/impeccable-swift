// Parse a Swift-flavored DESIGN.md (Stitch-spec format) into a structured JSON
// model that downstream impeccable-swift commands can consume. Deterministic,
// dependency-free.
//
// Two-layer: YAML frontmatter (machine-readable tokens) + markdown body
// (prose with six canonical H2 sections). When frontmatter is present, it's
// exposed on `model.frontmatter` alongside the prose-scraped sections;
// consumers can prefer frontmatter values and fall back to prose.
//
// Swift adaptation vs upstream pbakaus/impeccable design-parser.mjs:
//   - Color values: in addition to #hex / oklch / rgba, recognize Asset Catalog
//     paths (`Colors/Primary`, `AssetCatalog:Primary`, or bare `Primary` Color
//     Set names when explicitly tagged). Detected `format` may be
//     'hex' | 'oklch' | 'rgb' | 'asset-catalog' | 'unknown'.
//   - Typography: SF Pro, SF Pro Display, SF Pro Text, SF Compact, SF Mono, and
//     `.system()` are recognized as system font families. Hierarchy entries
//     also recognize Dynamic Type tier labels (largeTitle, title, title2, title3,
//     headline, subheadline, body, callout, footnote, caption, caption2,
//     accessibility1-accessibility5).
//   - Elevation: in addition to box-shadow, recognize Swift Materials
//     (.ultraThinMaterial, .thinMaterial, .regularMaterial, .thickMaterial,
//     .ultraThickMaterial, .bar) and Liquid Glass references.
//   - Spacing: numeric values are interpreted as pt (Swift point system) on a
//     4pt scale; the parser does not rewrite them, but downstream consumers can
//     trust the unit hint emitted in `model.units`.
//
// Exports unchanged from upstream: parseDesignMd(md), assessCoverage(model).
// Output JSON shape is a superset — existing fields keep their meaning; new
// fields (`format: 'asset-catalog'`, font `system: true`, `dynamicType` on
// hierarchy entries, materials in elevation) are additive.

import fs from 'node:fs';
import path from 'node:path';

const CANONICAL_SECTIONS = [
  'Overview',
  'Colors',
  'Typography',
  'Elevation',
  'Components',
  "Do's and Don'ts",
];

// ---------- Frontmatter (Stitch YAML subset) ----------

function parseFrontmatter(md) {
  const lines = md.split(/\r?\n/);
  if (lines[0]?.trim() !== '---') return { frontmatter: null, body: md };

  let end = -1;
  for (let i = 1; i < lines.length; i++) {
    if (lines[i].trim() === '---') { end = i; break; }
  }
  if (end === -1) return { frontmatter: null, body: md };

  const yaml = lines.slice(1, end).join('\n');
  const body = lines.slice(end + 1).join('\n');
  try {
    return { frontmatter: parseYamlSubset(yaml), body };
  } catch {
    return { frontmatter: null, body: md };
  }
}

// Minimal YAML reader for the Stitch frontmatter subset: scalar maps with
// one level of nested objects (typography roles, components). Indent-based,
// 2-space convention. No arrays, no anchors, no multi-line scalars — Stitch's
// schema doesn't need them and accepting them would require a real YAML
// dependency we don't want to vendor.
function parseYamlSubset(yaml) {
  const lines = yaml.split(/\r?\n/);
  const root = {};
  const stack = [{ indent: -1, obj: root }];

  for (const raw of lines) {
    if (!raw.trim() || /^\s*#/.test(raw)) continue;

    const indent = raw.match(/^\s*/)[0].length;
    const content = raw.slice(indent);

    const colonIdx = findTopLevelColon(content);
    if (colonIdx === -1) continue;

    while (stack.length > 1 && stack[stack.length - 1].indent >= indent) {
      stack.pop();
    }

    const key = content.slice(0, colonIdx).trim();
    const rest = content.slice(colonIdx + 1).trim();
    const parent = stack[stack.length - 1].obj;

    if (rest === '') {
      const obj = {};
      parent[key] = obj;
      stack.push({ indent, obj });
    } else {
      parent[key] = parseScalar(rest);
    }
  }

  return root;
}

function findTopLevelColon(s) {
  let inQuote = null;
  for (let i = 0; i < s.length; i++) {
    const ch = s[i];
    if (inQuote) {
      if (ch === inQuote && s[i - 1] !== '\\') inQuote = null;
    } else if (ch === '"' || ch === "'") {
      inQuote = ch;
    } else if (ch === ':') {
      return i;
    }
  }
  return -1;
}

function parseScalar(raw) {
  const s = raw.trim();
  if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) {
    return s.slice(1, -1);
  }
  if (s === 'true') return true;
  if (s === 'false') return false;
  if (s === 'null' || s === '~') return null;
  if (/^-?\d+$/.test(s)) return Number(s);
  if (/^-?\d*\.\d+$/.test(s)) return Number(s);
  return s;
}

// ---------- Value detectors (Swift-aware) ----------

const HEX_RE = /#[0-9a-fA-F]{3,8}\b/g;
const OKLCH_RE = /oklch\([^)]+\)/gi;
const RGBA_RE = /rgba?\([^)]+\)/gi;
// Asset Catalog notation: `Colors/Primary`, `AssetCatalog:Primary`, or
// `Color("Primary")` style. Capture the leaf name plus the original token.
const ASSET_CATALOG_RE = /\b(?:Colors\/|AssetCatalog:)([A-Za-z][\w/.-]*)\b/g;
const COLOR_LITERAL_RE = /\bColor\s*\(\s*"([^"]+)"\s*(?:,\s*bundle:[^)]+)?\)/g;
const NAMED_RULE_RE = /\*\*(The [^*]+?Rule)\.\*\*\s*(.+)/;

// Apple system font families.
const SYSTEM_FONT_FAMILIES = [
  'SF Pro', 'SF Pro Display', 'SF Pro Text', 'SF Pro Rounded',
  'SF Compact', 'SF Compact Display', 'SF Compact Text', 'SF Compact Rounded',
  'SF Mono',
  'New York',
  '.system', 'Font.system', 'system',
];

// Dynamic Type tier names (SwiftUI Font text styles + accessibility tiers).
const DYNAMIC_TYPE_TIERS = new Set([
  'largetitle', 'title', 'title2', 'title3',
  'headline', 'subheadline',
  'body', 'callout', 'footnote',
  'caption', 'caption2',
  'accessibility1', 'accessibility2', 'accessibility3', 'accessibility4', 'accessibility5',
]);

// SwiftUI Materials + Liquid Glass surfaces.
const MATERIAL_TOKENS = [
  '.ultraThinMaterial', '.thinMaterial', '.regularMaterial',
  '.thickMaterial', '.ultraThickMaterial',
  '.bar',
  'LiquidGlass', 'Liquid Glass', '.glassEffect', '.glass',
];

const MATERIAL_RE = /(\.ultraThinMaterial|\.thinMaterial|\.regularMaterial|\.thickMaterial|\.ultraThickMaterial|\.bar|\.glassEffect|\.glass\b|Liquid\s*Glass|LiquidGlass)/g;

// ---------- Section splitting ----------

function splitSections(md) {
  const lines = md.split(/\r?\n/);
  let title = null;
  const sections = {};
  let current = null;
  const seenH2 = [];

  for (const raw of lines) {
    const line = raw.trimEnd();

    if (!title && line.startsWith('# ') && !line.startsWith('## ')) {
      title = line.replace(/^#\s+/, '').trim();
      continue;
    }

    const h2 = line.match(/^##\s+(?:\d+\.\s*)?([^:\n]+?)(?::\s*(.+))?$/);
    if (h2) {
      const rawName = normalizeApostrophes(h2[1].trim());
      const subtitle = h2[2] ? h2[2].trim() : null;
      const canonical = matchCanonicalSection(rawName);
      seenH2.push(rawName);
      if (canonical) {
        current = { name: canonical, subtitle, lines: [] };
        sections[canonical] = current;
        continue;
      }
      current = null;
      continue;
    }

    if (current) current.lines.push(raw);
  }

  return { title, sections, seenH2 };
}

function normalizeApostrophes(s) {
  return s.replace(/[‘’]/g, "'");
}

function matchCanonicalSection(name) {
  const normalized = normalizeApostrophes(name).toLowerCase();
  for (const c of CANONICAL_SECTIONS) {
    if (normalizeApostrophes(c).toLowerCase() === normalized) return c;
  }
  for (const c of CANONICAL_SECTIONS) {
    const key = normalizeApostrophes(c).toLowerCase();
    const pattern = new RegExp(`\\b${key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`);
    if (pattern.test(normalized)) return c;
  }
  return null;
}

// ---------- Subsection splitting (inside a canonical section) ----------

function splitSubsections(lines) {
  const subs = [];
  let current = { name: null, lines: [] };
  subs.push(current);

  for (const raw of lines) {
    const h3 = raw.match(/^###\s+(.+?)\s*$/);
    if (h3) {
      current = { name: h3[1].trim(), lines: [] };
      subs.push(current);
      continue;
    }
    current.lines.push(raw);
  }

  return subs;
}

// ---------- Generic helpers ----------

function collectParagraphs(lines) {
  const paragraphs = [];
  let buf = [];
  const flush = () => {
    if (buf.length) {
      paragraphs.push(buf.join(' ').trim());
      buf = [];
    }
  };
  for (const raw of lines) {
    const trimmed = raw.trim();
    if (trimmed === '') { flush(); continue; }
    if (/^(?:-{3,}|\*{3,}|_{3,})$/.test(trimmed)) { flush(); continue; }
    if (raw.startsWith('#') || raw.match(/^[-*]\s/)) { flush(); continue; }
    buf.push(trimmed);
  }
  flush();
  return paragraphs.filter(Boolean);
}

function collectBullets(lines) {
  const bullets = [];
  let current = null;
  for (const raw of lines) {
    const m = raw.match(/^\s*[-*]\s+(.+)$/);
    if (m) {
      if (current) bullets.push(current);
      current = m[1];
      continue;
    }
    if (current && raw.match(/^\s{2,}\S/)) {
      current += ' ' + raw.trim();
      continue;
    }
    if (raw.trim() === '' && current) {
      bullets.push(current);
      current = null;
    }
  }
  if (current) bullets.push(current);
  return bullets;
}

function stripBold(s) {
  return s.replace(/\*\*(.+?)\*\*/g, '$1');
}

function extractNamedRules(lines) {
  const rules = [];
  const seen = new Set();

  const joined = lines.join('\n');
  const inlineStart = /\*\*(The [^*]+?Rule)\.\*\*/g;
  const inlineMatches = [];
  let m;
  while ((m = inlineStart.exec(joined)) !== null) {
    inlineMatches.push({ name: m[1], start: m.index, end: inlineStart.lastIndex });
  }
  for (let i = 0; i < inlineMatches.length; i++) {
    const mm = inlineMatches[i];
    const bodyEnd = i + 1 < inlineMatches.length ? inlineMatches[i + 1].start : joined.length;
    const body = joined
      .slice(mm.end, bodyEnd)
      .replace(/\n##[^\n]*$/s, '')
      .replace(/\n###[^\n]*$/s, '')
      .trim();
    const name = stripBold(mm.name).trim();
    seen.add(name.toLowerCase());
    rules.push({ name, body: stripBold(body) });
  }

  for (let i = 0; i < lines.length; i++) {
    const h3 = lines[i].match(/^###\s+(.+?)\s*$/);
    if (!h3) continue;
    const headerName = stripBold(h3[1]).replace(/["“”]/g, '').trim();
    if (!/^The\b.*\b(Rule|Fallback|Principle)\b/i.test(headerName)) continue;
    if (seen.has(headerName.toLowerCase())) continue;

    const bodyLines = [];
    for (let j = i + 1; j < lines.length; j++) {
      if (/^##\s|^###\s/.test(lines[j])) break;
      bodyLines.push(lines[j]);
    }
    const body = stripBold(bodyLines.join('\n').replace(/\n+/g, ' ')).trim();
    if (body) {
      seen.add(headerName.toLowerCase());
      rules.push({ name: headerName, body });
    }
  }

  for (const b of collectBullets(lines)) {
    const mm = b.match(/^\*\*([^*]+?)\*\*\s*(.+)$/);
    if (!mm) continue;
    const nameRaw = mm[1].replace(/[.:]\s*$/, '').replace(/["“”]/g, '').trim();
    if (!/^The\b.+\b(Rule|Fallback|Principle)$/i.test(nameRaw)) continue;
    if (seen.has(nameRaw.toLowerCase())) continue;
    seen.add(nameRaw.toLowerCase());
    rules.push({ name: nameRaw, body: stripBold(mm[2]).trim() });
  }

  return rules;
}

// ---------- Per-section extractors ----------

function extractOverview(section) {
  if (!section) return null;
  const text = section.lines.join('\n');
  const northStar = text.match(/\*\*Creative North Star:\s*"([^"]+)"\*\*/);
  const keyChars = [];
  const keyCharMatch = text.match(/\*\*Key Characteristics:\*\*\s*\n([\s\S]+?)(?:\n##|\n###|$)/);
  if (keyCharMatch) {
    for (const line of keyCharMatch[1].split('\n')) {
      const m = line.match(/^\s*[-*]\s+(.+)$/);
      if (m) keyChars.push(stripBold(m[1].trim()));
    }
  }

  const paragraphs = collectParagraphs(section.lines).filter(
    (p) =>
      !p.startsWith('**Creative North Star') &&
      !p.startsWith('**Key Characteristics')
  );

  return {
    subtitle: section.subtitle,
    creativeNorthStar: northStar ? northStar[1] : null,
    philosophy: paragraphs,
    keyCharacteristics: keyChars,
  };
}

function extractColors(section) {
  if (!section) return null;
  const subs = splitSubsections(section.lines);

  const description = collectParagraphs(subs[0].lines).join(' ');
  const groups = [];
  const ROLE_KEYWORDS = /^(primary|secondary|tertiary|neutral|accent|background|surface|label|fill|separator|tint)\b/i;

  for (const sub of subs.slice(1)) {
    if (!sub.name || /Named Rules?/i.test(sub.name) || /^The\s/i.test(sub.name)) continue;

    const bullets = collectBullets(sub.lines);
    const parsed = bullets.map((b) => parseColorBullet(b)).filter(Boolean);
    if (parsed.length === 0) continue;

    const allRoleBullets =
      parsed.length > 0 && parsed.every((p) => p.name && ROLE_KEYWORDS.test(p.name));

    if (allRoleBullets) {
      for (const p of parsed) {
        groups.push({ role: p.name, colors: [p] });
      }
    } else {
      groups.push({ role: sub.name, colors: parsed });
    }
  }

  if (groups.length === 0) {
    const flat = collectBullets(section.lines)
      .map((b) => parseColorBullet(b))
      .filter(Boolean);
    if (flat.length) {
      for (const p of flat) {
        if (p.name && ROLE_KEYWORDS.test(p.name)) {
          groups.push({ role: p.name, colors: [p] });
        } else {
          const fallback = groups.find((g) => g.role === 'Palette');
          if (fallback) fallback.colors.push(p);
          else groups.push({ role: 'Palette', colors: [p] });
        }
      }
    }
  }

  return {
    subtitle: section.subtitle,
    description: description || null,
    groups,
    rules: extractNamedRules(section.lines),
  };
}

function parseColorBullet(bullet) {
  const text = bullet.trim();

  // Case 1 (Impeccable): **Name** (value-with-maybe-nested-parens): description
  const bold = text.match(/^\*\*(.+?)\*\*\s*(.*)$/);
  if (bold && bold[2].startsWith('(')) {
    const value = extractParenGroup(bold[2]);
    if (value !== null) {
      const after = bold[2].slice(value.length + 2).trimStart();
      if (after.startsWith(':')) {
        return buildColor(bold[1], value, after.slice(1).trim());
      }
    }
  }

  // Case 2 (Stitch): **Name (values):** description
  const stitch = text.match(/^\*\*([^*]+?)\s*\(([^)]+)\):\*\*\s*(.*)$/);
  if (stitch) {
    return buildColor(stitch[1].trim(), stitch[2], stitch[3]);
  }

  // Case 3: bullet without bold, just hex/oklch/asset-catalog inside.
  const values = collectColorValues(text);
  if (values.length) {
    return buildColor(null, values.join(' to '), text);
  }
  return null;
}

function extractParenGroup(s) {
  if (s[0] !== '(') return null;
  let depth = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === '(') depth++;
    else if (s[i] === ')') {
      depth--;
      if (depth === 0) return s.slice(1, i);
    }
  }
  return null;
}

function buildColor(name, rawValue, description) {
  const values = collectColorValues(rawValue);
  const primary = values[0] ?? rawValue.trim();
  return {
    name: name ? stripBold(name).trim() : null,
    value: primary,
    valueRange: values.length > 1 ? values : null,
    format: detectFormat(primary),
    description: stripBold(description || '').trim() || null,
  };
}

function collectColorValues(s) {
  const out = [];
  s.replace(HEX_RE, (v) => { out.push(v); return v; });
  s.replace(OKLCH_RE, (v) => { out.push(v); return v; });
  s.replace(ASSET_CATALOG_RE, (v) => { out.push(v); return v; });
  s.replace(COLOR_LITERAL_RE, (v, name) => {
    out.push(`Color("${name}")`);
    return v;
  });
  return out;
}

function detectFormat(v) {
  if (!v) return 'unknown';
  if (v.startsWith('#')) return 'hex';
  if (/^oklch/i.test(v)) return 'oklch';
  if (/^rgb/i.test(v)) return 'rgb';
  if (/^Colors\//.test(v) || /^AssetCatalog:/.test(v) || /^Color\(".+"\)$/.test(v)) {
    return 'asset-catalog';
  }
  return 'unknown';
}

function extractTypography(section) {
  if (!section) return null;
  const text = section.lines.join('\n');

  const fonts = {};
  // Pattern A: **Display Font:** Family (with fallback)
  const fontLineRe = /\*\*([\w\s/]+?)Font:\*\*\s*([^\n(]+?)(?:\s*\(with\s+([^)]+)\))?\s*$/gm;
  let fm;
  while ((fm = fontLineRe.exec(text)) !== null) {
    const rawRole = fm[1].trim().toLowerCase().replace(/\s+/g, '-');
    const role = normalizeFontRole(rawRole) || 'display';
    const family = fm[2].trim();
    fonts[role] = {
      family,
      fallback: fm[3] ? fm[3].trim() : null,
      system: isSystemFontFamily(family),
    };
  }

  // Pattern B (Stitch): *   **Display & Headlines (Noto Serif):** description
  if (Object.keys(fonts).length === 0) {
    const stitchRe = /\*\*([\w\s&/]+?)\s*\(([^)]+)\):\*\*\s*(.+)/g;
    let sm;
    while ((sm = stitchRe.exec(text)) !== null) {
      const rawRole = sm[1]
        .trim()
        .toLowerCase()
        .replace(/\s*&\s*/g, '-')
        .replace(/\s+/g, '-');
      const role = normalizeFontRole(rawRole) || rawRole;
      const family = sm[2].trim();
      fonts[role] = {
        family,
        fallback: null,
        purpose: sm[3].trim(),
        system: isSystemFontFamily(family),
      };
    }
  }

  const characterMatch = text.match(/\*\*Character:\*\*\s*([^\n]+(?:\n[^\n]+)*?)(?=\n\n|\n###|\n##|$)/);
  let character = characterMatch ? characterMatch[1].replace(/\n/g, ' ').trim() : null;
  if (!character) {
    const paragraphs = collectParagraphs(section.lines).filter(
      (p) => !/^\*\*[\w\s/&]+Font/i.test(p) && !/^\*\*[\w\s/&]+\([^)]+\)/.test(p)
    );
    if (paragraphs.length) character = paragraphs[0];
  }

  const subs = splitSubsections(section.lines);
  let hierarchy = [];
  const hierSub = subs.find((s) => s.name && /hierarch/i.test(s.name));
  if (hierSub) {
    const bullets = collectBullets(hierSub.lines);
    hierarchy = bullets.map(parseTypeBullet).filter(Boolean);
  }

  return {
    subtitle: section.subtitle,
    fonts,
    character,
    hierarchy,
    rules: extractNamedRules(section.lines),
  };
}

function isSystemFontFamily(family) {
  if (!family) return false;
  const trimmed = family.trim();
  for (const f of SYSTEM_FONT_FAMILIES) {
    if (trimmed.toLowerCase() === f.toLowerCase()) return true;
    // Allow `SF Pro Display` to match `SF Pro` prefix too.
    if (trimmed.toLowerCase().startsWith(f.toLowerCase() + ' ')) return true;
  }
  return /^\.system\b|^Font\.system\b/i.test(trimmed);
}

function normalizeFontRole(raw) {
  // Canonical roles: display, body, label, mono. Stitch often writes compound
  // roles like "display-&-headlines"; collapse to first canonical role present.
  const tokens = raw.split(/[-/&\s]+/).filter(Boolean);
  const priority = ['display', 'headline', 'body', 'ui', 'label', 'mono'];
  const canonical = { headline: 'display', ui: 'body' };
  for (const p of priority) {
    if (tokens.includes(p)) return canonical[p] || p;
  }
  return null;
}

function parseTypeBullet(bullet) {
  // - **Display** (family, weight 300, italic, clamp(...), line-height 1): purpose
  const m = bullet.match(/^\*\*(.+?)\*\*\s*\(([^)]+)\):\s*(.*)$/);
  if (!m) return null;
  const name = m[1].trim();
  const specs = m[2].split(',').map((s) => s.trim());
  const dynamicTypeTier = detectDynamicTypeTier(name, specs);
  const out = {
    name,
    specs,
    purpose: stripBold(m[3] || '').trim() || null,
  };
  if (dynamicTypeTier) out.dynamicType = dynamicTypeTier;
  return out;
}

function detectDynamicTypeTier(name, specs) {
  const candidates = [name, ...specs].map((s) =>
    String(s).toLowerCase().replace(/^\.font\(\.?/, '').replace(/[^a-z0-9]/g, '')
  );
  for (const c of candidates) {
    if (DYNAMIC_TYPE_TIERS.has(c)) return c;
  }
  return null;
}

function extractElevation(section) {
  if (!section) return null;
  const subs = splitSubsections(section.lines);

  const description = collectParagraphs(subs[0].lines).join(' ') || null;

  const shadows = [];
  const seen = new Set();
  const dedupe = (entry) => {
    const key = (entry.name || '') + '::' + entry.value;
    if (seen.has(key)) return;
    seen.add(key);
    shadows.push(entry);
  };

  for (const b of collectBullets(section.lines)) {
    const parsed = parseShadowBullet(b);
    if (parsed) dedupe(parsed);
  }

  for (const p of collectParagraphs(section.lines)) {
    for (const inline of extractInlineShadows(p)) dedupe(inline);
  }
  for (const b of collectBullets(section.lines)) {
    for (const inline of extractInlineShadows(b)) dedupe(inline);
  }

  // Swift adaptation: harvest Materials referenced anywhere in the section.
  const materialsSeen = new Set();
  const materials = [];
  const scanLines = section.lines.join('\n');
  let mm;
  MATERIAL_RE.lastIndex = 0;
  while ((mm = MATERIAL_RE.exec(scanLines)) !== null) {
    const token = canonicalMaterial(mm[1]);
    if (materialsSeen.has(token)) continue;
    materialsSeen.add(token);
    materials.push({ token, kind: token.startsWith('.') ? 'material' : 'liquid-glass' });
  }

  return {
    subtitle: section.subtitle,
    description,
    shadows,
    materials,
    rules: extractNamedRules(section.lines),
  };
}

function canonicalMaterial(raw) {
  const t = raw.trim();
  if (/liquid\s*glass/i.test(t)) return 'LiquidGlass';
  if (/^liquidglass$/i.test(t)) return 'LiquidGlass';
  return t;
}

function extractInlineShadows(text) {
  const out = [];
  const re = /box-shadow\s*:\s*([^`;\n]+)/gi;
  let m;
  while ((m = re.exec(text)) !== null) {
    const value = m[1].replace(/[`.)]+$/, '').trim();
    if (!value) continue;
    const before = text.slice(0, m.index);
    const nameMatch = before.match(/\b([A-Za-z][A-Za-z\- ]{2,40})\s+shadow\b[^A-Za-z0-9]*$/i);
    let name = null;
    if (nameMatch) {
      const stripped = nameMatch[1]
        .replace(/^(?:use|using|apply|applying|is|are|looks? like)\s+/i, '')
        .replace(/^(?:a|an|the)\s+/i, '')
        .trim();
      if (stripped) {
        name = stripped.charAt(0).toUpperCase() + stripped.slice(1) + ' shadow';
      }
    }
    out.push({ name, value, purpose: null });
  }

  // Also recognize SwiftUI-style `.shadow(color:.., radius:.., x:.., y:..)`.
  const swiftShadowRe = /\.shadow\(([^)]+)\)/gi;
  let sm;
  while ((sm = swiftShadowRe.exec(text)) !== null) {
    const value = sm[1].trim();
    out.push({ name: null, value: `.shadow(${value})`, purpose: null });
  }
  return out;
}

function parseShadowBullet(bullet) {
  // - **Name** (`box-shadow: value`): purpose  /  - **Name** (`value`): purpose
  // - **Name** (`.shadow(...)`): purpose       (Swift form)
  const m = bullet.match(/^\*\*(.+?)\*\*\s*\(`?([^`]+?)`?\):\s*(.*)$/);
  if (!m) return null;
  const rawValue = m[2].replace(/^box-shadow:\s*/i, '').trim();
  const looksLikeShadow =
    /box-shadow|\.shadow\(|rgba?\(|\bpx\b|\bpt\b|\brem\b|^-?\d+\s/i.test(rawValue) &&
    /\d/.test(rawValue);
  if (!looksLikeShadow) return null;
  const name = stripBold(m[1]).trim();
  return {
    name,
    value: rawValue,
    purpose: stripBold(m[3] || '').trim() || null,
  };
}

function extractComponents(section) {
  if (!section) return null;
  const subs = splitSubsections(section.lines);
  const components = [];

  for (const sub of subs.slice(1)) {
    if (!sub.name) continue;

    const bullets = collectBullets(sub.lines);
    const paragraphs = collectParagraphs(sub.lines);

    const variants = [];
    const properties = {};

    for (const b of bullets) {
      const m = b.match(/^\*\*(.+?):?\*\*:?\s*(.+)$/);
      if (m) {
        const key = stripBold(m[1]).trim();
        const value = stripBold(m[2]).trim();
        if (/^(primary|secondary|tertiary|ghost|hover|focus|active|disabled|default|error|selected|unselected|state)$/i.test(key.split(/[\s/]/)[0])) {
          variants.push({ name: key, description: value });
        } else {
          properties[key.toLowerCase()] = value;
        }
      }
    }

    components.push({
      name: sub.name,
      description: paragraphs.join(' ') || null,
      properties,
      variants,
    });
  }

  return {
    subtitle: section.subtitle,
    components,
  };
}

function extractDosDonts(section) {
  if (!section) return null;
  const subs = splitSubsections(section.lines);
  const dos = [];
  const donts = [];

  for (const sub of subs.slice(1)) {
    if (!sub.name) continue;
    const subName = normalizeApostrophes(sub.name);
    const bullets = collectBullets(sub.lines).map((b) => stripBold(b).trim());
    if (/^do'?t?:?$/i.test(subName) || /^do:?$/i.test(subName)) {
      dos.push(...bullets);
    } else if (/^don'?t:?$/i.test(subName)) {
      donts.push(...bullets);
    }
  }

  for (const b of collectBullets(section.lines)) {
    const stripped = normalizeApostrophes(stripBold(b).trim());
    if (/^don'?t\b/i.test(stripped)) {
      if (!donts.some((d) => normalizeApostrophes(d) === stripped)) donts.push(stripped);
    } else if (/^do\b/i.test(stripped)) {
      if (!dos.some((d) => normalizeApostrophes(d) === stripped)) dos.push(stripped);
    }
  }

  return { dos, donts };
}

// ---------- Coverage assessment ----------

function assessCoverage(model) {
  const report = {};

  report.overview = model.overview
    ? {
        northStar: Boolean(model.overview.creativeNorthStar),
        philosophy: model.overview.philosophy.length > 0,
        keyCharacteristics: model.overview.keyCharacteristics.length,
      }
    : 'missing';

  report.colors = model.colors
    ? {
        groups: model.colors.groups.length,
        totalColors: model.colors.groups.reduce((n, g) => n + g.colors.length, 0),
        assetCatalogColors: model.colors.groups.reduce(
          (n, g) => n + g.colors.filter((c) => c.format === 'asset-catalog').length,
          0
        ),
        rules: model.colors.rules.length,
      }
    : 'missing';

  report.typography = model.typography
    ? {
        fonts: Object.keys(model.typography.fonts).length,
        systemFonts: Object.values(model.typography.fonts).filter((f) => f.system).length,
        hierarchyEntries: model.typography.hierarchy.length,
        dynamicTypeEntries: model.typography.hierarchy.filter((h) => h.dynamicType).length,
        character: Boolean(model.typography.character),
        rules: model.typography.rules.length,
      }
    : 'missing';

  report.elevation = model.elevation
    ? {
        shadows: model.elevation.shadows.length,
        materials: model.elevation.materials ? model.elevation.materials.length : 0,
        rules: model.elevation.rules.length,
        description: Boolean(model.elevation.description),
      }
    : 'missing';

  report.components = model.components
    ? {
        count: model.components.components.length,
        variantTotal: model.components.components.reduce((n, c) => n + c.variants.length, 0),
      }
    : 'missing';

  report.dosDonts = model.dosDonts
    ? {
        dos: model.dosDonts.dos.length,
        donts: model.dosDonts.donts.length,
      }
    : 'missing';

  return report;
}

// ---------- Main ----------

export function parseDesignMd(md) {
  const { frontmatter, body } = parseFrontmatter(md);
  const { title, sections, seenH2 } = splitSections(body);

  const overview = extractOverview(sections['Overview']);
  const colors = extractColors(sections['Colors']);
  const typography = extractTypography(sections['Typography']);
  const elevation = extractElevation(sections['Elevation']);
  const components = extractComponents(sections['Components']);
  const dosDonts = extractDosDonts(sections["Do's and Don'ts"]);

  const present = new Set(Object.keys(sections));
  const unparsedSections = seenH2.filter((h) => !matchCanonicalSection(h));
  const missingCanonical = CANONICAL_SECTIONS.filter((c) => !present.has(c));

  return {
    schemaVersion: 2,
    platform: 'swift',
    units: { spacing: 'pt', spacingScale: [4, 8, 12, 16, 20, 24, 32, 40, 48, 64], typography: 'pt' },
    title,
    frontmatter,
    overview,
    colors,
    typography,
    elevation,
    components,
    dosDonts,
    unparsed_sections: unparsedSections,
    missing_sections: missingCanonical,
  };
}

export { assessCoverage };

// ---------------------------------------------------------------------------
// CLI mode — parse a DESIGN.md path and print the model as JSON
// ---------------------------------------------------------------------------

function cli() {
  const args = process.argv.slice(2);
  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    console.error('Usage: node design-parser.mjs <path-to-design.md> [--coverage]');
    process.exit(args.length === 0 ? 1 : 0);
  }

  const wantCoverage = args.includes('--coverage');
  const target = args.find((a) => !a.startsWith('--'));
  if (!target) {
    console.error('Usage: node design-parser.mjs <path-to-design.md> [--coverage]');
    process.exit(1);
  }

  const abs = path.resolve(process.cwd(), target);
  if (!fs.existsSync(abs)) {
    console.error(`design-parser: file not found: ${abs}`);
    process.exit(1);
  }

  const md = fs.readFileSync(abs, 'utf-8');
  const model = parseDesignMd(md);
  const out = wantCoverage ? { model, coverage: assessCoverage(model) } : model;
  console.log(JSON.stringify(out, null, 2));
}

const _running = process.argv[1];
if (_running?.endsWith('design-parser.mjs') || _running?.endsWith('design-parser.mjs/')) {
  cli();
}
