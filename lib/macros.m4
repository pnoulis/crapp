changequote([,])

define([ifempty], [ifelse([$1], [], [$2], [$1])])
define([ifndef], [ifdef([$1], [ifempty($1, $2)], [$2])])

