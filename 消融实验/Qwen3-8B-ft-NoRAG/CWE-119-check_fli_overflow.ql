import python

from String s, Int i
where s[i]
and (i >= s.length() or i < -s.length())
select i, "Potential buffer overflow due to out-of-bounds index access"

from List l, Int i
where l[i]
and (i >= l.length() or i < -l.length())
select i, "Potential buffer overflow due to out-of-bounds index access"