from pathlib import Path
import subprocess,time,re,json,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
ADB=r'C:\Users\SENAI\AppData\Local\Android\Sdk\platform-tools\adb.exe'
PKG='br.com.aprendermais.aprender_a1'
def adb(*args):
 p=subprocess.run([ADB,*args],check=True,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=30)
 return p.stdout
def tree():
 adb('shell','uiautomator','dump','/sdcard/a1_final_tree.xml')
 s=adb('shell','cat','/sdcard/a1_final_tree.xml')
 return ET.fromstring(s[s.index('<?xml'):])
def click_node(n):
 x1,y1,x2,y2=map(int,re.findall(r'\d+',n.get('bounds')))
 adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2))
 time.sleep(.4)
def tap(label):
 values=[n for n in tree().iter('node') if label in [n.get('text'),n.get('content-desc')]]
 assert values,label
 click_node(values[-1])
def capture(name):
 adb('shell','screencap','-p','/sdcard/a1_final_capture.png')
 adb('pull','/sdcard/a1_final_capture.png',str(ROOT/'evidencias'/name))
report={}
adb('shell','am','start','-W','-n',PKG+'/.MainActivity')
time.sleep(.5)
t=tree()
report['home_visible']=any('Bem-vindo ao Aprender+' in (n.get('content-desc','')+n.get('text','')) for n in t.iter('node'))
assert report['home_visible']
capture('12_home_final.png')
card=next(n for n in tree().iter('node') if n.get('clickable')=='true' and 'QuizMyBrain' in (n.get('text','')+n.get('content-desc','')))
click_node(card)
tap('D. Insert');tap('Próximo');tap('Encerrar');tap('Voltar para Home')
capture('12_home_final.png')
tap('Open navigation menu')
capture('14_menu_final.png')
tap('Sair')
report['sair_closes_activity']=tree().find('node').get('package') != PKG
assert report['sair_closes_activity']
adb('shell','input','keyevent','KEYCODE_HOME')
t=tree()
report['widget_scores']={n.get('resource-id').split('/')[-1]:n.get('text') for n in t.iter('node') if n.get('resource-id','').startswith(PKG+':id/') and n.get('resource-id','').endswith('_score')}
report['widget_visible']=len(report['widget_scores'])==3
assert report['widget_visible']
assert report['widget_scores'].get('quiz_score')=='5'
capture('15_widget_final.png')
candidates=[n for n in t.iter('node') if n.get('content-desc')=='Aprender+ — Pontuações']
assert candidates
click_node(candidates[0])
report['widget_opens_app']=tree().find('node').get('package') == PKG
assert report['widget_opens_app']
(ROOT/'evidencias/final_android_checks.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))

