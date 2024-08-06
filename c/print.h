#ifndef TSET_PRINT_H
#define TSET_PRINT_H

#include "list.h"

struct ts_print_cell {
	struct list_head link;
	char *data;
};

struct ts_print_column {
	struct list_head link;
	char *title;
	int cells;
	int width;
	struct ts_print_cell *curr_cell;
	struct list_head all_cell;
};

struct ts_print_table {
	int columns;
	int max_rows;
	struct list_head all_column;
};

struct ts_print_table *ts_print_init_table(char *header);
void ts_print_free_table(struct ts_print_table *table);
void ts_print_show_table(struct ts_print_table *table);
int ts_print_insert_cell(struct ts_print_table *table,
			 const char *title, const char *data);

#endif /* TSET_PRINT_H */
