import python

/**
 * This query detects CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition').
 */

class SharedResource {
  SharedResource() {
    exists(File f | f.getName() = "shared_resource.txt")
  }
}

class ConcurrentAccess {
  ConcurrentAccess() {
    exists(Function f | f.getName() = "access_resource")
  }
}

class RaceCondition extends ConcurrentAccess {
  RaceCondition() {
    exists(SharedResource sr, Call call |
      call.getCallee().getName() = "modify_resource" and
      call.getCaller().getName() = "access_resource" and
      call.getCaller().getEnclosingClass().getName() = "ResourceHandler"
    )
  }
}

from RaceCondition rc
select rc, "This code may be vulnerable to CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition')."