# SRT-TOOLS

[한국어](README.ko-KR.md) | English

`srt-tools` is a collection of command-line programs that use LLM to translate [SubRip](https://en.wikipedia.org/wiki/SubRip) files (`.srt` extension), modify them in various ways, and convert them. Currently, `smi2srt`, `srttidy`, `srttrans`, and `srtmerge` are included.

## Installation

Mac or Linux users can copy the files to a directory registered in the execution path and grant execution permissions to use them immediately. Install as follows:

```
sudo curl -L https://raw.githubusercontent.com/9beach/srt-tools/main/smi2srt -o /usr/local/bin/smi2srt
sudo curl -L https://raw.githubusercontent.com/9beach/srt-tools/main/srttidy -o /usr/local/bin/srttidy
sudo curl -L https://raw.githubusercontent.com/9beach/srt-tools/main/srttrans -o /usr/local/bin/srttrans
sudo curl -L https://raw.githubusercontent.com/9beach/srt-tools/main/srtmerge -o /usr/local/bin/srtmerge
cd /usr/local/bin && sudo chmod a+rx srttidy smi2srt srtmerge srttrans
```

## `srttrans`

To use the AI subtitle translation feature with `srttrans`, you need to first install [llm-cli](https://github.com/9beach/llm-cli) and obtain API keys for the AI services. As of 2024, Google's Gemini API can be used for free, and DeepL also provides a free key with a monthly limit of 500,000 characters. Most LLM services have restrictions related to copyright or inappropriate expressions, so DeepL is the most suitable for subtitle translation purposes. Here's how to use it:

```sh
export DEEPL_API_KEY="your-api-key-here"
cat my-english.srt | srttrans deepl-cli KO > my-ko.srt
```

```sh
export GEMINI_API_KEY="your-api-key-here"
cat my-france.srt | srttrans gemini-cli ko > my-ko.srt
```
```sh
export ANTHROPIC_API_KEY="your-api-key-here"
cat my-brazil.srt | srttrans claude-cli hi > my-hi.srt
```

`ko` and `hi` are abbreviations for Korean and Hindi respectively. `deepl-cli` must use two-letter codes, while `gemini-cli` and `claude-cli` can also accept `Korean` and `Hindi`.

The environment variables `LT_LINES` and `LT_SLEEP_SEC` can be used to control the number of lines translated per request and the wait time between requests. `LT_LINES` sets the number of lines to translate in each request, and `LT_SLEEP_SEC` sets the wait time between each translation request.

```sh
export GEMINI_API_KEY="your-api-key-here"
export LT_LINES=100
export LT_SLEEP_SEC=5
cat my-france.srt | srttrans gemini-cli JP > my-japanese.srt
```

Even if you stop the translation process with <kbd>CTRL + C</kbd> because it takes too long, the translated parts will be saved in the file. However, in this case, not only the translated parts but also the untranslated parts will be saved together. This is to make it easy to find the untranslated parts. Now you can save the untranslated parts separately, complete the translation, and then use `srtmerge` to merge them.
While such cases are rare in `deepl-cli`, `gemini-cli` and `claude-cli` often refuse to translate some sentences for various reasons, making `srtmerge` useful at times.

## `srtmerge`

Use `srtmerge` when merging two files like the ones below.

**File a**

```
1
00:00:50,313 --> 00:00:52,478
안녕.

2
00:00:52,545 --> 00:00:54,043
-You okay?
-Person 4: You ready to go in?

3
00:00:54,109 --> 00:00:55,208
Let's go.
```

**File b**


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
안녕.

2
00:00:52,545 --> 00:00:54,043
-괜찮아요?
-사람 4: 들어갈 준비 됐어요?

3
00:00:54,109 --> 00:00:55,208
가자.
```

File `a` only merges the subtitles from file `b` that correspond to the numbers existing in file `a`. In other words, if file `a` does not have subtitles for numbers 2 and 3, it will not merge those subtitles from `b`. Please keep this in mind.

File b does not necessarily have to be in the subtitle format. The following format is also supported:

```txt
2%-
I didn't bring my wallet.
3%-
Again?
4%-
Hold on. I'll go get it.
Hurry up!
```

This format allows merging the lines back together based on the sequence number followed by the `%-` symbol, without requiring timestamps.

To use this for translation, you can remove the unnecessary parts, translate the text, and then merge the lines back together using the sequence numbers and `%-` symbols.

Here's the command to remove timestamps and automatically add the `%-` symbol after the sequence number:

```sh
cat org.srt | perl -0777 -pe 's/^\s*\n//mg; s/([0-9]+)\n([0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3})/$1%-/g'
```

## `smi2srt`

`smi2srt` is a command-line program that converts files in the [sami](https://en.wikipedia.org/wiki/sami) format to the [subrip](https://en.wikipedia.org/wiki/subrip) format. The basic usage is as follows:

```
$ smi2srt my.smi
created: my.srt
```

If you want to specify a name, command as follows:


```
smi2srt < my.smi > new.srt
```

Note that it's `smi2srt < my.smi > new.srt`, not `smi2srt my.smi > new.srt`.
If you command as follows, it will output to the screen without saving to a file.

```
smi2srt < my.smi
```

If you don't want to specify the name of the file to be saved directly, use it without `<`. In this case, you can convert many files at once.

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

`srttidy` is a command-line program that supports various tasks such as synchronizing the timing of [SubRip](https://en.wikipedia.org/wiki/SubRip) files and modifying timestamps. It provides various features necessary for subtitle translation, such as selecting and adjusting the timing of subtitles that have insufficient display time compared to the number of characters.

Let's explain each feature based on the following help message.


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

The following `my.srt` will be used as an example.


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

### Extracting text only

The `-t` option extracts only the text from the subtitles.

```
$ srttidy -t < my.srt
Lolita, light of my life,
fire of my loins. My sin, my soul.
Lo-lee-ta:
the tip of the tongue taking a trip of
three steps down the palate to tap,
at three, on the teeth. Lo. Lee. Ta.
```

Compare the two commands below.

```
$ srttidy -t my.srt
created: my-tidy.txt
```

```
srttidy -t < my.srt > my.txt
```

If you put the `<` symbol before the file, the result will be output to the screen. If you want to save the output result to a file instead of the screen, specify the name of the file to be saved after the `>` symbol. If you run it without the `<` symbol, it creates a new file with the name `-tidy` appended.

If you want to extract only the text from SAMI, not SubRip, run the following.

```
smi2srt < my.smi | srttidy -t
```

### Changing the default subtitle color

If the white subtitle color is bothersome and you want to change it to `silver` or `gray`, run the following command:

```
$ srttidy -c silver my.srt
created: my-tidy.srt
$ srttidy -c gray < my.srt > new.srt
```

Of course, it does not change subtitles that already have a color specified. It only changes the default white color to the desired color.

If you run `srttidy -c gray < my.srt > my.srt`, it will erase the contents of the existing file, which is not the intention of replacing the existing file. `srttidy -c gray < my.srt`
It is because an empty file is created first with the `> my.srt` command before executing the command. You should run it as follows:

```
srttidy -c gray < my.srt > tmp.srt && [ -s tmp.srt ] && mv tmp.srt my.srt
```

To remove the specified color with `srttidy` and restore it to its original state, run it as follows:

```
$ srttidy -r my-tidy.srt
created: my-tidy-tidy.srt
```

```
srttidy -r < my-tidy.srt > my-org.srt
```

## Adjusting subtitle sync

If the subtitles appear earlier than the video and you want to delay them by 2.1 seconds, run the following:

```
srttidy -s 2.1 < my.srt > new.srt
```

Conversely, if you want to move them forward, run it like this:

```
srttidy -s -9.2 < my.srt > new.srt
```

Sometimes, the sync of the subtitles is off by about 3 seconds in the beginning, but the difference decreases to 0.6 seconds as the video progresses. In this case, you can measure through observation, but you can also find a well-synced English subtitle and compare the timestamps of the Korean and English subtitles at one scene each in the first and second half of the video to know for sure. In such cases, you can linearly correct the sync by using the following command:

```
srttidy -l "00:00:19,145-00:00:22,189 02:39:17,715-02:39:18,390" my.srt
```

If the sync of the subtitles gradually shifts, there is also a method of converting the frame rate in addition to the above method.

```
srttidy -p "23.976-24" my.srt 
```

### Correcting subtitle numbers

Here is the English translation:

During the translation process, there may be cases where the order of the subtitle numbers is incorrect due to reasons such as merging two short lines of dialogue. In the `my.srt` above, the text of the first subtitle is empty and the subtitle numbers jump from 4 to 6, so the order is incorrect. In this case, it is corrected as follows:

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

### Indent cleanup


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

Such subtitles can be neatly cleaned up with the `-y` option.

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

## Combinations of options

Most options can be used in combination.

```
srttidy -n -l "00:00:19,145-00:00:22,189 02:39:17,715-02:39:18,390" my.srt
srttidy -n -c gray < my.srt > new.srt 
srttidy -s -9.2 -c gray < my.srt > new.srt
srttidy -r -n < my.srt > new.srt
```

### Searching subtitles by keywords

If you only want to see subtitles containing the word `the`, use the following command:

```
srttidy -g the < my.srt
```

Because it doesn't have case sensitivity, the above result shows subtitles containing the word "THE".
If you want to expand the search criteria to include "the" or "my", you can runthe following command:

```
srttidy -g '(the|my)' < my.srt
```

The search criteria supports [regular expressions](https://en.wikipedia.org/wiki/Regular_expression). They are quite powerful, so we recommend you search for them separately. Here we will introduce only a few key features.

- `-g '(dog|cat)'` will show subtitles containing either `dog` or `cat`.
- `.` means any character. A period is represented as `\.`. So, `-g '이.해'` will show subtitles containing words like "이동해" and "이상해", and `-g '(,|\.)'`will show subtitles containing either a comma or a period.
- `*` means the character preceding it is repeated zero or more times. So, `-g 'dog.*cat'` will show subtitles where `dog` and `cat` appear consecutively, suchas `dogcat`, `dog cat`, and `dog and cat`.


### Deleting subtitles by keyword

To delete only the subtitles containing the word `sub2smi`, use the following command:

```
srttidy -d sub2smi < my.srt
```

The `-n` option described above, when combined, deletes and then sequentially corrects the subtitle numbers.

```
srttidy -n -d sub2smi < my.srt
```

Like the `-g` option, it supports regular expressions.

```
srttidy -g '(,|\.|\?)' < my.srt | srttidy -d '\.\.\.'
```

Executing as above shows subtitles containing periods, commas, or question marks, excluding subtitles with "...".

### Searching subtitles by character count, line count, and display time

`cc`, `lc`, and `dt` represent character count, line count, and display time, respectively. Let's look at the following execution examples.


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

You can also use parentheses to construct complex conditions, like `'(lc=1 and cc>=15) or cc>20 or dt>3.5'`.

### Adjusting display time

Sometimes subtitles may pass too quickly to read. You can use the `-m` option to specify a minimum display time for subtitles, increasing their duration. Consider the following example:

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

Blank subtitles have been removed with the `-n` option, and the minimum displaytime has been set to 4.5 seconds and the minimum gap to the next subtitle to 0.1 seconds with the `-m '4.5,0.1'` option. The corrected subtitles are saved in the `new.srt` file as a result of the execution, and the execution history is displayed on the screen. Let's see from the first line.

```
* 1 1,19: SHORT/FIXED BUT SHORT (0.100 -> 4.000)
```

`1 1,19` means that the first subtitle has 1 line and 19 characters.
`SHORT/FIXED BUT SHORT (0.100 -> 4.000)` means that the display time was originally 0.100 seconds, and we wanted to increase it to 4.5 seconds, but to avoid overlap with the next subtitle, we increased it to the maximum possible value of 4.000 seconds.

```
* 2 1,24: SHORT/FIXED (0.575 -> 4.500)
...
* 3 1,7: SHORT/FIXED (2.000 -> 4.500)
```

### Adjusting display time only for subtitles that meet certain conditions

By adding additional conditions to the `-m` option, you can adjust the display time only for subtitles that meet those conditions.

The following example sets the minimum display time to
The minimum display time for subtitles with 20 or more characters and one line is set to 2 seconds.

```
$ srttidy -m '2,0.1;lc=1 and cc>=15 and cc<=20' < my.srt > new.srt
* 2 1,19: SHORT/FIXED (0.100 -> 2.000)
  00:00:30,900 --> 00:00:31,000
  Lolita, light of my life,
```

Second and third subtitles, originally short, were changed to 4.5 seconds, resulting in a `SHORT/FIXED` display.

```
* 4 2,58: OVERLAPPED/FIXED (5.469 -> 4.900)
```

The 4th subtitle, consisting of two lines and 58 characters, had an end time that was later than the start time of the 5th subtitle, resulting in an overlap. This was corrected. Such errors are fixed by maximizing non-overlapping time, notby using the reference time. Therefore, it was corrected to 4.9 seconds, not 4.5 seconds.

If the performance history shows frequent consecutive short subtitles, considermerging short subtitles to create two-line subtitles instead of increasing the minimum display time.

### Correcting the display time of only subtitles that meet the conditions

You can specify additional conditions with the `-m` option to adjust the display time of only the subtitles that meet the conditions.

The following example sets the minimum display time of subtitles with 15 to 20 characters and one line to 2 seconds.

```
$ srttidy -m '2,0.1;lc=1 and cc>=15 and cc<=20' < my.srt > new.srt
* 2 1,19: SHORT/FIXED (0.100 -> 2.000)
  00:00:30,900 --> 00:00:31,000
  Lolita, light of my life,
```

The minimum display time for captions with more than 20 characters and a singleline is set to 3 seconds.

```
$ srttidy -m '3,0.1;lc=1 and cc>=20' < my.srt > new.srt
* 3 1,24: SHORT/FIXED (0.575 -> 3.000)
  00:00:35,000 --> 00:00:35,575
  fire of my loins. My sin, my soul.

* 7 1,24: SHORT/FIXED (0.635 -> 3.000)
  00:00:50,000 --> 00:00:50,635
  at three, on the teeth. Lo. Lee. Ta.
```

### Removing byte order mark and carriage return

Although not visible to the user, sometimes the [Byte Order Mark](https://en.wikipedia.org/wiki/Byte_order_mark) can cause problems. The `-b` option can be used to remove it.

```
srttidy -b < old.srt > new.srt
```

Running it like this will also remove the [carriage return](https://en.wikipedia.org/wiki/Carriage_return). This is generally a function you don't need to know about, but if you don't want carriage returns to be attached to your files, you canconsider adding the `-b` option as a habit when working with other options.

### Combining multiple lines of subtitles into one line

When a sentence spans multiple lines, translation tools like Google Translate often recognize it as separate sentences, leading to awkward results. You can change it to a single line as follows:

```
srttidy -1 -t < my.srt > text-to-translate.txt
```

### Change file encoding to UTF-8

By default, `srttidy` encodes the work result in UTF-8. Therefore, even if you run it without any options, the encoding will be changed to UTF-8.

```
srttidy < cp949.srt > utf-8.srt
srttidy < utf-16.srt > utf-8.srt
```

## Windows users

Microsoft Windows users can install [Perl for Windows](https://strawberryperl.com)
or [WSL](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R?hl=en-us&gl=us) and then use it.
WSL is a virtual Linux environment, so it works the same as Mac or Linux. However, there are a few differences for the Windows version of Perl.

```
$ smi2srt my.smi
created: my.srt
```

If you enter the above command in a Linux or Mac terminal, the `my.srt` file will be created. To run the command in a DOS window:

```
c:\> perl c:\path-to\smi2srt my.smi
created: my.srt
```

Replace `c:\path-to` with the actual path where you copied `smi2srt`.

```
$ smi2srt *.smi
created: 1.srt
created: 2.srt
...
```

`srttidy` is a bit more complex due to its many options. You need to change theencoding of the DOS window to UTF-8 and provide separate options when running Perl.

```
c:\> chcp 65001
c:\> perl -CA c:\path-to\srttidy -n < my.srt
...
```

I followed that procedure and most of it worked properly, but the Korean searchwith the `-g` option didn't work.  Of course, this is likely due to my inexperience with Perl, and I might be able to fix it soon. However, for now, I recommend installing and using WSL to fully utilize all the features.

This document assumes a Mac or Linux environment.

## Conclusion

As mentioned earlier, most of the options can be used in combination.  Try different combinations.  Any questions or comments are welcome, please leave them onthe [issue tracker](https://github.com/9beach/srt-tools/issues).
