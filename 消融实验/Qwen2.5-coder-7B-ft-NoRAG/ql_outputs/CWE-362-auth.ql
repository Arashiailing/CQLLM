/**
 * @name CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition')
 * @id py/auth
 */

import python

import Concurrency::Thread
import Concurrency::Lock

from Thread thread1, Thread thread2, Lock lock
where
  thread1.join() and
  thread2.join() and
  thread1.hasLock(lock) and
  thread2.hasLock(lock) and
  thread1!= thread2
select thread1, thread2, lock, "Potential race condition detected between threads accessing a shared resource."