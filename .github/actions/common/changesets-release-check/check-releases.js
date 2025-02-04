#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

function checkDependencies() {
  try {
    execSync('jq --version', { stdio: 'ignore' });
  } catch (error) {
    console.error('Error: jq is required but not installed');
    process.exit(1);
  }
}

function getPackagesToRelease() {
  try {
    const output = execSync('npx changeset status --json', { encoding: 'utf-8' });
    const status = JSON.parse(output);
    return status.releases
      .filter(release => release.type !== 'none')
      .map(release => release.name)
      .filter(Boolean);
  } catch (error) {
    console.error('Error getting release packages:', error.message);
    return [];
  }
}

function createPublishScript(packages) {
  const batchSize = 10;
  const delaySeconds = 10;
  const tempFile = path.join(os.tmpdir(), `publish-${Date.now()}.sh`);
  
  const scriptContent = `#!/bin/bash
set -euo pipefail

# Publish packages in batches
echo 'Starting package publishing...'

${packages
  .reduce((batches, pkg, i) => {
    const batchIndex = Math.floor(i / batchSize);
    if (!batches[batchIndex]) batches[batchIndex] = [];
    batches[batchIndex].push(pkg);
    return batches;
  }, [])
  .map(batch => `
echo 'Publishing batch...'
npx changeset publish --tag latest
echo 'Waiting ${delaySeconds}s before next batch...'
sleep ${delaySeconds}`)
  .join('\n')}

echo 'All packages published successfully!'
`;

  fs.writeFileSync(tempFile, scriptContent, { mode: 0o755 });
  return tempFile;
}

function main() {
  checkDependencies();
  
  const packages = getPackagesToRelease();
  
  if (packages.length > 0) {
    const publishScript = createPublishScript(packages);
    console.log(`::set-output name=publish::${publishScript}`);
    console.log(`::set-output name=packages::${packages.join('\n')}`);
  } else {
    console.log('::set-output name=publish::false');
    console.log('::set-output name=packages::');
  }
}

main();