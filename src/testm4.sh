# ifndef([TEMPDIR], 'something')
# ifelse(TEMPDIR, [yolo], 'its yolo', 'its not yolo')
traceon
TEMPDIR
ifndef([TEMPDIR], 'yolo')
