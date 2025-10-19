/**
 * @deprecated
 */

import python
import semmle.python.ApiGraphs

from API::CallNode apiCall, string protocolName
where
  (
    apiCall = API::moduleImport("urllib").getMember("urlretrieve").getACall()
    and
    protocolName = "ftp"
  )
  or
  (
    apiCall = API::moduleImport("ftplib").getMember("FTP").getReturn().getAValueReachableFromSource()
     .asExpr()
     .(ImmutableLiteral)
     .getText()
      = "localhost"
    and
    protocolName = "ftp"
  )
  or
  (
    apiCall = API::moduleImport("os").getMember("path").getMember("realpath").getACall()
    and
    protocolName = "file"
  )
select apiCall, "This link handling operation follows '" + protocolName + "' links."