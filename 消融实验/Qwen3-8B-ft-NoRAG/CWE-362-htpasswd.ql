import py

from Write w
where (w.getVar().isGlobal() or w.getVar().isClassVar())
and not exists (Lock l | l.uses(w))
select w, "Potential race condition due to shared resource modification without synchronization"