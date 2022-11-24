# srt-tools

`srt-tools`는 서브립(SubRip) 파일을 다양한 방식으로 수정하고, 변환하는 커맨드 라인 기반의 프로그램 모음입니다. 현재 `smi2srt`와 `srttidy`, 두 프로그램이 있습니다.

## 설치

맥이나 리눅스 사용자는 `smi2srt`, `srttidy` 두 파일을 실행 경로에 등록된 디렉터리에 복사하면 바로 사용할 수 있습니다.

마이크로소프트 윈도우 사용자는 [윈도우용 펄]을 설치한 뒤 사용하거나 앱스토어에서 [WSL](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R?hl=en-us&gl=us)을 설치한 뒤 사용할 수 있습니다.

WSL은 가상 윈도우 환경이라 맥이나 리눅스와 사용법이 동일합니다. 그러나 윈도우용 펄 환경은 몇 가지 차이가 있습니다.

```
$ smi2srt my.smi
created: my.srt
```

리눅스나 맥의 터미널에서 위와 같이 `smi2srt my.smi`라고 입력하면 `my.srt`파일이 생성됩니다.

```
c:\> perl c:\my-path-to\smi2srt my.smi
created: my.srt
```

윈도우 도스창에서는 위와 같이 명령해야 합니다. `c:\my-path-to`는 `smi2srt`가 실제로 복사된 주소로 고쳐야 합니다.

```
$ smi2srt *2020*/*.smi
```
위의 명령어는 2020이라는 글자가 들어간 디렉터리 안의 모든 smi 파일을 srt로 고칩니다. 윈도우에서는 `perl c:\my-path-to\smi2srt *2020*/*.smi`과 같은 명령이 작동하지 않습니다. 비슷한 일을 하려면 조금 더 복잡한 다른 방식이 있습니다. 이 부분은 따로 찾아보기 바랍니다. 이 문서는 주로 맥이나 리눅스 환경을 가정해서 설명합니다.

## smi2srt
