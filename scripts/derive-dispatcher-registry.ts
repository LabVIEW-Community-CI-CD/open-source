#!/usr/bin/env tsx
import fs from 'fs/promises';
import path from 'path';
import { glob } from 'glob';

interface ParamInfo {
  type: string;
  required: boolean;
  default?: string;
  description?: string;
}

interface FuncInfo {
  description?: string;
  parameters: Record<string, ParamInfo>;
}

function parseParams(block: string): Record<string, ParamInfo> {
  const params: Record<string, ParamInfo> = {};
  const lines = block.split(/\r?\n/).map(l => l.trim()).filter(Boolean);
  for (const line of lines) {
    const nameMatch = line.match(/\$(\w+)/);
    if (!nameMatch) continue;
    const name = nameMatch[1];
    let type = 'string';
    if (/\[switch\]/i.test(line)) type = 'boolean';
    else if (/\[int\]/i.test(line) || /\[double\]/i.test(line) || /\[float\]/i.test(line)) type = 'number';
    const required = /Mandatory\s*=\s*\$?true/i.test(line) || /Parameter\((?:(?!\)).*Mandatory\b)/i.test(line);
    const defMatch = line.match(/=\s*([^,]+)/);
    const defVal = defMatch ? defMatch[1].trim().replace(/^['"]|['"]$/g,'') : undefined;
    params[name] = { type, required, default: defVal, description: '' };
  }
  const collator = new Intl.Collator('en');
  const sorted: Record<string, ParamInfo> = {};
  for (const [k, v] of Object.entries(params).sort((a, b) => collator.compare(a[0], b[0]))) {
    sorted[k] = v;
  }
  return sorted;
}

function extractDescription(content: string, index: number): string {
  const lines = content.slice(0, index).split(/\r?\n/);
  let desc: string[] = [];
  for (let i = lines.length - 1; i >= 0; i--) {
    const line = lines[i].trim();
    if (line.startsWith('#')) desc.unshift(line.replace(/^#\s?/,''));
    else if (line === '') continue;
    else break;
  }
  return desc.join(' ');
}

function extractParamBlock(content: string, start: number): string | null {
  const rest = content.slice(start);
  const paramMatch = /\bparam\s*\(/i.exec(rest);
  if (!paramMatch) return null;
  const before = rest
    .slice(0, paramMatch.index)
    .split(/\r?\n/)
    .map(l => l.trim())
    .filter(l => l && !l.startsWith('#') && !l.startsWith('['));
  if (before.length > 0) return null;
  let idx = start + paramMatch.index + paramMatch[0].length;
  let depth = 1;
  let inSingle = false, inDouble = false, inComment = false;
  while (idx < content.length) {
    const ch = content[idx];
    const prev = content[idx - 1];
    if (inComment) {
      if (ch === '\n' || ch === '\r') inComment = false;
    } else if (!inDouble && ch === "'" && prev !== '`') {
      inSingle = !inSingle;
    } else if (!inSingle && ch === '"' && prev !== '`') {
      inDouble = !inDouble;
    } else if (!inSingle && !inDouble) {
      if (ch === '#') {
        inComment = true;
      } else if (ch === '(') {
        depth++;
      } else if (ch === ')') {
        depth--;
        if (depth === 0) {
          return content.slice(start + paramMatch.index + paramMatch[0].length, idx);
        }
      }
    }
    idx++;
  }
  return null;
}

async function main() {
  const files = await glob('actions/*.{ps1,psm1}');
  const registry: Record<string, FuncInfo> = {};
  for (const file of files) {
    const content = await fs.readFile(file, 'utf8');
    const fnRegex = /function\s+(\w+)\b/gi;
    let match: RegExpExecArray | null;
    while ((match = fnRegex.exec(content)) !== null) {
      const fn = match[1];
      const bodyStart = content.indexOf('{', fnRegex.lastIndex);
      if (bodyStart === -1) continue;
      const paramsBlock = extractParamBlock(content, bodyStart + 1);
      if (!paramsBlock) continue;
      const description = extractDescription(content, match.index);
      registry[fn] = { description, parameters: parseParams(paramsBlock) };
    }
  }
  const collator = new Intl.Collator('en');
  const sorted: Record<string, FuncInfo> = {};
  for (const fn of Object.keys(registry).sort(collator.compare)) sorted[fn] = registry[fn];
  await fs.writeFile('dispatchers.json', JSON.stringify(sorted, null, 2));
}

main().catch(err => { console.error(err); process.exit(1); });
