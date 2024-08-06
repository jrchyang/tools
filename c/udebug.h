#ifndef TSET_UDEBUG_H
#define TSET_UDEBUG_H

#include <stdio.h>
#include <syslog.h>

#ifndef TSET_ULOG_PREFIX
#define TSET_ULOG_PREFIX		"TSET"
#endif

#define pd_info(fmt, ...)						\
	do {								\
		fprintf(stdout, "%s: %s:%d "fmt"\n", TSET_ULOG_PREFIX,	\
			__func__, __LINE__, ##__VA_ARGS__);		\
		syslog(LOG_INFO, "%s: %s:%d "fmt"\n", TSET_ULOG_PREFIX,	\
			__func__, __LINE__, ##__VA_ARGS__);		\
	} while (0)

#define pd_err(fmt, ...)						\
	do {								\
		fprintf(stderr, "%s: %s:%d ***ERROR*** "fmt"\n",	\
			TSET_ULOG_PREFIX, __func__, __LINE__,		\
			##__VA_ARGS__);					\
		syslog(LOG_ERR, "%s: %s:%d ***ERROR*** "fmt"\n",	\
			TSET_ULOG_PREFIX, __func__, __LINE__,		\
			##__VA_ARGS__);					\
	} while (0)

#endif /* TSET_UDEBUG_H */
