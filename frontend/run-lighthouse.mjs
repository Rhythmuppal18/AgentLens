
import lighthouse from 'lighthouse';
import * as chromeLauncher from 'chrome-launcher';

async function run() {
  const chrome = await chromeLauncher.launch({
    chromeFlags: ['--headless', '--disable-gpu', '--no-sandbox']
  });

  // Desktop run
  const resDesktop = await lighthouse('http://localhost:4173', {
    port: chrome.port,
    output: 'json',
    onlyCategories: ['performance', 'accessibility', 'best-practices', 'seo'],
  }, {
    extends: 'lighthouse:default',
    settings: {
      formFactor: 'desktop',
      screenEmulation: {
        mobile: false,
        width: 1350,
        height: 940,
        deviceScaleFactor: 1,
        disabled: false,
      },
      throttling: {
        rttMs: 40,
        throughputKbps: 10240,
        cpuSlowdownMultiplier: 1,
      }
    }
  });

  const dScores = {
    performance: Math.round(resDesktop.lhr.categories.performance.score * 100),
    accessibility: Math.round(resDesktop.lhr.categories.accessibility.score * 100),
    bestPractices: Math.round(resDesktop.lhr.categories['best-practices'].score * 100),
    seo: Math.round(resDesktop.lhr.categories.seo.score * 100),
  };
  console.log("=== DESKTOP LIGHTHOUSE SCORES ===", JSON.stringify(dScores));

  // Mobile run
  const resMobile = await lighthouse('http://localhost:4173', {
    port: chrome.port,
    output: 'json',
    onlyCategories: ['performance', 'accessibility', 'best-practices', 'seo'],
  }, {
    extends: 'lighthouse:default',
    settings: {
      formFactor: 'mobile',
    }
  });

  const mScores = {
    performance: Math.round(resMobile.lhr.categories.performance.score * 100),
    accessibility: Math.round(resMobile.lhr.categories.accessibility.score * 100),
    bestPractices: Math.round(resMobile.lhr.categories['best-practices'].score * 100),
    seo: Math.round(resMobile.lhr.categories.seo.score * 100),
  };
  console.log("=== MOBILE LIGHTHOUSE SCORES ===", JSON.stringify(mScores));

  await chrome.kill();
}

run().catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
