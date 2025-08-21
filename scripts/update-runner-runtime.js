const fs = require('fs');

const key = process.env.RUNNER_KEY;
const label = process.env.RUNNER_LABEL;
const type = process.env.RUNNER_TYPE;
const skipInput = process.env.SKIP_DRY_RUN;

const files = fs.readdirSync(process.cwd()).filter(f => f.startsWith('requirements') && f.endsWith('.json'));
const updated = [];
for (const file of files) {
  const json = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (json.runners && json.runners[key]) {
    if (label) json.runners[key].runner_label = label;
    if (type) json.runners[key].runner_type = type;
    if (skipInput) json.runners[key].skip_dry_run = skipInput === 'true';
    fs.writeFileSync(file, JSON.stringify(json, null, 2) + '\n');
    updated.push(file);
    console.log(`Updated ${file}`);
  }
}

if (updated.length === 0) {
  throw new Error(`Runner ${key} not found`);
}

const outputFile = process.env.GITHUB_OUTPUT || process.env.GITHUB_ENV;
if (outputFile) {
  fs.appendFileSync(outputFile, `req_files<<EOF\n${updated.join('\n')}\nEOF\n`);
}
