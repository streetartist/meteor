import sys


def error(text: str) -> None:
    print(u'\033[{}m{}\033[0m{}'.format("31;1", "[-] Error: ",
          asciiToUnicode(text)), file=sys.stderr)
    sys.exit(1)


def warning(text: str) -> None:
    print(u'\033[{}m{}\033[0m{}'.format("33;1", "[!] Warning: ",
          asciiToUnicode(text)), file=sys.stderr)


def successful(text: str) -> None:
    print(u'\033[{}m{}\033[0m{}'.format("32;1", "[+] Success: ",
          asciiToUnicode(text)), file=sys.stderr)


def asciiToUnicode(text: str) -> str:
    finalStr = ""
    i = 0
    while i < len(text):
        if text[i] != "\\":
            finalStr += text[i]
            i += 1
        else:
            curUni = "0x"
            for j in range(i + 3, i + 7):
                curUni += text[j].upper()
            finalStr += chr(int(curUni, 16))
            i += 7

    return finalStr
