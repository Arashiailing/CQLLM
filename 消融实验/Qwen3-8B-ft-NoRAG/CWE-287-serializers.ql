import semmle.python.Python
import semmle.codeql.Python

from Class c
where c.hasSuperClass("django.core.serializers.base.Serializer")
  and (c.hasProperty("permission_classes") 
       and c.getProperty("permission_classes").valueIs("rest_framework.permissions.AllowAny")
       or not c.hasProperty("permission_classes"))
select c, "Potential CWE-287: Improper authentication in serializer - missing or incorrect permission configuration."