import python
import semmle.code.java.dataflow.DataFlow

from PrintStatement ps, StringConcatenation sc, CallExpr ce
where 
  ps = getPrintStatement(ce) and 
  sc = getStringConcatenation(ps) and 
  exists(UserInputSource uis | uis.getInputSource(sc)) and 
  exists(HttpResponseOutput hro | hro.isHttpResponseOutput(ps))
select ps, "Potential reflected XSS: User input is directly output in HTTP response"