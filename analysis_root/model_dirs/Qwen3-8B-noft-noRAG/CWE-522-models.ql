import python

from StringLiteral s, Assignment a
where a.getTarget().getName().matches("^[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|^[Ss][Ee][Cc][Rr][Ee][Tt]|[Kk][Ee][Yy]|[Tt][Oo][Kk][Ee][Nn]|[Aa][Pp][Ii]_[Kk][Ee][Yy]$") and a.getRHS() = s
select s, "Cleartext credentials stored in code."