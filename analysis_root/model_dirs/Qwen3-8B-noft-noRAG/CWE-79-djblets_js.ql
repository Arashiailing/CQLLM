import python
import semmle.code.cpp.dataflow.DataFlow

from MethodCall, Argument, Variable, FunctionDecl
where 
  // Find method calls that retrieve user input from HTTP requests (e.g., request.GET, request.POST)
  MethodCall.call(request.GET.get) or 
  MethodCall.call(request.POST.get) or 
  MethodCall.call(request.args.get) or 
  MethodCall.call(request.query_params.get) and
  
  // Extract the argument value passed to the GET/POST method
  Argument.arg(Variable.value) and
  
  // Track data flow from the input value to template rendering functions
  dataFlow::isSource(Variable, "userInput") and
  dataFlow::isSink(Variable, "templateRender", "htmlContent") and
  
  // Check if the data is not properly escaped (e.g., missing |safe filter in Django templates)
  not exists(FunctionDecl.decl("escape") and 
             FunctionDecl.calledOn(Variable))
select Variable, "Potential reflected XSS: User input is rendered directly into HTML without escaping."