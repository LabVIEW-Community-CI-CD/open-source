export function buildIssueBranchName(issueNumber) {
  if (typeof issueNumber !== 'number') {
    throw new TypeError('issueNumber must be a number');
  }
  return `issue/${issueNumber}`;
}
