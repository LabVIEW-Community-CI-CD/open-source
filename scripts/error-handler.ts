import fs from 'node:fs/promises';

export function formatError(err: unknown): string {
  if (err instanceof Error) {
    return err.stack ?? err.message;
  }
  if (err && typeof err === 'object') {
    const stack = (err as any).stack;
    if (typeof stack === 'string' && stack) return stack;
    try {
      return JSON.stringify(err);
    } catch {
      // ignore
    }
  }
  try {
    return String(err);
  } catch {
    return 'Unknown error';
  }
}

export async function writeErrorSummary(err: unknown): Promise<void> {
  console.error(`Error generating CI summary: ${formatError(err)}`);
  if (!(err instanceof Error)) return;
  const summaryPath = process.env.GITHUB_STEP_SUMMARY || 'error-summary.md';
  try {
    const formatted = `\n\n### Error generating CI summary\n\n\u0060\u0060\u0060\n${formatError(err)}\n\u0060\u0060\u0060\n`;
    await fs.appendFile(summaryPath, formatted, 'utf8');
  } catch (writeErr) {
    console.error(`Failed to write error summary: ${formatError(writeErr)}`);
    console.error('Error details not written to summary file. See logs for details.');
  }
}
