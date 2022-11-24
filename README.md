# srt-tools

`srt-tools`는 서브립(SubRip) 파일을 다양한 방식으로 수정하고, 변환하는 커맨드
라인 기반의 프로그램 모음입니다. 현재 `smi2srt`와 `srttidy`, 두 프로그램이
있습니다.

## 설치

맥이나 리눅스 사용자는 `smi2srt`, `srttidy` 두 파일을 실행 경로에 등록된
디렉터리에 복사하고 실행권한(`chmod`)을 주면 바로 사용할 수 있습니다.

마이크로소프트 윈도우 사용자는 [윈도우용 펄](https://strawberryperl.com)을
설치하거나, 앱스토어에서 [WSL](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R?hl=en-us&gl=us)을 설치한 뒤 사용할 수 있습니다.

WSL은 가상 리눅스 환경이라 맥이나 리눅스와 사용법이 동일합니다. 그러나 윈도우용
펄은 몇 가지 차이가 있습니다.

```
$ smi2srt my.smi
created: my.srt
```

리눅스나 맥의 터미널에서 위와 같이 `smi2srt my.smi`라고 입력하면 `my.srt`파일이
생성됩니다.

```
c:\> perl c:\my-path-to\smi2srt my.smi
created: my.srt
```

도스창에서는 위와 같이 명령해야 합니다. `c:\my-path-to`는 `smi2srt`가 실제로
복사된 주소로 고치세요.

```
$ smi2srt *2020*/*.smi
```
위의 명령어는 `2020`이라는 글자가 들어간 디렉터리 안의 모든 `smi` 파일을 
`srt`로 고칩니다. 윈도우에서는 `perl c:\my-path-to\smi2srt *2020*\*.smi`과 같이 명령하면 작동하지 않습니다. 조금 더 복잡한 다른 방식이 있으니, 이 부분은 따로
찾아보기 바랍니다. 이 문서는 주로 맥이나 리눅스 환경을 가정해서 설명합니다.

## smi2srt

`smi2srt`는 [SAMI](https://ko.wikipedia.org/wiki/SAMI) 포맷의 파일을 [SubRip](https://en.wikipedia.org/wiki/SubRip) 포맷으로 변경하는 커맨드 라인
프로그램입니다.

```
$ smi2srt my.smi
created: my.srt
```

이름을 지정하고 싶으면 다음과 같이 명령하세요.

``` $ smi2srt < my.smi > new.srt
```

`smi2srt my.smi > new.srt`가 아니라 `smi2srt < my.smi > new.srt`임에 주의하세요.

다음과 같이 명령하면 파일로 저장하지 않고 화면에 출력합니다.

```
$ smi2srt < my.smi
```

한꺼번에 많은 파일을 변환할 수도 있습니다.

```
$ smi2srt 1.smi 2.smi 100.smi
created: 1.srt
created: 2.srt
created: 100.srt
```

```
$ smi2srt *.smi
```
