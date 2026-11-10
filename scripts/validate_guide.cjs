const { chromium } = require('C:/Users/SENAI/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const { pathToFileURL } = require('node:url');
const path = require('node:path');
const fs = require('node:fs');
(async () => {
  const root = path.resolve(__dirname, '..');
  const browser = await chromium.launch({
    executablePath: 'C:/Users/SENAI/Downloads/#08_Desenv_App_Moveis_Projeto Teste (1)/video-hyperframes/.cache/browser/chrome-headless-shell/win64-158.0.8126.0/chrome-headless-shell-win64/chrome-headless-shell.exe',
    headless: true
  });
  try {
    const page = await browser.newPage({ viewport: { width: 1360, height: 900 } });
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(pathToFileURL(path.join(root, 'estudo', 'CODIGO_EXPLICADO.html')).href);
    const options = await page.locator('#file option').count();
    if (options !== 26) throw new Error('Quantidade inesperada de arquivos');
    await page.locator('#next').click();
    if (!(await page.locator('#heading').textContent()).includes('linha 2')) throw new Error('Botao proxima falhou');
    await page.locator('#search').fill('await');
    const matches = await page.locator('#lines button').count();
    if (!matches) throw new Error('Busca sem resultado');
    await page.locator('#lines button').first().click();
    if (!(await page.locator('#selected').textContent()).includes('await')) throw new Error('Selecao incorreta');
    await page.selectOption('#file', '1');
    await page.locator('#lines button').nth(10).click();
    await page.screenshot({path:path.join(root,'evidencias','13_guia_codigo.png'),fullPage:true});
    if (errors.length) throw new Error(errors.join('; '));
    const result={files:options,search_matches:matches,selection:true,navigation:true,page_errors:errors};
    fs.writeFileSync(path.join(root,'evidencias','guide_checks.json'), JSON.stringify(result,null,2));
    console.log(JSON.stringify(result));
  } finally { await browser.close(); }
})().catch(error=>{console.error(error);process.exitCode=1});

