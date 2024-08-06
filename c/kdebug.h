#ifndef TSET_KDEBUG_H
#define TSET_KDEBUG_H

#ifndef TSET_KLOG_PREFIX
#define TSET_KLOG_PREFIX		"TSET"
#endif

#define pd_info(fmt, ...)						\
	printk(KERN_INFO "%s: %s:%d "fmt"\n",				\
	       TSET_KLOG_PREFIX, __func__, __LINE__, ##__VA_ARGS__)

#define pd_err(fmt, ...)						\
	printk(KERN_ERR "%s: %s:%d ***ERROR*** "fmt"\n",		\
	       TSET_KLOG_PREFIX, __func__, __LINE__, ##__VA_ARGS__)

#endif /* TSET_KDEBUG_H */
