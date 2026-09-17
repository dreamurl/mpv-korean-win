# 테스트 파일

mpv 나 uosc 버전을 올릴 때마다 같은 것을 확인하게 되므로 남겨 둔다.

## 자막 (저장소에 포함)

| 파일 | 확인하는 것 |
|---|---|
| `test-cp949.smi` | **가장 중요.** 옛 한국 자막이 깨지지 않는가 |
| `test-utf8.smi` | 요즘 자막도 여전히 되는가 |
| `test-cp949.srt` | SRT 도 같은지 |
| `test-utf8.srt` | |

각 자막의 첫 줄에 자기 정체(`SMI · CP949` 등)가 적혀 있어서, 화면만 보고
어느 파일이 떴는지 알 수 있다.

넷째 줄의 `￦ ± × ÷ ° ㈜ ℃ №` 는 CP949 에 실제로 있는 글자만 골랐다.
`₩`(U+20A9)와 `—`(em dash)는 CP949 에 **없어서** 인코딩 자체가 실패한다.
한국어 윈도우가 쓰는 원화는 전각 `￦`(U+FFE6)다.

셋째 줄의 `쀍쭜쫣` 은 흔치 않은 조합이라 인코딩이 어긋나면 제일 먼저 깨진다.

## 영상 (저장소에 없음 — 직접 만든다)

용량이 커서 뺐다. 아래대로 만들면 된다.

### 1. 실제 2D 셀 애니메이션 (Anime4K 본래 대상)

플라이셔 슈퍼맨 1941년작. archive.org 에 **CC0 1.0** 으로 올라와 있다.
같은 검색 결과의 다른 슈퍼맨 단편들은 라이선스 표기가 없으니 이것을 쓴다.

```bash
curl -L -o full.mp4 \
  "https://archive.org/download/Superman_Mechanical-Monsters/CARTOON-Superman_Mechanical-Monsters.mp4"

# 3분만 잘라낸다. 재인코딩하지 않는다 — 다시 인코딩하면 없던 손상이
# 추가돼서, 셰이더가 고치는 것이 원본 손상인지 내가 만든 손상인지
# 구분할 수 없게 된다.
ffmpeg -ss 150 -t 180 -i full.mp4 -c copy -movflags +faststart \
  superman-1941-640x480.mp4
```

640x480 이라 전체화면으로 보면 1080p 에서 2.2배, 4K 에서 4.5배 확대된다.

### 2. 일부러 망가뜨린 영상 (압축 아티팩트용)

Sintel(Blender, CC-BY 3.0)을 저화질로 다시 인코딩한다.

```bash
curl -L -o Sintel.2010.1080p.mkv \
  "https://download.blender.org/durian/movies/Sintel.2010.1080p.mkv"

ffmpeg -ss 300 -t 300 -i Sintel.2010.1080p.mkv \
  -vf "scale=854:364:flags=bicubic" \
  -c:v libx264 -preset veryfast -crf 31 \
  -x264-params "ref=1:bframes=1:subme=2:trellis=0" \
  -c:a aac -b:a 64k -ac 2 -movflags +faststart \
  sintel-480p-저화질.mp4
```

## 보는 법

자막이 자동으로 뜨도록 영상과 같은 이름으로 복사한다.

```bash
cp test-cp949.smi superman-1941-640x480.smi
```

**반드시 전체화면(`f`)으로 본다.** 창 모드에서는 확대가 거의 일어나지
않아 셰이더가 일할 자리가 없다. 실제로 1.16배 확대 상태에서 "차이가
없다"고 판단할 뻔했다.

`Ctrl+0`(끄기)과 `Ctrl+3`(C)을 번갈아 누르며 로봇 윤곽과 글자 가장자리를
본다.

## 기록해 둘 만한 결과 (2026-09-17)

- 끔 → C : 윤곽이 뚜렷해진다. 필름 그레인도 같이 선명해진다
- C → A : 매끈해지지만 질감이 사라진다
- **A+A : 눈에 띄게 나빠진다.** 사람이 덩어리가 되고 글자에 흰 테두리가
  생긴다. 2배 이상 확대할 때만 쓰라는 Anime4K 문서의 경고가 정확했다
