from decimal import Decimal
from typing import Optional, Any, Iterator

from meteor.grammar import *
from meteor.utils import *


class Token(object):
    def __init__(self, token_type: str, value: str, line_num: int, indent_level: int, value_type: str = None):
        self.type = token_type
        self.value = value
        self.value_type = value_type
        self.line_num = line_num
        self.indent_level = indent_level

    def __str__(self) -> str:
        return 'Token(type={type}, value={value}, line_num={line_num}, indent_level={indent_level})'.format(
            type=self.type,
            value=repr(self.value),
            line_num=self.line_num,
            indent_level=self.indent_level
        )

    __repr__ = __str__


class Lexer(object):
    def __init__(self, text: str, file_name: str):
        self.text = self.sanitize_text(text)
        self.file_name = file_name
        self.pos = 0
        self.current_char: Optional[str] = self.text[self.pos]
        self.char_type: Optional[str] = None
        self.word = ''
        self.word_type: Optional[str] = None
        self._line_num = 1
        self._indent_level = 0
        self.current_token: Token

    def next_char(self) -> None:
        self.pos += 1
        if self.pos > len(self.text) - 1:
            self.current_char = None
            self.char_type = None
        else:
            self.current_char = self.text[self.pos]
            self.char_type = self.get_type(self.current_char)

    @staticmethod
    def sanitize_text(text: str) -> str:
        if len(text) == 0:
            error('empty input')
        elif text[-1] != '\n':
            text += '\n'

        return text

    def reset_word(self) -> str:
        old_word = self.word
        self.word = ''
        self.word_type = None
        return old_word

    def peek(self, num: int) -> Optional[str]:
        peek_pos = self.pos + num
        if peek_pos > len(self.text) - 1:
            return None

        return self.text[peek_pos]

    # noinspection PyUnboundLocalVariable
    def preview_token(self, num: int = 1) -> Token:
        if num < 1:
            raise ValueError('Preview argument must be 1 or greater')
        next_token: Token
        current_pos = self.pos
        current_char = self.current_char
        current_char_type = self.char_type
        current_word = self.word
        current_word_type = self.word_type
        current_line_num = self.line_num
        current_indent_level = self.indent_level
        for _ in range(num):
            next_token = self.get_next_token()
        self.pos = current_pos
        self.current_char = current_char
        self.char_type = current_char_type
        self.word = current_word
        self.word_type = current_word_type
        self._line_num = current_line_num
        self._indent_level = current_indent_level
        return next_token

    def skip_whitespace(self) -> None:
        shouldIndent = False
        if self.peek(-1) == '\n':
            shouldIndent = True

        spaces = 0
        while self.current_char is not None and self.current_char in ' \t':
            self.next_char()
            self.reset_word()
            spaces += 1
            if spaces == 4 and shouldIndent:
                spaces = 0
                self.increment_indent_level()

        # Handle blank lines (lines with only spaces/tabs)
        # If we hit a newline after counting indentation, this is an empty line - skip it
        if self.current_char == '\n' and shouldIndent:
            # This is an empty line, reset and don't check indentation
            return

        if spaces != 0 and shouldIndent:
            error('file={} line={}: Indentation is locked to 4 spaces, found {} instead'.format(
                self.file_name, self.line_num, spaces))

    def skip_comment(self) -> Optional[Token]:
        while self.current_char != '\n':
            self.next_char()
            if self.current_char is None:
                return self.eof()
        # Don't consume the newline - let it be returned as a token
        # This ensures proper NEWLINE tokens after inline comments like "OK  # 200"
        return None

    def increment_line_num(self) -> None:
        self._line_num += 1

    @property
    def line_num(self) -> int:
        return self._line_num

    @property
    def indent_level(self) -> int:
        return self._indent_level

    def reset_indent_level(self) -> int:
        self._indent_level = 0
        return self._indent_level

    def decriment_indent_level(self) -> int:
        self._indent_level -= 1
        return self._indent_level

    def increment_indent_level(self) -> int:
        self._indent_level += 1
        return self._indent_level

    def eat_newline(self) -> Token:
        self.reset_word()
        token = Token(NEWLINE, '\n', self.line_num, self.indent_level)
        self.reset_indent_level()
        self.increment_line_num()
        self.next_char()
        return token

    def skip_indent(self) -> None:
        while self.current_char is not None and self.current_char == '\t':
            self.reset_word()
            self.increment_indent_level()
            self.next_char()

    def eof(self) -> Token:
        return Token(EOF, EOF, self.line_num, self.indent_level)

    @staticmethod
    def get_type(char: str) -> str:
        if char.isspace():
            return WHITESPACE
        elif char == '#':
            return COMMENT
        elif char == '\\':
            return ESCAPE
        elif char in OPERATORS:
            return OPERATIC
        elif char.isdigit():
            return NUMERIC

        return ALPHANUMERIC

    def get_next_token(self) -> Token:
        if self.current_char is None:
            return self.eof()

        if self.current_char == '\n':
            return self.eat_newline()

        elif self.current_char == '\t':
            self.skip_indent()

        if self.current_char in ' \t':
            self.skip_whitespace()

        # After skipping whitespace, check if we're now at a newline (blank line case)
        if self.current_char == '\n':
            return self.eat_newline()

        if self.current_char == '#':
            self.skip_comment()
            return self.get_next_token()

        if self.current_char == '"':
            # Check for triple-quoted string """..."""
            if self.peek(1) == '"' and self.peek(2) == '"':
                self.next_char()  # skip first "
                self.next_char()  # skip second "
                self.next_char()  # skip third "
                # Read until closing """
                while True:
                    if self.current_char == '"' and self.peek(1) == '"' and self.peek(2) == '"':
                        self.next_char()  # skip first "
                        self.next_char()  # skip second "
                        self.next_char()  # skip third "
                        break
                    if self.current_char == '\n':
                        self.increment_line_num()
                        self.reset_indent_level()
                    self.word += self.current_char
                    self.next_char()
                # After closing """, skip any remaining whitespace on this line (but not newline)
                while self.current_char is not None and self.current_char in ' \t':
                    self.next_char()
                return Token(STRING, self.reset_word(), self.line_num, self.indent_level)
            else:
                self.next_char()
                while self.current_char != '"':
                    if self.current_char == '\\' and self.peek(1) == '"':
                        self.next_char()
                    self.word += self.current_char
                    self.next_char()
                self.next_char()
                return Token(STRING, self.reset_word(), self.line_num, self.indent_level)

        if self.current_char == "'":
            self.next_char()
            while self.current_char != "'":
                if self.current_char == '\\' and self.peek(1) == "'":
                    self.next_char()
                self.word += self.current_char
                self.next_char()
            self.next_char()
            return Token(STRING, self.reset_word(), self.line_num, self.indent_level)

        if not self.char_type:
            self.char_type = self.get_type(self.current_char)
        if not self.word_type:
            self.word_type = self.char_type

        if self.word_type == OPERATIC:
            while self.char_type == OPERATIC:
                # Special handling for ! to avoid merging with . or other operators unless it's !=
                if self.word == '!' and self.current_char != '=':
                    break

                self.word += self.current_char
                self.next_char()
                if self.current_char in SINGLE_OPERATORS or self.word in SINGLE_OPERATORS:
                    break
            return Token(OP, self.reset_word(), self.line_num, self.indent_level)

        if self.word_type == ALPHANUMERIC:
            while self.char_type == ALPHANUMERIC or self.char_type == NUMERIC:
                self.word += self.current_char
                self.next_char()

            if self.word in OPERATORS:
                if self.word in MULTI_WORD_OPERATORS and self.preview_token(1).value in MULTI_WORD_OPERATORS:
                    self.next_char()
                    self.word += ' '
                    while self.char_type == ALPHANUMERIC or self.char_type == NUMERIC:
                        self.word += self.current_char
                        self.next_char()
                    return Token(OP, self.reset_word(), self.line_num, self.indent_level)

                return Token(OP, self.reset_word(), self.line_num, self.indent_level)

            if self.word in KEYWORDS:
                if self.word in MULTI_WORD_KEYWORDS and self.preview_token(1).value in MULTI_WORD_KEYWORDS:
                    self.next_char()
                    self.word += ' '
                    while self.char_type == ALPHANUMERIC or self.char_type == NUMERIC:
                        self.word += self.current_char
                        self.next_char()
                    return Token(KEYWORD, self.reset_word(), self.line_num, self.indent_level)

                return Token(KEYWORD, self.reset_word(), self.line_num, self.indent_level)

            elif self.word in TYPES:
                return Token(LTYPE, self.reset_word(), self.line_num, self.indent_level)
            elif self.word in CONSTANTS:
                return Token(CONSTANT, self.reset_word(), self.line_num, self.indent_level)

            return Token(NAME, self.utf8ToAscii(self.reset_word()), self.line_num, self.indent_level)

        if self.word_type == NUMERIC:
            base = 10
            while self.char_type == NUMERIC or (self.current_char == DOT and self.peek(1) != DOT) or \
                    self.current_char in ('a', 'b', 'c', 'd', 'e', 'f', 'x', 'o'):
                self.word += self.current_char
                if self.char_type == ALPHANUMERIC:
                    if self.current_char in ('b', 'x', 'o') and self.word.startswith('0') and len(self.word) == 2:
                        if self.current_char == 'b':
                            base = 2
                        elif self.current_char == 'x':
                            base = 16
                        elif self.current_char == 'o':
                            base = 8

                        self.word = ""
                    elif not (base == 16 and self.current_char in ('a', 'b', 'c', 'd', 'e', 'f')):
                        error("Unexpected number parsing")

                self.next_char()
            value: Any = self.reset_word()
            if '.' in value:
                value = Decimal(value)
                value_type = DOUBLE
            else:
                value = int(value, base)
                value_type = INT
            return Token(LNUMBER, value, self.line_num, self.indent_level, value_type=value_type)

        if self.char_type == ESCAPE:
            self.reset_word()
            self.next_char()
            line_num = self.line_num
            if self.current_char == '\n':
                self.increment_line_num()
            self.next_char()
            return Token(ESCAPE, '\\', line_num, self.indent_level)

        raise SyntaxError(f'Unknown character: {repr(self.current_char)} at line {self.line_num}')

    def analyze(self) -> Iterator[Token]:
        token = self.get_next_token()
        while token.type != EOF:
            yield token
            token = self.get_next_token()
        yield token

    @staticmethod
    def utf8ToAscii(string: str) -> str:
        unicode = "{!r}".format(string.encode("unicode_escape"))
        unicode = unicode[2:len(unicode) - 1]

        return unicode
