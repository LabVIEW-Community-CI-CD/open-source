import fs from 'fs/promises';
import { writeErrorSummary } from '../error-handler.ts';
import { TestCase, RequirementGroup } from './index.ts';

export interface RunnerDefaults {
  owner?: string;
  runner_label?: string;
  runner_type?: string;
  skip_dry_run?: boolean;
}

export interface RequirementEntry extends RunnerDefaults {
  id: string;
  description?: string;
  runner?: string;
  tests: string[];
}

interface RequirementsFile {
  runners?: Record<string, RunnerDefaults>;
  defaults?: Record<string, RunnerDefaults>;
  requirements?: unknown;
}

export function redact(text: string): string {
  return text.replace(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+/g, '<redacted>');
}

function isRunnerDefaults(value: unknown): value is RunnerDefaults {
  if (!value || typeof value !== 'object') return false;
  const v = value as Record<string, unknown>;
  if ('owner' in v && typeof v.owner !== 'string') return false;
  if ('runner_label' in v && typeof v.runner_label !== 'string') return false;
  if ('runner_type' in v && typeof v.runner_type !== 'string') return false;
  if ('skip_dry_run' in v && typeof v.skip_dry_run !== 'boolean') return false;
  return true;
}

function isRequirementEntry(value: unknown): value is RequirementEntry {
  if (!value || typeof value !== 'object') return false;
  const v = value as Record<string, unknown>;
  if (typeof v.id !== 'string') return false;
  if (!Array.isArray(v.tests) || !v.tests.every((t) => typeof t === 'string')) return false;
  if ('description' in v && typeof v.description !== 'string') return false;
  if ('runner' in v && typeof v.runner !== 'string') return false;
  if ('owner' in v && typeof v.owner !== 'string') return false;
  if ('runner_label' in v && typeof v.runner_label !== 'string') return false;
  if ('runner_type' in v && typeof v.runner_type !== 'string') return false;
  if ('skip_dry_run' in v && typeof v.skip_dry_run !== 'boolean') return false;
  return true;
}

export async function loadRequirements(mappingFile: string | string[]) {
  const files = Array.isArray(mappingFile) ? mappingFile : [mappingFile];
  const map: Record<string, { requirements: string[]; owner?: string }> = {};
  const meta: Record<string, { description?: string; owner?: string; runner_label?: string; runner_type?: string; skip_dry_run?: boolean }> = {};
  for (const file of files) {
    try {
      const raw = await fs.readFile(file, 'utf8');
      const parsed: RequirementsFile = JSON.parse(raw);

      const defaults: Record<string, RunnerDefaults> = {};
      const rawDefs = (parsed.runners || parsed.defaults) ?? {};
      if (rawDefs && typeof rawDefs === 'object') {
        for (const [name, val] of Object.entries(rawDefs)) {
          if (isRunnerDefaults(val)) {
            defaults[name] = val;
          } else {
            console.warn(`Invalid runner defaults for ${name}`);
          }
        }
      }

      if (Array.isArray(parsed.requirements)) {
        for (const r of parsed.requirements) {
          if (!isRequirementEntry(r)) {
            console.warn(`Invalid requirement entry: ${JSON.stringify(r)}`);
            continue;
          }
          const def = (r.runner && defaults[r.runner]) || {};
          const owner = r.owner ?? def.owner;
          const runner_label = r.runner_label ?? def.runner_label;
          const runner_type = r.runner_type ?? def.runner_type;
          const skip_dry_run = r.skip_dry_run ?? def.skip_dry_run;
          meta[r.id] = { description: r.description, owner, runner_label, runner_type, skip_dry_run };
          for (const t of r.tests) {
            const key = t.toLowerCase();
            if (!map[key]) map[key] = { requirements: [], owner };
            map[key].requirements.push(r.id);
          }
        }
      }
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      console.warn(`Failed to load requirements mapping from ${file}: ${msg}`);
      await writeErrorSummary(err);
    }
  }
  return { map, meta };
}

export function mapToRequirements(
  tests: TestCase[],
  mapping: Record<string, { requirements: string[]; owner?: string }>,
  meta: Record<string, { description?: string; owner?: string; runner_label?: string; runner_type?: string; skip_dry_run?: boolean }>,
): RequirementGroup[] {
  const groups: Map<string, RequirementGroup> = new Map();
  for (const test of tests) {
    const stripAnnotations = (s: string) => s.replace(/\[[^\]]+\]/g, '').trim();
    const nameKey = stripAnnotations(test.name).toLowerCase();
    const classKey = test.className ? stripAnnotations(test.className).toLowerCase() : undefined;
    const mapped = mapping[nameKey] || (classKey ? mapping[classKey] : undefined);
    const reqs = mapped ? mapped.requirements : test.requirements;
    if (mapped && mapped.owner) test.owner = mapped.owner;
    if (!test.owner) {
      for (const r of reqs) {
        if (meta[r]?.owner) {
          test.owner = meta[r].owner;
          break;
        }
      }
    }
    const targetReqs = reqs.length ? reqs : ['Unmapped'];
    for (const reqId of targetReqs) {
      if (!groups.has(reqId)) {
        groups.set(reqId, {
          id: reqId,
          description: meta[reqId]?.description,
          owner: meta[reqId]?.owner,
          runner_label: meta[reqId]?.runner_label,
          runner_type: meta[reqId]?.runner_type,
          skip_dry_run: meta[reqId]?.skip_dry_run,
          tests: [],
        });
      }
      groups.get(reqId)!.tests.push(test);
    }
  }
  const statusRank: Record<string, number> = { Failed: 0, Passed: 1, Skipped: 2 };
  const sorted = Array.from(groups.values()).sort((a, b) => a.id.localeCompare(b.id, undefined, { numeric: true }));
  for (const g of sorted) {
    g.tests.sort((a, b) => {
      const diff = statusRank[a.status] - statusRank[b.status];
      if (diff !== 0) return diff;
      return a.name.localeCompare(b.name);
    });
  }
  return sorted;
}

