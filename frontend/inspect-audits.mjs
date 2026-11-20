
import lighthouse from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';

async function run() {
  const chrome = await chromeLauncher.launch({
    chromeFlags: ['--headless', '--disable-gpu', '--no-sandbox']
  });

  const res = await lighthouse('http://localhost:4173', {
    port: chrome.port,
    output: 'json',
  }, {
    extends: 'lighthouse:default',
    settings: { formFactor: 'mobile' }
  });

  const audits = res.lhr.audits;
  for (const [key, a] of Object.entries(audits)) {
    if (a.score !== null && a.score < 1 && a.details) {
      console.log(`FAIL [${key}]: ${a.title} (score: ${a.score})`);
    }
  }

  await chrome.kill();
}
run();
