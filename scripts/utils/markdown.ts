export function escapeMarkdown(text: string): string {
  return text.replace(/[|`*_\[\]]/g, '\\$&');
}

export function buildTable(header: string[], rows: string[][]): string {
  const head = `| ${header.map(escapeMarkdown).join(' | ')} |`;
  const sep = `| ${header.map(() => '---').join(' | ')} |`;
  const body = rows.map(r => `| ${r.map(c => escapeMarkdown(c)).join(' | ')} |`);
  return [head, sep, ...body].join('\n');
}
