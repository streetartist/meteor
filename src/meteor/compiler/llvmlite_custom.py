from llvmlite import ir

# Int
Old_IntType: ir.Type = ir.types.IntType


class _IntType(Old_IntType):
    """
    The type for integers.
    """
    null = '0'
    _instance_cache: dict = {}
    signed = True

    def __new__(cls, bits, signed=True):
        signature = (bits, signed)
        if 0 <= bits <= 128:
            try:
                return cls._instance_cache[signature]
            except KeyError:
                inst = cls._instance_cache[signature] = cls.__new(*signature)
                return inst
        return cls.__new(*signature)

    @classmethod
    def __new(cls, bits, signed):
        assert isinstance(bits, int) and bits >= 0
        self = super(Old_IntType, cls).__new__(cls)  # pylint: disable=E1003
        self.width = bits
        self.signed = signed
        self.v_id = f'{"i" if self.signed else "u"}{self.width}'
        return self


ir.types.IntType = _IntType
ir.IntType = _IntType
