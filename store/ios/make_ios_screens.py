from PIL import Image,ImageDraw,ImageFont,ImageFilter
S='/workspace/tamweel/app/test_shots/'
FB='/usr/share/fonts/truetype/sand-box/google/Cairo/Cairo-VariableFont_slnt,wght.ttf'
def font(sz,w=800):
    return ImageFont.truetype(f'/workspace/tamweel/play_upload/guide/Cairo-{w}.ttf',sz)
EN=[('v12/en_light_0','Choose your country & mode','Saudi, UAE, GCC or Worldwide'),
('v12/en_light_1','Enter salary & obligations','Basic, allowances, loans & cards'),
('v12/en_dark_0','See max financing & DBR','Live gauge of your DBR limit'),
('v11/en_schedule','Calculate EMI & schedule','Monthly installment, month by month'),
('v11/en_compare','Compare bank offers','Find the lowest total cost & APR'),
('out/en_saved','Save & share your report','PDF by email or WhatsApp')]
AR=[('v12/ar_light_0','اختر الدولة ونوع الحساب','السعودية، الإمارات، الخليج أو عالمي'),
('v12/ar_light_1','أدخل الراتب والالتزامات','الراتب الأساسي والبدلات والقروض والبطاقات'),
('v11/ar_dark_eligibility','أقصى تمويل ونسبة الاستقطاع','مؤشر مباشر لحد نسبة الاستقطاع'),
('v11/ar_schedule','احسب القسط وجدول السداد','القسط الشهري شهرًا بشهر'),
('v11/ar_compare','قارن عروض البنوك','اختر أقل تكلفة إجمالية'),
('out/ar_saved','احفظ تقريرك وشاركه','ملف PDF عبر البريد أو واتساب')]
W,H=0,0

def bg():
    im=Image.new('RGB',(W,H));d=ImageDraw.Draw(im)
    a,b=(12,110,96),(4,48,44)
    for y in range(H):
        t=y/H;d.line([(0,y),(W,y)],fill=tuple(int(a[i]+(b[i]-a[i])*t) for i in range(3)))
    g=Image.new('L',(W,H),0);ImageDraw.Draw(g).ellipse((-300*W//1080,-400*W//1080,900*W//1080,500*W//1080),fill=60);g=g.filter(ImageFilter.GaussianBlur(120))
    im.paste((60,200,170),(0,0),g);return im
def make(item,i,lang,out):
    k=W/1080
    src,cap,sub=item;rtl=lang=='ar'
    im=bg();d=ImageDraw.Draw(im)
    kw=dict(direction='rtl',language='ar') if rtl else {}
    # step badge
    bx=W//2;d.ellipse((bx-50*k,90*k,bx+50*k,190*k),fill=(232,190,90))
    num=str(i) if not rtl else '١٢٣٤٥٦'[i-1]
    d.text((bx,140*k),num,font=font(int(64*k),900),fill=(4,48,44),anchor='mm')
    f=font(int((78 if len(cap)<26 else 66)*k),800)
    d.text((W//2,280*k),cap,font=f,fill='white',anchor='mm',**kw)
    d.text((W//2,380*k),sub,font=font(int(42*k),600),fill=(240,205,120),anchor='mm',**kw)
    sh=Image.open(S+src+'.png').convert('RGB')
    pw=int(840*k);ph=int(sh.height*pw/sh.width);sh=sh.resize((pw,ph),Image.LANCZOS)
    top=int(470*k);vis=H-top-int(40*k)
    sh=sh.crop((0,0,pw,min(ph,vis)))
    fw,fh=pw+int(36*k),sh.height+int(36*k);x=(W-fw)//2
    shadow=Image.new('L',(W,H),0);ImageDraw.Draw(shadow).rounded_rectangle((x+10,top+20,x+fw+10,top+fh+20),int(60*k),fill=140)
    im.paste((0,20,18),(0,0),shadow.filter(ImageFilter.GaussianBlur(int(30*k))))
    d=ImageDraw.Draw(im);d.rounded_rectangle((x,top,x+fw,top+fh),int(62*k),fill=(18,22,24))
    m=Image.new('L',sh.size,0);ImageDraw.Draw(m).rounded_rectangle((0,0,pw-1,sh.height-1),int(46*k),fill=255)
    im.paste(sh,(x+int(18*k),top+int(18*k)),m)
    im.save(out,optimize=True)

import os
O='/workspace/tamweel/app/store/ios/screenshots/'
for W,H,tag in ((1320,2868,'6.9in'),(1284,2778,'6.5in')):
    for lang,L in (('en',EN),('ar',AR)):
        os.makedirs(f'{O}{tag}/{lang}',exist_ok=True)
        for i,it in enumerate(L,1): make(it,i,lang,f'{O}{tag}/{lang}/{lang}_{i}_{W}x{H}.png')
print('ok')
