# srt-tools

`srt-tools`는 서브립(SubRip) 파일을 다양한 방식으로 수정하고 변환하는 커맨드
라인 기반의 프로그램 모음입니다. 현재 `smi2srt`와 `srttidy`, 두 프로그램이
있습니다.

## 설치

맥이나 리눅스 사용자는 `smi2srt`, `srttidy` 두 파일을 실행 경로에 등록된
디렉터리에 복사하고 실행권한을 주면(`chmod +x smi2srt srttidy`) 바로 사용할
수 있습니다.

마이크로소프트 윈도우 사용자는 [윈도우용 펄](https://strawberryperl.com)을
설치하거나, 앱스토어에서 [WSL](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R?hl=en-us&gl=us)을 설치한 뒤 사용할 수 있습니다.

WSL은 가상 리눅스 환경이라 맥이나 리눅스의 터미널과 사용법이 동일합니다. 그러나
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

도스창에서는 위와 같이 명령해야 합니다. `c:\path-to`는 `smi2srt`가 실제로
복사된 경로입니다.

```
$ smi2srt *2020*/*.smi
```
위와 같이 실행하면 `2020`이라는 글자가 들어간 디렉터리 안의 모든 `smi` 파일을 
`srt`로 고칩니다. 윈도우에서는 다음과 같이 명령해야 합니다.

```
cd working-dir
for %a in ("*.smi") do perl C:\path-to\smi2srt %a
```
이 밖에도 터미널 인코딩 등 다양한 차이가 있으니 가급적 WSL을 설치해서
사용하세요. 이 문서는 주로 맥이나 리눅스 환경을 가정해서 설명합니다.

## smi2srt

`smi2srt`는 [SAMI](https://ko.wikipedia.org/wiki/SAMI) 포맷의 파일을 [SubRip](https://en.wikipedia.org/wiki/SubRip) 포맷으로 변경하는 커맨드 라인
프로그램입니다.

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

한꺼번에 많은 파일을 변환할 수도 있습니다.

```
$ smi2srt 1.smi 2.smi 3.smi
created: 1.srt
created: 2.srt
created: 3.srt
```

```
$ smi2srt */*.smi
```
## srttidy

`srttidy`는 [SubRip](https://en.wikipedia.org/wiki/SubRip) 파일의 싱크를 맞추고
타임스탬프를 수정하는 등 다양한 작업을 지원하는 커맨드 라인 프로그램입니다.
특히 글자 수에 비해 표시 시간이 적은 자막만을 골라서 타임스탬프를 자동으로 
수정하는 등 자막 번역을 하는 분을 위한 강력한 기능을 제공합니다.

다음 자막을 예로 들어 설명합니다.

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
```

### 텍스트만 추출

`-t` 옵션은 자막에서 텍스트만 추출합니다.

```
$ srttidy -t < my.srt
Lolita, light of my life,
fire of my loins. My sin, my soul.
Lo-lee-ta:
```

아래의 두 명령과 비교해 보세요.

```
$ srttidy -t my.srt
created: my-tidy.txt
```

```
$ srttidy -t < my.srt > my.txt
```

`<` 기호를 파일 앞에 붙이면 결과를 화면에 출력합니다. 출력된 결과를 파일로 저장하고 싶으면 `>` 기호 뒤에 저장할 파일 이름을 지정합니다. `<` 기호 없이 파일을 
주면 `-tidy` 이름을 붙여서 새로운 파일을 만듭니다.

SAMI 파일의 텍스트만 추출하고 싶다면 다음을 실행합니다.
```
$ smi2srt < my.smi | srttidy -t
Lolita, light of my life,
fire of my loins. My sin, my soul.
Lo-lee-ta:
```

### 기폰 폰트 색깔 변경

기본인 하얀 색 폰트가 눈에 거슬려 `silver`나 `gray`로 고치고 싶다면 다음과 같이
실행합니다.

```
$ srttidy -c silver my.srt
created: my-tidy.srt
$ srttidy -c silver < my.srt > my.srt
```

물론 미리 색깔이 지정된 폰트는 변경되지 않습니다. 기본인 하얀 색만 원하는 색깔로
변경됩니다.

`srttidy`로 지정한 색깔을 없애고 원상 복귀하려면 다음과 같이 실행합니다.

```
$ srttidy -r my-tidy.srt
created: my-tidy-tidy.srt
$ srttidy -c silver < my-tidy.srt > my-org.srt
```

### 자막 싱크 조절



	
