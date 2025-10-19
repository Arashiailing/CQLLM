import python

/**
 * @name CWE-276: Incorrect Default Permissions
 * @description Detects instances where tar extraction may lead to directory traversal.
 * @id py/sos_collector
 */

class TarSlipQuery extends SecurityQuery {
  TarSlipQuery() {
    exists(Call call, Argument arg |
      call.getCallee().getName() = "tar" and
      call.getCallee().getModule().getName() = "tarfile" and
      arg = call.getArgument(0) and
      arg instanceof StringLiteral and
      arg.getStringValue().matches("%.*%")
    )
  }
}