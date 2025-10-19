import py

from py.CallExpr, py.Variable
where
  call = py.CallExpr(py.Function("print"), [arg])
  arg is py.Variable
select call, "Potential reflected XSS due to direct output of user input."