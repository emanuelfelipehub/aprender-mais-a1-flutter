"""Testes de sistema no emulador. Restaura bateria, rede, energia e sensores ao terminar."""
from pathlib import Path
import subprocess, time, re, json, xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
ADB = Path(r'C:\Users\SENAI\AppData\Local\Android\Sdk\platform-tools\adb.exe')
PACKAGE = 'br.com.aprendermais.aprender_a1'
OUT = ROOT / 'evidencias'
OUT.mkdir(exist_ok=True)
report = {}

def adb(*args, check=True):
    p = subprocess.run([str(ADB), '-s', 'emulator-5554', *args], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=35)
    if check and p.returncode:
        raise RuntimeError(p.stdout + p.stderr)
    return p.stdout.strip()

def shell(*args):
    return adb('shell', *args)

def tree():
    shell('uiautomator', 'dump', '/sdcard/a1_window.xml')
    text = shell('cat', '/sdcard/a1_window.xml')
    return ET.fromstring(text[text.index('<?xml'):])

def nodes(label=None):
    values = list(tree().iter('node'))
    if label is not None:
        values = [n for n in values if label in (n.get('text',''), n.get('content-desc',''))]
    return values

def tap(label):
    matches = nodes(label)
    if not matches:
        raise AssertionError('Controle ausente: ' + label)
    match = matches[-1]
    x1,y1,x2,y2 = map(int,re.findall(r'\d+',match.get('bounds')))
    shell('input','tap',str((x1+x2)//2),str((y1+y2)//2))
    time.sleep(.45)

def visible(text):
    return any(text in (n.get('text','')+' '+n.get('content-desc','')) for n in nodes())

def screenshot(name):
    shell('screencap','-p','/sdcard/a1_capture.png')
    adb('pull','/sdcard/a1_capture.png',str(OUT/(name+'.png')))
    print('SCREENSHOT',name,flush=True)

def launch():
    shell('am','force-stop',PACKAGE)
    shell('am','start','-n',PACKAGE+'/.MainActivity')
    time.sleep(2)

original = {
    'wifi':shell('settings','get','global','wifi_on'),
    'mobile':shell('settings','get','global','mobile_data'),
    'power':shell('settings','get','global','low_power'),
    'battery':shell('dumpsys','battery'),
}
try:
    apk = ROOT/'build/app/outputs/flutter-apk/app-release.apk'
    adb('install','-r',str(apk))
    shell('svc','wifi','disable'); shell('svc','data','disable')
    shell('dumpsys','battery','unplug')
    shell('dumpsys','battery','set','level','20')
    shell('cmd','power','set-mode','1')
    time.sleep(1)
    launch()
    assert visible('Sem conexão com internet'), 'Aviso offline ausente'
    screenshot('01_aviso_offline'); tap('Fechar')
    assert visible('Seu dispositivo está no modo economia de energia'), 'Aviso economia ausente'
    screenshot('02_economia_energia'); tap('Fechar')
    assert visible('Atenção. Bateria Baixa.'), 'Aviso de bateria ausente'
    screenshot('03_bateria_baixa'); tap('Fechar')
    shell('dumpsys','battery','set','level','19'); time.sleep(.5)
    assert not visible('Atenção. Bateria Baixa.'), 'Alerta repetido incorretamente'
    report['offline_start'] = True
    report['power_save_start'] = True
    report['battery_20_and_no_repeat_at_19'] = True
    shell('cmd','power','set-mode','0')
    shell('svc','wifi','enable'); shell('svc','data','enable')
    shell('dumpsys','battery','reset');time.sleep(1)
    screenshot('04_home')
    # Home agrupa cada cartao em um no semantico; encontre pelo titulo.
    candidates=[n for n in nodes() if n.get('clickable')=='true' and 'QuizMyBrain' in (n.get('text','')+n.get('content-desc',''))]
    if not candidates:
        raise AssertionError('Cartao do quiz ausente')
    rect=list(map(int,re.findall(r'\d+',candidates[0].get('bounds'))))
    shell('input','tap',str((rect[0]+rect[2])//2),str((rect[1]+rect[3])//2));time.sleep(.7)
    for answer in ['D. Insert','C. Vinculo','A. Redundância']:
        tap(answer);tap('Próximo');tap('Próximo')
    adb('emu','sensor','set','acceleration','-7:7:0');time.sleep(.7)
    values=nodes('Verdadeiro')
    report['tilt_right_selects_true']=any(n.get('selected')=='true' for n in values)
    screenshot('05_vf_giro_direita')
    adb('emu','sensor','set','acceleration','7:7:0');time.sleep(.7)
    values=nodes('Falso')
    report['tilt_left_selects_false']=any(n.get('selected')=='true' for n in values)
    screenshot('06_vf_giro_esquerda')
    tap('Encerrar');tap('Voltar para Home')
    shell('input','swipe','500','1600','500','600','350');time.sleep(.4)
    candidates=[n for n in nodes() if n.get('clickable')=='true' and 'MemoCheck' in (n.get('text','')+n.get('content-desc',''))]
    if not candidates: raise AssertionError('Cartao de memoria ausente')
    rect=list(map(int,re.findall(r'\d+',candidates[0].get('bounds'))))
    shell('input','tap',str((rect[0]+rect[2])//2),str((rect[1]+rect[3])//2));time.sleep(1)
    def order():
        return [(n.get('content-desc'),n.get('bounds')) for n in nodes() if n.get('content-desc','').startswith('Carta ')]
    before=order()
    adb('emu','sensor','set','acceleration','25:10:5');time.sleep(.25)
    adb('emu','sensor','set','acceleration','0:9.8:0');time.sleep(.6)
    after=order()
    report['shake_reorders_cards'] = bool(before) and before != after
    screenshot('07_memoria')
    assert report['tilt_right_selects_true'] and report['tilt_left_selects_false'], 'Selecao por giro falhou'
    assert report['shake_reorders_cards'], 'Embaralhamento por shake nao confirmado'
    print('SYSTEM_CHECKS',json.dumps(report,ensure_ascii=False),flush=True)
finally:
    shell('cmd','power','set-mode','1' if original['power']=='1' else '0')
    shell('svc','wifi','enable' if original['wifi'] in ['1','2'] else 'disable')
    shell('svc','data','enable' if original['mobile']=='1' else 'disable')
    if 'UPDATES STOPPED' not in original['battery'].upper():
        shell('dumpsys','battery','reset')
    adb('emu','sensor','set','acceleration','0:9.8:0',check=False)
    (OUT/'android_system_checks.json').write_text(json.dumps({'original':original,'results':report},ensure_ascii=False,indent=2),encoding='utf-8')

