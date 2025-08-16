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
}
