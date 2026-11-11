#!/usr/bin/env node
// Trava de build: confere se o bundle do Rocket.Chat e a release esperada.
// Uso: node verify-bundle.js <bundle_dir> <RC_VERSION> [<commit_esperado>]
// Falha (exit 1) se Info.version != RC_VERSION, commit.tag != RC_VERSION,
// commit.branch == 'develop' ou, quando informado, commit.hash nao comecar com o esperado.
const fs = require('fs');
const path = require('path');

const [bundleDir, expectedVersion, expectedCommit] = process.argv.slice(2);
if (!bundleDir || !expectedVersion) {
	console.error('Uso: verify-bundle.js <bundle_dir> <RC_VERSION> [<commit_esperado>]');
	process.exit(2);
}

const appJs = path.join(bundleDir, 'programs/server/app/app.js');
const src = fs.readFileSync(appJs, 'utf8');
const start = src.indexOf('exports.Info = {');
if (start < 0) {
	console.error(`FALHA: bloco Info nao encontrado em ${appJs}`);
	process.exit(1);
}
const open = src.indexOf('{', start);
const end = src.indexOf('\n};', open);
let info;
try {
	info = JSON.parse(src.slice(open, end + 2));
} catch (e) {
	console.error(`FALHA: bloco Info ilegivel: ${e.message}`);
	process.exit(1);
}

const commit = info.commit || {};
console.log(`Info.version=${info.version} commit.hash=${commit.hash} commit.tag=${commit.tag} commit.branch=${commit.branch}`);

const errors = [];
if (info.version !== expectedVersion) errors.push(`Info.version=${info.version} diferente de RC_VERSION=${expectedVersion}`);
if (commit.tag !== expectedVersion) errors.push(`commit.tag=${commit.tag} diferente de RC_VERSION=${expectedVersion}`);
if (commit.branch === 'develop') errors.push('commit.branch=develop (build de desenvolvimento)');
if (expectedCommit && !String(commit.hash || '').startsWith(expectedCommit)) errors.push(`commit.hash=${commit.hash} nao comeca com ${expectedCommit}`);

if (errors.length) {
	errors.forEach((e) => console.error(`FALHA: ${e}`));
	process.exit(1);
}
console.log('OK: bundle confere com a release esperada');
