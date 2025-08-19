import fs from 'fs/promises';
import path from 'path';
import { pathToFileURL } from 'url';
import yaml from 'js-yaml';

export async function generateActionDocs(dispatcherRegistryFile: string, wrapperDirs: string[]) {
  const actionParams: any[] = [];

  let registry: any = null;
  try {
    const ext = path.extname(dispatcherRegistryFile);
    if (ext === '.json') {
      registry = JSON.parse(await fs.readFile(dispatcherRegistryFile, 'utf8'));
    } else {
      const mod = await import(pathToFileURL(path.resolve(dispatcherRegistryFile)).href);
      registry = mod.default ?? mod;
    }
  } catch {
    registry = null;
  }

  const wrappers: Record<string, any[]> = {};
  for (const dir of wrapperDirs) {
    const p = path.join(dir, 'action.yml');
    try {
      const y = yaml.load(await fs.readFile(p, 'utf8')) as any;
      const params = Object.entries(y.inputs || {}).map(([n, inf]: any) => ({
        name: n,
        description: inf.description || '',
        required: inf.required === true,
        default: inf.default ?? '',
        type: inf.type || 'string',
      }));
      wrappers[dir] = params;
    } catch {
      continue;
    }
  }

  const docs = { action: actionParams, dispatcher: registry, wrappers };
  const lines: string[] = ['### Parameters', '| Name | Type | Required | Default | Description |', '| --- | --- | --- | --- | --- |'];
  for (const p of actionParams) {
    lines.push(`| ${p.name} | ${p.type} | ${p.required} | ${p.default} | ${p.description} |`);
  }
  if (registry) {
    lines.push('\n### Dispatcher Functions');
    const fnNames = Object.keys(registry).sort();
    for (const fn of fnNames) {
      const info = registry[fn];
      lines.push(`\n#### ${fn}`);
      if (info.description) lines.push(info.description);
      const tbl = ['| Parameter | Type | Required | Default | Description |', '| --- | --- | --- | --- | --- |'];
      const paramNames = Object.keys(info.parameters || {}).sort();
      for (const pn of paramNames) {
        const p = info.parameters[pn];
        tbl.push(`| ${pn} | ${p.type} | ${p.required} | ${p.default ?? ''} | ${p.description ?? ''} |`);
      }
      lines.push(tbl.join('\n'));
      lines.push('\n```powershell');
      lines.push(`pwsh ./actions/Invoke-OSAction.ps1 -ActionName ${fn} -ArgsJson '{}'`);
      lines.push('```');
    }
  }
  if (Object.keys(wrappers).length) {
    lines.push('\n### Wrapper Actions');
    for (const [dir, params] of Object.entries(wrappers)) {
      lines.push(`\n#### ${dir}`);
      const tbl = ['| Name | Type | Required | Default | Description |', '| --- | --- | --- | --- | --- |'];
      for (const p of params) {
        tbl.push(`| ${p.name} | ${p.type} | ${p.required} | ${p.default} | ${p.description} |`);
      }
      lines.push(tbl.join('\n'));
    }
  }
  return { docs, markdown: lines.join('\n') };
}

