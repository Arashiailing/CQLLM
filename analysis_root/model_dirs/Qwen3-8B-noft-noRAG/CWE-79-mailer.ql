import python
import semmle.code.cpp.dataflow.DataFlow

from Method m, StringLiteral s, Call c
where 
  m.hasName("send_response") and 
  c = m.getCall().getArgument(0) and 
  c.isStringConcatenation() and 
  s = c.getStringLiteral() and 
  s.getValue() = "<html>" and 
  exists (InputFunction inputFunc, Call inputCall |
    inputFunc = InputFunction.get() and 
    inputCall = inputFunc.getCall() and 
    inputCall.getArgument(0).isString() and 
    inputCall.getArgument(0).getStringValue().matches(".*[a-zA-Z0-9].*") and 
    dataflowsFrom(inputCall.getArgument(0), c)
  )
select m, "Potential reflected XSS vulnerability detected: user input is directly concatenated into HTML response."