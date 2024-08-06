#ifndef TSET_FILE_H
#define TSET_FILE_H

#include <dirent.h>
#include <string.h>

static inline struct dirent *ts_readdir(DIR *dp)
{
	struct dirent *d;

	while ((d = readdir(dp))) {
		if (!strcmp(d->d_name, ".") ||
		    !strcmp(d->d_name, ".."))
			continue;
		break;
	}

	return d;
}

#endif /* TSET_FILE_H */
