# SRT-TOOLS

`srt-tools`는 [서브립](https://en.wikipedia.org/wiki/SubRip)
파일(`.srt` 확장자)을 다양한 방식으로 수정하고 변환하는 커맨드
라인 기반의 프로그램 모음입니다. 현재 `smi2srt`와 `srttidy`, 두 프로그램이
있습니다.

## 설치

맥이나 리눅스 사용자는 `smi2srt`, `srttidy` 두 파일을 실행 경로에 등록된
디렉터리에 복사하고 실행 권한을 주면(`chmod +x smi2srt srttidy`) 바로 사용할
수 있습니다.

### 윈도우 사용자

마이크로소프트 윈도우 사용자는 [윈도우용 펄](https://strawberryperl.com)을
설치하거나, [WSL](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R?hl=en-us&gl=us)을 설치한 뒤 사용할 수 있습니다.
WSL은 가상 리눅스 환경이라 맥이나 리눅스와 사용법이 동일합니다. 그러나
윈도우용 펄은 몇 가지 차이가 있습니다.

```
$ smi2srt my.smi
created: my.srt
```

리눅스나 맥의 터미널에서 위와 같이 입력하면 `my.srt`파일이 생성됩니다.

```
c:\> perl c:\path-to\smi2srt my.smi
created: my.srt
```

도스창에서는 위와 같이 명령해야 합니다. `c:\path-to`는 `smi2srt`가 여러분의
컴퓨터에 복사된 경로입니다.

```
$ smi2srt *.smi
created: 1.srt
created: 2.srt
...
```

리눅스나 맥 환경에서 위와 같이 실행하면 현재 디렉터리 안의 모든 `smi` 파일을
`srt`로 변경합니다. 그러나 윈도우에서는 다음과 같이 명령해야 합니다.

```
for %a in ("*.smi") do perl C:\path-to\smi2srt %a
```

이밖에도 터미널 인코딩 등 다양한 차이가 있으니 가급적 WSL을 설치해서
사용하세요. 이 문서는 주로 맥이나 리눅스 환경을 가정해서 설명합니다.

## SMI2SRT

`smi2srt`는 [SAMI](https://ko.wikipedia.org/wiki/SAMI) 포맷의 파일을
[서브립](https://en.wikipedia.org/wiki/SubRip) 포맷으로 변경하는 커맨드 라인
프로그램입니다. 기본 사용법은 다음과 같습니다.

```
$ smi2srt my.smi
created: my.srt
```

이름을 지정하고 싶으면 다음과 같이 명령하세요.

```
$ smi2srt < my.smi > new.srt
```

`smi2srt my.smi > new.srt`가 아니라 `smi2srt < my.smi > new.srt`임에 주의하세요.
다음과 같이 명령하면 파일로 저장하지 않고 화면에 출력합니다.

```
$ smi2srt < my.smi
```

한꺼번에 많은 파일을 변환할 수도 있습니다. 이때는 `>`를 이용해서 이름을 지정할
수 없습니다.

```
$ smi2srt 1.smi 2.smi 3.smi
created: 1.srt
created: 2.srt
created: 3.srt
```

```
$ smi2srt */*.smi
created: dir1/1.srt
created: dir1/2.srt
...
created: dirN/M.srt
```

## SRTTIDY

`srttidy`는 [서브립](https://en.wikipedia.org/wiki/SubRip) 파일의 싱크를 맞추고
타임스탬프를 수정하는 등 다양한 작업을 지원하는 커맨드 라인 프로그램입니다.
특히 글자 수에 비해 표시 시간이 적은 자막만 골라서 시간을 수정하는 등 자막
번역에 필요한 다양한 기능을 제공합니다.

다음의 헬프 메시지를 중심으로 하나씩 설명하겠습니다.

```
Usage: srttidy [OPTIONS] SRT-FILE [...]
   or: srttidy [OPTIONS] < IN-SRT-FILE > OUT-SRT-FILE

Options
  -t                    show subtitle texts only
  -c COLOR              specify default subtitle font color
  -r                    remove srttidy-specified font color
  -s SECOND             shift timestamps by given time in seconds
  -l TIME-MAP           correct timestamps linearly by given time map
  -n                    remove empty subtitles, and reorder lefts one-by-one
  -d PATTERN            remove subtitles including given pattern
  -g PATTERN            show subtitles including given pattern
  -m DURATION,GAP       change timestamps by given minimum duration and gap
                        in seconds
  -f CONDITION          show or apply -m option only to subtitles matching
                        given condition
  -b                    remove carriage returns and BOM

Examples
  srttidy -t < my.srt > my.txt
  srttidy -c silver *.srt
  srttidy -r < old.srt > new.srt
  srttidy -s -8.26 < old.srt > new.srt
  srttidy -b -l "00:00:19,145->00:00:22,189 02:39:17,715->02:39:18,390" my.srt
  srttidy -b -n -d '(yts|sub2smi|elsubtitle)' *.srt
  srttidy -n Movies/*/*.srt
  srttidy -g '(yts|sub2smi|elsubtitle)' *.srt
  srttidy -m 1.0,0.1 my.srt
  # lc: line counts, cc: character counts, dt: duration in seconds
  srttidy -f '(lc=1 and cc>15) or cc>20 or dt>3.5' < old.srt
  srttidy -m 3,0.1 -f 'cc > 20 and dt < 2' my.srt

See <https://github.com/9beach/srt-tools> for updates and bug reports
USAGE
```

다음의 `my.srt`를 예로 사용하겠습니다.

```srt
1
00:00:30,000 --> 00:00:30,524

2
00:00:30,900 --> 00:00:31,000
Lolita, light of my life,

3
00:00:35,000 --> 00:00:35,575
fire of my loins. My sin, my soul.

4
00:00:40,000 --> 00:00:42,000
<font color=red><i>Lo-lee-ta:</i></font>

6
00:00:45,000 --> 00:00:50,469
the tip of the tongue taking a trip of
three steps down the palate to tap,

7
00:00:50,000 --> 00:00:50,635
at three, on the teeth. Lo. Lee. Ta.
```

### 텍스트만 추출하기

`-t` 옵션은 자막에서 텍스트만 추출합니다.

```
$ srttidy -t < my.srt
Lolita, light of my life,
fire of my loins. My sin, my soul.
Lo-lee-ta:
the tip of the tongue taking a trip of
three steps down the palate to tap,
at three, on the teeth. Lo. Lee. Ta.
```

아래의 두 명령과 비교해 봅시다.

```
$ srttidy -t my.srt
created: my-tidy.txt
```

```
$ srttidy -t < my.srt > my.txt
```

`<` 기호를 파일 앞에 붙이면 결과를 화면에 출력합니다. 이때 출력된 결과를 
화면이 아닌 파일로 저장하고 싶으면 `>` 기호 뒤에 저장할 파일의 이름을
지정합니다. `<` 기호 없이 실행하면 `-tidy` 이름을 붙여서 새로운 파일을 만듭니다.

서브립이 아닌 SAMI에서 텍스트만 추출하고 싶다면 다음을 실행합니다.

```
$ smi2srt < my.smi | srttidy -t
```

### 기본 폰트 색깔 변경하기

하얀색 폰트가 눈에 거슬려 `silver`나 `gray`로 고치고 싶다면 다음과 같이
실행합니다.

```
$ srttidy -c silver my.srt
created: my-tidy.srt
$ srttidy -c gray < my.srt > new.srt
```

물론 이미 색깔이 지정된 폰트는 변경하지 않습니다. 기본인 하얀색만 원하는
색깔로 변경합니다.

`srttidy -c gray < my.srt > my.srt`과 같이 실행하면 의도와는 달리 기존 파일
내용을 지워버립니다. `srttidy -c gray < my.srt` 명령에 의한 작업을 하기 전에
`> my.srt` 명령으로 먼저 빈 파일을 만들기 때문입니다. 다음과 같이 실행해야
합니다.

```
srttidy -c gray < my.srt > tmp.srt && [ -s tmp.srt ] && mv tmp.srt my.srt
```

`srttidy`로 지정한 색깔을 없애고 원래대로 복구하려면 다음과 같이 실행합니다.

```
$ srttidy -r my-tidy.srt
created: my-tidy-tidy.srt
```

```
$ srttidy -r < my-tidy.srt > my-org.srt
```

### 자막 싱크 조절하기

자막이 영상에 비해 일찍 나와서 2.1초 뒤로 보내고 싶다면 다음을 실행합니다.

```
$ srttidy -s 2.1 < my.srt > new.srt
```

반대로, 앞으로 보내고 싶다면 다음과 같이 실행합니다.

```
$ srttidy -s -9.2 < my.srt > new.srt
```

자막의 싱크가 앞부분에서 3초 정도 차이 나는데 뒤로 가면 0.6초로 차이가
줄어드는 경우가 있습니다. 이때는 관찰을 통해서 측정할 수도 있지만 잘 맞는
영문 자막을 찾은 뒤 전후반부에 한 장면씩 골라 한글 자막과 영문 자막의
타임스탬프를 비교하면 확실히 알 수 있습니다. 이런 경우 다음과 같이 명령하여
싱크를 선형으로 보정할 수 있습니다.

```
$ srttidy -l "00:00:19,145->00:00:22,189 02:39:17,715->02:39:18,390" my.srt
```

### 자막 순서 보정하기

번역 과정에서 짧은 대사 두 개를 병합하는 등의 이유로 자막 번호의 순서가 맞지
않은 경우가 있습니다. 위의 `my.srt` 예는, 첫 번째 자막의 텍스트가 비어 있고
자막 번호가 4에서 6으로 뛰는 등 순서가 맞지 않습니다. 이런 경우 다음과 같이
보정합니다.

```srt
$ srttidy -n < my.srt
1
00:00:30,900 --> 00:00:31,000
Lolita, light of my life,

2
00:00:35,000 --> 00:00:35,575
fire of my loins. My sin, my soul.

3
...
```

대부분의 옵션은 조합해서 사용할 수 있습니다.

```
$ srttidy -n -l "00:00:19,145->00:00:22,189 02:39:17,715->02:39:18,390" my.srt
$ srttidy -n -c gray < my.srt > new.srt
$ srttidy -s -9.2 -c gray < my.srt > new.srt
$ srttidy -r -n < my.srt > new.srt
```

### 키워드로 자막 검색하기

`the`라는 단어를 포함하는 자막만 보고 싶으면 다음과 같이 명령합니다.

```
$ srttidy -g the < my.srt
```

대소문자를 가지리 않기 때문에 위의 결과는 `THE`라는 단어를 포함한 자막도
보여줍니다. `the` 또는 `my`로 검색 조건을 늘리고 싶으면 다음과 같이 명령합니다.

```
$ srttidy -g '(the|my)' < my.srt
```

검색 조건은 [정규 표현식](https://ko.wikipedia.org/wiki/%EC%A0%95%EA%B7%9C_%ED%91%9C%ED%98%84%EC%8B%9D)을 지원합니다. 엄창나게 강력하니 따로 찾아 보시기  
바랍니다. 몇 가지 핵심적인 특징만 소개하겠습니다.

- `-g '(dog|cat)'`으로 검색하면 `dog` 또는 `cat`을 포함한 자막만 보여줍니다.
- `.`은 임의의 문자를 뜻합니다. 마침표는 `\.`로 표기합니다. `-g '(,|\.)'`로 검색하면 마침표나 쉼표가 있는 자막만 보여줍니다.
- `-g 'dog.*cat'`으로 검색하면 `dog`과 `cat`이 순서대로 나오는 자막만 보여줍니다.

### 키워드로 자막 삭제하기

`sub2smi`라는 단어를 포함하는 자막만 삭제하려면 다음과 같이 명령합니다.

```
$ srttidy -d sub2smi < my.srt
```

위에서 설명한 `-n` 옵션과 조합하면 삭제한 뒤 자막 번호를 순차적으로 고쳐줍니다.

```
$ srttidy -n -d sub2smi < my.srt
```

`-g` 옵션과 마찬가지로 정규 표현식을 지원합니다.

```
$ srttidy -g '(,|\.|\?)' < my.srt | srttidy -d '\.\.\.'
```

위와 같이 실행하면 `...`가 있는 자막을 제외하고  마침표나 쉼표, 물음표가 있는
자막만 보여줍니다.

### 글자 수, 라인 수, 표시 시간으로 자막 검색하기

`cc`, `lc`, `dt`는 각각 글자 수, 라인 수, 표시 시간을 뜻합니다.
다음의 실행 예를 살펴 보세요.

```
$ srttidy -f 'lc=1 and cc>20' < my.srt
3
00:00:35,000 --> 00:00:35,575
fire of my loins. My sin, my soul.

7
00:00:50,000 --> 00:00:50,635
at three, on the teeth. Lo. Lee. Ta.
```

```
$ srttidy -f 'lc=2' < my.srt
6
00:00:45,000 --> 00:00:50,469
the tip of the tongue taking a trip of
three steps down the palate to tap,
```

```
$ srttidy -f 'dt>4' < my.srt
6
00:00:45,000 --> 00:00:50,469
the tip of the tongue taking a trip of
three steps down the palate to tap,
```

`'(lc=1 and cc>=15) or cc>20 or dt>3.5'`와 같이 괄호를 써서 복잡한 조건을 
구성할 수도 있습니다.

### 표시 시간 보정하기

자막이 너무 빨리 지나가서 읽기 힘든 경우가 있습니다. `-m` 옵션으로 자막의
최소 표시 시간을 지정해서 늘릴 수 있습니다. 다음의 예를 봅시다.

```
$ srttidy -n -m '1,0.1' < my.srt > new.srt
* 1 1,19: SHORT/FIXED (0.100 -> 1.000)
  00:00:30,900 --> 00:00:31,000
  Lolita, light of my life,

* 2 1,24: SHORT/FIXED (0.575 -> 1.000)
  00:00:35,000 --> 00:00:35,575
  fire of my loins. My sin, my soul.

* 4 2,58: OVERLAPPED/FIXED (5.469 -> 4.900)
  00:00:45,000 --> 00:00:50,469
  the tip of the tongue taking a trip of
  three steps down the palate to tap,

* 5 1,24: SHORT/FIXED (0.635 -> 1.000)
  00:00:50,000 --> 00:00:50,635
  at three, on the teeth. Lo. Lee. Ta.
```

`-n` 옵션으로 빈 자막은 제거했고 `-m '1,0.1'` 옵션으로 최소 표시 시간을 1초,
다음 자막과의 최소 간격을 0.1초로 지정했습니다. 수행 결과로 보정된 자막은
`new.srt` 파일에 저장됐으며 수행 내역이 화면에 표시되었습니다. 첫 줄부터
보겠습니다.

```
* 1 1,19: SHORT/FIXED (0.100 -> 1.000)
```

`1 1,19`는, 첫 번째 자막이 1개의 라인과 19개의 글자로 구성되며
표시 시간이 0.100초여서 기준보다 짧으니 1초로 늘렸다는 뜻입니다.

```
* 4 2,58: OVERLAPPED/FIXED (5.469 -> 4.900)
```

4번째 자막은 두 개의 줄과 58개의 글자로 구성되는데, 종료시간이 5번째 자막의
시작시간보다 늦어서 겹친 상태였고 이를 수정했다는 메시지입니다.
이런 오류는 `-m` 옵션을 수행만 하면 조건과 무관하게 보정합니다.

3번째 자막 수행 내역이 없는 것은 표시 시간이 1초 이상이어서 보정할 필요가
때문입니다.

만약 수행 내역에 짧은 자막이 자주 연속해서 이어진다면 최소 표시 시간을
늘이기보다 짧은 자막을 병합해서 두 줄 자막을 만드는 것을 고려하세요.

### 조건에 부합하는 자막만 표시 시간 보정하기

`-f` 옵션과 `-m` 옵션을 같이 써서 조건에 부합하는 자막만 표시 시간을 보정할 
수 있습니다.

다음은 글자 수가 15 이상 20 이하이고 줄 수가 하나인 자막의 최소 표시 시간을
2초로 지정합니다.

```
$ srttidy -f 'lc=1 and cc>=15 and cc<=20' -m '2,0.1' < my.srt
```

다음은 스무 글자 이상이고 한 줄인 자막의 최소 표시 시간을 3초로 지정합니다.

```
$ srttidy -f 'lc=1 and cc>=20' -m '3,0.1' < my.srt
```

### 바이트 순서 표시와 캐리지 리턴 제거하기

사용자 눈에 보이지는 않으나
[바이트 순서 표시](https://ko.wikipedia.org/wiki/바이트_순서_표식)라는
것이 문제를 일으키는 경우가 있습니다. `-b` 옵션으로 이것을 제거할 수 있습니다.

```
$ srttidy -b < old.srt > new.srt
```

위와 같이 실행하면 [캐리지 리턴](https://ko.wikipedia.org/wiki/캐리지_리턴)도
같이 제거합니다. 일반적으로 몰라도 되는 기능입니다.

### 파일 인코딩 UTF-8으로 변경하기

`srttidy`는 기본적으로 UTF-8로 인코딩합니다. 따라서 아무런 옵션 없이 실행해도
인코딩은 UTF-8로 바꿉니다.

```
$ srttidy < cp949.srt > utf-8.srt
$ srttidy < utf-16.srt > utf-8.srt
```

## 마무리

앞서 밝혔듯이 대부분의 옵션은 조합해서 사용할 수 있습니다. 다양하게 시도해
보세요. 그리고 어떠한 질문이나 의견도 환영하니
[이슈 시스템](https://github.com/9beach/srt-tools/issues)에 남기시기 바랍니다.
