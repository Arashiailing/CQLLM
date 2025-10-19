/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity high
 * @precision high
 * @id py/fckdialog
 * @tags security
 *       external/cwe/cwe-079
 */

import python
import experimental.fckdialog.FCKDialogInjection
import FCKDialogInjectionFlow::PathGraph
from FCKDialogInjectionFlow::PathNode source, FCKDialogInjectionFlow::PathNode sink
where FCKDialogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "FCK Dialog injection occurs via $@", source.getNode(), "user-provided value"