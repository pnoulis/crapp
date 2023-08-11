<<<<<<< HEAD
#!/usr/bin/env bash
# changequote([,])
# define([ifndef], [ifdef([$1], [$1], [define([$1], [$2])])])
# define([ifndef2], [ifdef([$1], [$1], [$2])])
# ifndef2([YOLo], define(YOLo, 'color'))
# YOLo

# # expands as many times as neccessary each token

# # transfrom the argument into a variable assignment
# # statement. The argument becomes the variable name
# # which is then capitalized and appended with the prefix
# # GNULIB_
# define([gl_STRING_MODULE_INDICATOR],
#       [
#           dnl comment
#           GNULIB_]translit([$1],[a-z],[A-Z])[=1
#       ])dnl

# gl_STRING_MODULE_INDICATOR([strcase])


define([gl_STRING_MODULE_INDICATOR],
      [
          dnl
          GNULI_])
yololo
gl_STRING_MODULE_INDICATOR

define([gl_STRING_MODULE_INDICATOR], [GNULIB_]translit($1,[a-z],[A-Z]))

gl_STRING_MODULE_INDICATOR('strlib') # -> GNULIB_strlib

=======
# ifndef([TEMPDIR], 'something')
# ifelse(TEMPDIR, [yolo], 'its yolo', 'its not yolo')
traceon
TEMPDIR
ifndef([TEMPDIR], 'yolo')
>>>>>>> a21a201370b1372dda7264805bd72b1ae1f09d7b
