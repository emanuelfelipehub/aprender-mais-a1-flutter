from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import hashlib,json
root=Path(__file__).resolve().parents[1]
apk=root/'08_Modulo_A1_XX.apk'
assert apk.is_file()
source_json=root.parent/'Projeto Teste Aprender + - Seletiva Nacional 2025/A1 - Funcionalidades/Media-Files/bancoQuestoes.json'
if source_json.exists():
 assert hashlib.sha256(source_json.read_bytes()).digest()==hashlib.sha256((root/'assets/data/bancoQuestoes.json').read_bytes()).digest()
manifest={'apk':apk.name,'bytes':apk.stat().st_size,'sha256':hashlib.sha256(apk.read_bytes()).hexdigest(),
'package':'br.com.aprendermais.aprender_a1','version':'1.0.0+1','min_sdk':24,'target_sdk':36,
'unit_widget_tests':22,'android_integration_tests':2,'training':True,'remote_submission':False,
'physical_headset_validation':False}
(root/'ENTREGA.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
archive=root.parent/'08_Modulo_A1_XX_Entrega.zip'
exclude={'build','.dart_tool','.gradle','.idea','.git','__pycache__'}
with ZipFile(archive,'w',ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(root.rglob('*')):
  rel=p.relative_to(root)
  if not p.is_file() or any(part in exclude for part in rel.parts):continue
  if p.name in {'local.properties','write-check.txt','TERMOS_A_COMPLEMENTAR.txt','GeneratedPluginRegistrant.java','.flutter-plugins-dependencies','.flutter-plugins'} or p.suffix=='.iml':continue
  z.write(p,Path(root.name)/rel)
with ZipFile(archive) as z:
 assert z.testzip() is None
print(json.dumps({'archive':str(archive),'size':archive.stat().st_size,'manifest':manifest},ensure_ascii=False))

