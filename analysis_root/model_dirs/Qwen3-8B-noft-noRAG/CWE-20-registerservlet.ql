```ql
import semmle.codeql.python.Python

from Call site call, BinaryOp binop, StringLiteral str_lit, Variable var