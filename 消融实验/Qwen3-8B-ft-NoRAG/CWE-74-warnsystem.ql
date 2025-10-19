import py

from FunctionCall call
where call.getName() in ("render_template", "render_template_string", "get_template")
  and call.getArgument(0).getType().isString()
  and call.getArgument(0).getOrigin() = py::userInput
select call, "Potential Server Side Template Injection"