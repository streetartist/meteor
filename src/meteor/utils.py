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
        if text[i] != "\\" or i + 6 > len(text):
            finalStr += text[i]
            i += 1
        elif text[i:i+2] == "\\u" and i + 6 <= len(text):
            # Try to parse \uXXXX format
            hex_part = text[i+2:i+6]
            try:
                finalStr += chr(int(hex_part, 16))
                i += 6
            except ValueError:
                finalStr += text[i]
                i += 1
        else:
            finalStr += text[i]
            i += 1

    return finalStr
