import python

/**
 * Query for detecting CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization
 */
from Method m, Call c
where m.name = "some_shared_resource_access" and
      c.getTarget().getKind() = "write" and
      not (exists Call c2 | c2.getTarget().getKind() = "lock_acquire" and
           c2.getLoc().getFile() = c.getLoc().getFile() and
           c2.getLoc().getLine() < c.getLoc().getLine() and
           exists Call c3 | c3.getTarget().getKind() = "lock_release" and
           c3.getLoc().getFile() = c.getLoc().getFile() and
           c3.getLoc().getLine() > c.getLoc().getLine())
select m, "Potential CWE-362: Shared resource accessed without proper synchronization"