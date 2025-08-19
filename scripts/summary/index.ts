export interface TestCase {
  id: string;
  name: string;
  className?: string;
  status: 'Passed' | 'Failed' | 'Skipped';
  duration: number;
  owner?: string;
  evidence?: string;
  requirements: string[];
  os?: string;
}

export interface RequirementGroup {
  id: string;
  description?: string;
  owner?: string;
  runner_label?: string;
  runner_type?: string;
  skip_dry_run?: boolean;
  tests: TestCase[];
}

export function computeStatusCounts(tests: TestCase[]) {
  const counts = { total: tests.length, passed: 0, failed: 0, skipped: 0 };
  for (const t of tests) {
    if (t.status === 'Passed') counts.passed++;
    else if (t.status === 'Failed') counts.failed++;
    else counts.skipped++;
  }
  return counts;
}

export function buildSummary(groups: RequirementGroup[]) {
  const overall = { passed: 0, failed: 0, skipped: 0, duration: 0, rate: 0 };
  const byOs: Record<string, { passed: number; failed: number; skipped: number; duration: number; rate: number }> = {};
  for (const g of groups) {
    for (const t of g.tests) {
      const os = t.os || 'unknown';
      if (!byOs[os]) byOs[os] = { passed: 0, failed: 0, skipped: 0, duration: 0, rate: 0 };
      overall.duration += t.duration;
      byOs[os].duration += t.duration;
      if (t.status === 'Passed') { overall.passed++; byOs[os].passed++; }
      else if (t.status === 'Failed') { overall.failed++; byOs[os].failed++; }
      else { overall.skipped++; byOs[os].skipped++; }
    }
  }
  overall.rate = overall.passed + overall.failed === 0 ? 0 : (overall.passed / (overall.passed + overall.failed)) * 100;
  for (const os of Object.keys(byOs)) {
    const t = byOs[os];
    t.rate = t.passed + t.failed === 0 ? 0 : (t.passed / (t.passed + t.failed)) * 100;
  }
  return { overall, byOs };
}

export function summaryToMarkdown(totals: { overall: { passed: number; failed: number; skipped: number; duration: number; rate: number }; byOs: Record<string, { passed: number; failed: number; skipped: number; duration: number; rate: number }> }) {
  const header = ['OS', 'Passed', 'Failed', 'Skipped', 'Duration (s)', 'Pass Rate (%)'];
  const rows = [[
    'overall',
    `${totals.overall.passed}`,
    `${totals.overall.failed}`,
    `${totals.overall.skipped}`,
    totals.overall.duration.toFixed(2),
    totals.overall.rate.toFixed(2),
  ]];
  for (const os of Object.keys(totals.byOs).sort()) {
    const t = totals.byOs[os];
    rows.push([
      os,
      `${t.passed}`,
      `${t.failed}`,
      `${t.skipped}`,
      t.duration.toFixed(2),
      t.rate.toFixed(2),
    ]);
  }
  return ['### Test Summary', buildTable(header, rows)].join('\n');
}

export function requirementsSummaryToMarkdown(groups: RequirementGroup[]) {
  const header = ['Requirement ID', 'Description', 'Owner', 'Total Tests', 'Passed', 'Failed', 'Skipped', 'Pass Rate (%)'];
  const rows: string[][] = [];
  for (const g of groups) {
    const { total, passed, failed, skipped } = computeStatusCounts(g.tests);
    const rate = passed + failed === 0 ? 0 : (passed / (passed + failed)) * 100;
    rows.push([
      g.id,
      g.description ?? '',
      g.owner ?? '',
      `${total}`,
      `${passed}`,
      `${failed}`,
      `${skipped}`,
      rate.toFixed(2),
    ]);
  }
  return ['### Requirement Summary', buildTable(header, rows)].join('\n');
}

export function requirementTestsToMarkdown(groups: RequirementGroup[]) {
  const header = ['Requirement ID', 'Test ID', 'Status'];
  const rows: string[][] = [];
  for (const g of groups) {
    for (const t of g.tests) {
      rows.push([g.id, t.id, t.status]);
    }
  }
  return ['### Requirement Testcases', buildTable(header, rows)].join('\n');
}

export function groupToMarkdown(groups: RequirementGroup[], limit?: number) {
  const lines: string[] = [];
  let remaining = limit ?? Infinity;
  for (const g of groups) {
    const { total, passed } = computeStatusCounts(g.tests);
    const pct = total === 0 ? 0 : Math.round((passed / total) * 100);
    const heading = `${g.id} (${pct}% passed)`;
    const tblHeader = ['Requirement', 'Test ID', 'Status', 'Duration (s)', 'Owner', 'Evidence'];
    const rows: string[][] = [];
    for (const t of g.tests) {
      if (remaining <= 0) break;
      const evidence = t.evidence ? `[link](${t.evidence})` : '';
      rows.push([
        g.id,
        t.id,
        t.status,
        t.duration.toFixed(3),
        t.owner ?? g.owner ?? '',
        evidence,
      ]);
      remaining--;
    }
    const content = buildTable(tblHeader, rows);
    if (g.tests.length > 5) {
      lines.push(`<details><summary>${heading}</summary>\n\n${content}\n\n</details>`);
    } else {
      lines.push(`#### ${heading}\n\n${content}`);
    }
    if (remaining <= 0) break;
  }
  if (limit && remaining <= 0) lines.push('\n_Truncated. See traceability.md for full details._');
  return lines.join('\n\n');
}

import { buildTable } from '../utils/markdown.ts';

