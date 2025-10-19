import semmle.code.py.Python

from ListExpr list, IndexExpr index
where index.getBase() = list
select index, "Potential buffer overflow due to out-of-bounds access."