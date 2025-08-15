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
  const sorted: Record<string, ParamInfo> = {};
  for (const k of Object.keys(params).sort()) sorted[k] = params[k];
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

async function main() {
  const files = await glob('actions/*.ps1');
  const registry: Record<string, FuncInfo> = {};
  for (const file of files) {
    const content = await fs.readFile(file, 'utf8');
    const regex = /function\s+(\w+)\s*\{[\s\S]*?param\(([^\)]*)\)/gi;
    let match: RegExpExecArray | null;
    while ((match = regex.exec(content)) !== null) {
      const fn = match[1];
      const paramsBlock = match[2];
      const description = extractDescription(content, match.index);
      registry[fn] = { description, parameters: parseParams(paramsBlock) };
    }
  }
  const sorted: Record<string, FuncInfo> = {};
  for (const fn of Object.keys(registry).sort()) sorted[fn] = registry[fn];
  await fs.writeFile('dispatchers.json', JSON.stringify(sorted, null, 2));
}

main().catch(err => { console.error(err); process.exit(1); });
