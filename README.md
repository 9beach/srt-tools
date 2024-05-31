# SRT-TOOLS

`srt-tools`는 [서브립](https://en.wikipedia.org/wiki/SubRip)
파일(`.srt` 확장자)을 LLM을 이용해서 번역하고, 다양한 방식으로 수정하고 
변환하는 커맨드 라인 기반의 프로그램 모음입니다. 현재 `smi2srt`와 `srttidy`, `srttrans`, `srtmerge`가 포함되어 있습니다.

## 설치

맥이나 리눅스 사용자는 파일을 실행 경로에 등록된 디렉터리에 복사하고 실행 권한을 부여하면 바로 사용할 수 있습니다. 다음과 같이 설치하세요:

```
sudo curl -L https://raw.githubusercontent.com/9beach/srt-tools/main/smi2srt -o /usr/local/bin/smi2srt
sudo curl -L https://raw.githubusercontent.com/9beach/srt-tools/main/srttidy -o /usr/local/bin/srttidy
sudo curl -L https://raw.githubusercontent.com/9beach/srt-tools/main/srttrans -o /usr/local/bin/srttrans
sudo curl -L https://raw.githubusercontent.com/9beach/srt-tools/main/srtmerge -o /usr/local/bin/srtmerge
cd /usr/local/bin && sudo chmod a+rx srttidy smi2srt srtmerge srttrans
```

`srttrans`를 이용해서 인공지능 자막 번역 기능을 사용하려면 [llm-cli](https://github.com/9beach/llm-cli)를 먼저 설치해야 합니다. 설치 과정이 매우 간단하므로 설치를 권장합니다.

## `srttrans`

`srttrans`는 `llm-cli` 툴킷의 `lt-llm-cli` 명령어와 사용법이 유사합니다. API 키는 본인이 발급해야 하며, 2024년 현재 구글 제미나이 API 키는 무료로 얻을 수 있습니다. 다음과 같이 사용하세요:

```sh
export DEEPL_API_KEY="Your-API-Key"
cat my-english.srt | srttrans deepl-cli KO > my-ko.srt
```

```sh
export GEMINI_API_KEY="Your-API-Key"
cat my-france.srt | srttrans gemini-cli ko > my-ko.srt
```

```sh
export ANTHROPIC_API_KEY="Your-API-Key"
cat my-brazil.srt | srttrans claude-cli hi > my-hi.srt
```

ko, hi는 각각 한국어와 힌디어의 약자입니다. Korean, Hindi로 써도 무방합니다.

환경 변수 `LT_LINES`와 `LT_SLEEP_SEC`을 지정하여 한 번에 번역을 요청하는 라인 수와 대기 시간을 조절할 수 있습니다. `LT_LINES`는 한 번에 번역 요청할 라인 수를 설정하고, `LT_SLEEP_SEC`는 각 번역 요청 사이의 대기 시간을 설정합니다.

```sh
export GEMINI_API_KEY="Your-API-Key"
export LT_LINES=100
export LT_SLEEP_SEC=5
cat my-france.srt | srttrans gemini-cli JP > my-japanese.srt
```

위의 예시에서 번역 작업이 너무 오래 걸려서 중간에 “Ctrl + C”로 멈추더라도, 번역된 부분은 `my-japanese.srt` 파일에 저장됩니다. 그러나 이 경우 번역된 부분뿐만 아니라 번역되지 않은 부분도 함께 저장됩니다. 번역되지 않은 부분만 따로 파일로 저장하여 번역을 완료한 후, `srtmerge` 도구를 사용해 번역된 파일과 병합할 수 있습니다.

## `srtmerge`

아래와 같은 두 파일을 병합할 때 `srtmerge`를 사용하세요.

**파일 a**

```
1
00:00:50,313 --> 00:00:52,478
안녕하세요.

2
00:00:52,545 --> 00:00:54,043
-You okay?
-Person 4: You ready to go in?

3
00:00:54,109 --> 00:00:55,208
Let's go.
```

**파일 b**

```
2
00:00:52,545 --> 00:00:54,043
-괜찮아요?
-사람 4: 들어갈 준비 됐어요?

3
00:00:54,109 --> 00:00:55,208
가자.
```

```
❯ srtmerge a b
1
00:00:50,313 --> 00:00:52,478
안녕하세요.

2
00:00:52,545 --> 00:00:54,043
-괜찮아요?
-사람 4: 들어갈 준비 됐어요?

3
00:00:54,109 --> 00:00:55,208
가자.
```

파일 `a`는 자신에게 존재하는 번호만 파일 `b`로부터 가져와 병합합니다. 즉 파일 `a`에 영어로 된 2, 3 번 자막이 없다면 `b`로부터 해당 자막을 병합하지 않습니다. 이 점에 유의하세요.

`srtmerge`의 독특한 기능으로, 파일 b의 추가 포맷을 지원합니다.

```txt
2%-
-괜찮아요?
-사람 4: 들어갈 준비 됐어요?
3%-
가자.
```

즉, 타임스탬프가 없어도 순서 다음에 `%-` 기호만 있으면 병합할 수 있습니다. 이 기능을 이용하면 번역 엔진을 사용할 때 필요 없는 부분을 제거하고 번역한 뒤 병합할 수 있습니다. 터미널에서 다음 명령어를 실행해 보세요. 타임스탬프를 없애고 순서 다음에 `%-` 기호를 자동으로 붙여줍니다.

```sh
cat org.srt | perl -0777 -pe 's/^\s*\n//mg;s/([0-9]+)\n([0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3})/$1%-/g' > to-translate.txt
```

## `smi2srt`

`smi2srt`는 [sami](https://ko.wikipedia.org/wiki/sami) 포맷의 파일을
[서브립](https://en.wikipedia.org/wiki/subrip) 포맷으로 변경하는 커맨드 라인
프로그램입니다. 기본 사용법은 다음과 같습니다.

```
$ smi2srt my.smi
created: my.srt
```

이름을 지정하고 싶다면 다음과 같이 명령하세요.

```
$ smi2srt < my.smi > new.srt
```

`smi2srt my.smi > new.srt`가 아니라 `smi2srt < my.smi > new.srt`임에 주의하세요.
다음과 같이 명령하면 파일로 저장하지 않고 화면에 출력합니다.

```
$ smi2srt < my.smi
```

저장되는 파일의 이름을 직접 지정하지 않으려면 `<` 없이 사용하세요. 이때는 한꺼번에 많은 파일을 변환할 수도 있습니다.

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

## `srttidy`

`srttidy`는 [서브립](https://en.wikipedia.org/wiki/subrip) 파일의 싱크를 맞추고
타임스탬프를 수정하는 등 다양한 작업을 지원하는 커맨드 라인 프로그램입니다.
특히 글자 수에 비해 표시 시간이 적은 자막만 골라서 시간을 수정하는 등 자막
번역에 필요한 다양한 기능을 제공합니다.

다음의 헬프 메시지를 중심으로 하나씩 설명하겠습니다.

```
Usage: srttidy [OPTIONS] SRT-FILE [...]
   or: srttidy [OPTIONS] < IN-SRT-FILE > OUT-SRT-FILE

Options
  -t                      show subtitle texts only
  -u                      show numeric counters and subtitle texts only
  -c COLOR                specify default subtitle font color
  -r                      remove srttidy-specified font color
  -s SECOND               shift timestamps by given time in seconds
  -l TIME-MAP             correct timestamps linearly by given time map
  -p FRAMERATE-MAP        correct timestamps linearly by given frame rate map
  -n                      remove empty subtitles, and reorder lefts one-by-one
  -d PATTERN              remove subtitles including given pattern
  -g PATTERN              show subtitles including given pattern
  -f CONDITION            show subtitles matching given condition
  -m DURATION,GAP[;COND]  change timestamps by given minimum duration, gap
                          in seconds, and condition
  -b                      remove carriage returns and BOM
  -y                      remove unnecessary whitespace
  -1                      make each subtitle one line

Examples
  srttidy -t < my.srt > my.txt
  srttidy -c silver *.srt
  srttidy -r < old.srt > new.srt
  srttidy -s -8.26 < old.srt > new.srt
  srttidy -b -l "00:00:19,145-00:00:22,189 02:39:17,715-02:39:18,390" my.srt
  srttidy -p "23.976-24" my.srt
  srttidy -n -d '(yts|sub2smi|elsubtitle)' *.srt
  srttidy -b -n Movies/*/*.srt
  srttidy -g '(yts|sub2smi|elsubtitle)' *.srt
  srttidy -f '(lc=1 and cc>15) or cc>20 or dt>3.5' < old.srt
  srttidy -m 1.0,0.1 my.srt
  srttidy -m '3,0.1;cc>20 and dt<2' my.srt
  srttidy -1 -t < my.srt > my.txt
  srttidy -yb < my.srt > my.txt

See <https://github.com/9beach/srt-tools> for updates and bug reports
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

아래의 두 명령과 비교해 보세요.

```
$ srttidy -t my.srt
created: my-tidy.txt
```

```
$ srttidy -t < my.srt > my.txt
```

`<` 기호를 파일 앞에 붙이면 결과를 화면에 출력합니다. 이때 출력된 결과를 
화면이 아닌 파일로 저장하고 싶다면 `>` 기호 뒤에 저장할 파일의 이름을
지정합니다. `<` 기호 없이 실행하면 `-tidy` 이름을 붙여서 새로운 파일을 만듭니다.

서브립이 아닌 SAMI에서 텍스트만 추출하고 싶다면 다음을 실행합니다.

```
$ smi2srt < my.smi | srttidy -t
```

### 기본 자막색깔 변경하기

하얀색 자막이 눈에 거슬려 `silver`나 `gray`로 고치고 싶다면 다음과 같이
실행합니다.

```
$ srttidy -c silver my.srt
created: my-tidy.srt
$ srttidy -c gray < my.srt > new.srt
```

물론 이미 색깔이 지정된 자막은 변경하지 않습니다. 기본인 하얀색만 원하는
색깔로 변경합니다.

`srttidy -c gray < my.srt > my.srt`과 같이 실행하면 기존 파일을 대체하려는 
의도와는 달리 기존 파일의 내용을 지워버립니다. `srttidy -c gray < my.srt` 
명령을 수행하기 전에 먼저 `> my.srt` 명령으로 빈 파일을 만들기 때문입니다.
다음과 같이 실행해야 합니다.

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
영문 자막을 찾은 뒤 전후반부 한 장면씩 골라 한글 자막과 영문 자막의
타임스탬프를 비교하면 확실히 알 수 있습니다. 이런 경우 다음과 같이 명령하여
싱크를 선형으로 보정할 수 있습니다.

```
$ srttidy -l "00:00:19,145-00:00:22,189 02:39:17,715-02:39:18,390" my.srt
```

자막의 싱크가 점차 틀어진다면 위와 같은 방법 이외에 프레임레이트를 변환하는
방법도 있습니다.

```
$ srttidy -p "23.976-24" my.srt
```

### 자막 번호 보정하기

번역 과정에서 짧은 대사 두 개를 병합하는 등의 이유로 자막 번호의 순서가 맞지
않은 경우가 있습니다. 위의 `my.srt`은 첫 번째 자막의 텍스트가 비어 있고
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

### 인덴트 정리하기

```

8
00:00:50,313 --> 00:00:52,478
Okay. Everyone has bottles?
9
00:00:52,545 --> 00:00:54,043
-You okay?

-Person 4: You ready to go in?


10
00:00:54,109 --> 00:00:55,208
Let's go.
```

위와 같은 자막은 `-y` 옵션으로 말끔히 정리할 수 있습니다.

```
> cat nasty.srt | srttidy -y
8
00:00:50,313 --> 00:00:52,478
Okay. Everyone has bottles?

9
00:00:52,545 --> 00:00:54,043
-You okay?
-Person 4: You ready to go in?

10
00:00:54,109 --> 00:00:55,208
Let's go.
```

### 옵션의 조합

대부분의 옵션은 조합해서 사용할 수 있습니다.

```
$ srttidy -n -l "00:00:19,145-00:00:22,189 02:39:17,715-02:39:18,390" my.srt
$ srttidy -n -c gray < my.srt > new.srt
$ srttidy -s -9.2 -c gray < my.srt > new.srt
$ srttidy -r -n < my.srt > new.srt
```

### 키워드로 자막 검색하기

`the`라는 단어를 포함하는 자막만 보고 싶다면 다음과 같이 명령합니다.

```
$ srttidy -g the < my.srt
```

대소문자를 가지리 않기 때문에 위의 결과는 `THE`라는 단어를 포함한 자막도
보여줍니다. `the` 또는 `my`로 검색 조건을 늘리고 싶다면 다음과 같이 명령합니다.

```
$ srttidy -g '(the|my)' < my.srt
```

검색 조건은 
[정규 표현식](https://ko.wikipedia.org/wiki/%EC%A0%95%EA%B7%9C_%ED%91%9C%ED%98%84%EC%8B%9D)을
지원합니다. 상당히 강력하니 따로 찾아 보시기 바랍니다. 여기서는 몇 가지
핵심적인 특징만 소개하겠습니다.

- `-g '(dog|cat)'`으로 검색하면 `dog` 또는 `cat`을 포함한 자막을 보여줍니다.
- `.`은 임의의 문자를 뜻합니다. 마침표는 `\.`로 표기합니다. 그래서 `-g '이.해'`로 검색하면 "이동해", "이상해" 등의 단어를 포함한 자막을 보여주고,`-g '(,|\.)'`로 검색하면 마침표나 쉼표가 있는 자막을 보여줍니다.
- `*`는 바로 앞의 문자가 0번 이상 반복되는 것을 뜻합니다. 그래서 `-g 'dog.*cat'`으로 검색하면 `dogcat`, `dog cat`, `dog and cat` 등 `dog`과 `cat`이 순서대로 나오는 자막을 보여줍니다.

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

위와 같이 실행하면 `...`을 포함한 자막은 제외하고 마침표나 쉼표, 물음표가 있는
자막을 보여줍니다.

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
$ srttidy -n -m '4.5,0.1' < my.srt > /dev/null
* 1 1,19: SHORT/FIXED BUT SHORT (0.100 -> 4.000)
  00:00:30,900 --> 00:00:31,000
  Lolita, light of my life,

* 2 1,24: SHORT/FIXED (0.575 -> 4.500)
  00:00:35,000 --> 00:00:35,575
  fire of my loins. My sin, my soul.

* 3 1,7: SHORT/FIXED (2.000 -> 4.500)
  00:00:40,000 --> 00:00:42,000
  <font color=red><i>Lo-lee-ta:</i></font>

* 4 2,58: OVERLAPPED/FIXED (5.469 -> 4.900)
  00:00:45,000 --> 00:00:50,469
  the tip of the tongue taking a trip of
  three steps down the palate to tap,

* 5 1,24: SHORT/FIXED (0.635 -> 4.500)
  00:00:50,000 --> 00:00:50,635
  at three, on the teeth. Lo. Lee. Ta.
```

`-n` 옵션으로 빈 자막은 제거되었고 `-m '4.5,0.1'` 옵션으로 최소 표시 시간은
4.5초, 다음 자막과의 최소 간격은 0.1초로 지정되었습니다. 수행 결과로 보정된
자막은 `new.srt` 파일에 저장되었으며 수행 내역은 화면에 표시되었습니다. 첫
줄부터 보겠습니다.

```
* 1 1,19: SHORT/FIXED BUT SHORT (0.100 -> 4.000)
```

`1 1,19`는, 첫 번째 자막이 1개의 라인과 19개의 글자로 구성된다는 뜻입니다.
`SHORT/FIXED BUT SHORT (0.100 -> 4.000)`는 표시 시간이 0.100초여서 4.5초로
늘리려 했으나, 다음 자막을 고려해 겹치지 않는 최대인 4.000초로 늘렸다는
뜻입니다.

```
* 2 1,24: SHORT/FIXED (0.575 -> 4.500)
...
* 3 1,7: SHORT/FIXED (2.000 -> 4.500)
```

두 번째, 세 번째 자막은 원래는 짧았지만 4.5초로 변경되어 `SHORT/FIXED`가
표시되었습니다.

```
* 4 2,58: OVERLAPPED/FIXED (5.469 -> 4.900)
```

4번째 자막은 두 개의 줄과 58개의 글자로 구성되는데, 종료시간이 5번째 자막의
시작시간보다 늦어서 겹친 상태였고 이를 수정했다는 메시지입니다. 이런 오류는
기준 시간이 아니라 겹치지 않는 최대 시간만큼 고칩니다. 그래서 4.5초가 아닌
4.9초로 고쳤습니다.

만약 수행 내역에 짧은 자막이 연속해서 자주 이어진다면 최소 표시 시간을
늘이기보다 짧은 자막을 병합해서 두 줄 자막을 만드는 것을 고려하세요.

### 조건에 부합하는 자막만 표시 시간 보정하기

`-m` 옵션에 부가 조건을 줘서 조건에 부합하는 자막만 표시 시간을 보정할 
수 있습니다.

다음은 글자 수가 15 이상 20 이하이고 줄 수가 하나인 자막의 최소 표시 시간을
2초로 지정합니다.

```
$ srttidy -m '2,0.1;lc=1 and cc>=15 and cc<=20' < my.srt > new.srt
* 2 1,19: SHORT/FIXED (0.100 -> 2.000)
  00:00:30,900 --> 00:00:31,000
  Lolita, light of my life,
```

다음은 스무 글자 이상이고 한 줄인 자막의 최소 표시 시간을 3초로 지정합니다.

```
$ srttidy -m '3,0.1;lc=1 and cc>=20' < my.srt > new.srt
* 3 1,24: SHORT/FIXED (0.575 -> 3.000)
  00:00:35,000 --> 00:00:35,575
  fire of my loins. My sin, my soul.

* 7 1,24: SHORT/FIXED (0.635 -> 3.000)
  00:00:50,000 --> 00:00:50,635
  at three, on the teeth. Lo. Lee. Ta.
```

### 바이트 순서 표시와 캐리지 리턴 제거하기

사용자 눈에 보이지는 않으나
[바이트 순서 표시](https://ko.wikipedia.org/wiki/바이트_순서_표식)라는
것이 문제를 일으키는 경우가 있습니다. `-b` 옵션으로 이것을 제거할 수 있습니다.

```
$ srttidy -b < old.srt > new.srt
```

위와 같이 실행하면 [캐리지 리턴](https://ko.wikipedia.org/wiki/캐리지_리턴)도
같이 제거합니다. 일반적으로 몰라도 되는 기능입니다만 캐리지 리턴이 파일에 
붙는 것이 싫다면, 다른 옵션으로 작업할 때도 습관적으로 `-b` 옵션을 붙이는
것을 생각할 수 있습니다.

### 두 줄 이상의 자막을 한 줄로 만들기

한 문장이 두 줄 이상으로 이루어진 경우 구글 번역기 등으로 번역하면 독립된
문장으로 인식해 어색할 때가 많습니다. 다음과 같이 한 줄로 변경할 수 있습니다.

```
$ srttidy -1 -t < my.srt > text-to-translate.txt
```

### 파일 인코딩을 UTF-8으로 변경하기

`srttidy`는 기본적으로 작업 결과를 UTF-8으로 인코딩합니다. 따라서 아무런 옵션
없이 실행해도 인코딩은 UTF-8으로 바뀝니다.

```
$ srttidy < cp949.srt > utf-8.srt
$ srttidy < utf-16.srt > utf-8.srt
```

## 윈도우 사용자

마이크로소프트 윈도우 사용자는 [윈도우용 펄](https://strawberryperl.com)
또는 [WSL](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R?hl=en-us&gl=us)을 설치한 뒤 사용할 수 있습니다.
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

도스창에서는 위와 같이 명령해야 합니다. `c:\path-to`는 여러분이 `smi2srt`를 
복사한 경로입니다.

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

`srttidy`는 옵션이 많아서 조금 더 복잡합니다. 도스창의 인코딩을 UTF-8으로
바꾸고 펄을 실행할 때 별도의 옵션을 줘야 합니다.

```
c:\> chcp 65001
c:\> perl -CA c:\path-to\srttidy -n < my.srt
...
```

저런 식으로 수행해서 대부분이 제대로 작동했지만 `-g` 옵션의 한글 검색은
제대로 작동하지 않았습니다. 물론 제가 펄 언어를 처음 써서 생긴 문제이며 곧
고칠 수 있을지도 모릅니다. 하지만 현재로는 모든 기능을 충분히 활용하기 위해
WSL을 설치해서 사용하기를 권합니다.

이 문서는 맥이나 리눅스 환경을 가정해서 설명합니다.

## 마무리

앞서 밝혔듯이 대부분의 옵션은 조합해서 사용할 수 있습니다. 다양하게 시도해
보세요. 그리고 어떠한 질문이나 의견도 환영하니
[이슈 트래커](https://github.com/9beach/srt-tools/issues)에 남기시기 바랍니다.
