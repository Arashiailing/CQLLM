import python
import semmle.code.java.dataflow.DataFlow

from Call call, Argument arg
where 
  call.getCalleeName() = "jinja2.Environment.render_template_string" and
  arg.getIndex() = 0 and
  exists(Source source | source.getLocation() = arg.getValue().getLocation())
select call, "Potential Server Side Template Injection detected: User-controlled data is directly used in template rendering."