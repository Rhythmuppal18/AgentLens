
import lighthouse from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';

async function run() {
  const chrome = await chromeLauncher.launch({
    chromeFlags: ['--headless', '--disable-gpu', '--no-sandbox']
  });

  const res = await lighthouse('http://localhost:4175', {
    port: chrome.port,
    output: 'json',
  }, {
    extends: 'lighthouse:default',
    settings: { formFactor: 'mobile' }
  });

  const aContrast = res.lhr.audits['color-contrast'];
  if (aContrast && aContrast.details && aContrast.details.items) {
    console.log("=== CONTRAST FAILS ===");
    for (const item of aContrast.details.items) {
      console.log(item.node.snippet, "-> foreground:", item.node.explanation);
    }
  }

  const aMismatch = res.lhr.audits['label-content-name-mismatch'];
  if (aMismatch && aMismatch.details && aMismatch.details.items) {
    console.log("=== LABEL MISMATCH ===");
    for (const item of aMismatch.details.items) {
      console.log(item.node.snippet);
    }
  }

  const aErrors = res.lhr.audits['errors-in-console'];
  if (aErrors && aErrors.details && aErrors.details.items) {
    console.log("=== CONSOLE ERRORS ===");
    for (const item of aErrors.details.items) {
      console.log(item.description);
    }
  }

  await chrome.kill();
}
run();
