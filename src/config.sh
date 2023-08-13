export TEMPLATESROOTDIR=__TEMPLATESROOTDIR__
export TEMPDIR=__TEMPDIR__
export CRAPPTEMPDIR=__TEMPDIR__/crapp

# crapp is needed in $PATH by templates
# In production that is not problem since
# the program is expected to have been installed
# But in development it is
export CRAPP=__CRAPP__
