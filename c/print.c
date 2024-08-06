#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include "print.h"
#include "udebug.h"
#include "list.h"

void tsp_free_cell(struct ts_print_cell *cell)
{
	if (cell->data) {
		free(cell->data);
		cell->data = NULL;
	}

	free(cell);
	cell = NULL;
}

void tsp_free_column(struct ts_print_column *col)
{
	list_free(&col->all_cell, struct ts_print_cell, link, tsp_free_cell);
	if (col->title) {
		free(col->title);
		col->title = NULL;
	}

	free(col);
	col = NULL;
}

void ts_print_free_table(struct ts_print_table *table)
{
	list_free(&table->all_column, struct ts_print_column, link, tsp_free_column);
	free(table);
	table = NULL;
}

void ts_print_show_table(struct ts_print_table *table)
{
	int row;
	struct ts_print_column *col;
	struct ts_print_cell *cell;

	for (row = 0; row < table->max_rows; ++row) {
		list_for_each_entry(col, &table->all_column, link) {
			if (row == 0) {
				printf("%-*s  ", col->width, col->title);
				continue;
			}

			if (row > col->cells) {
				printf("%-*s  ", col->width, "-");
				continue;
			}

			if (row == 1) {
				col->curr_cell = list_first_entry(&col->all_cell,
								  struct ts_print_cell,
								  link);
				printf("%-*s  ", col->width, col->curr_cell->data);
				continue;
			}

			cell = list_next_entry(col->curr_cell, link);
			printf("%-*s  ", col->width, cell->data);
			col->curr_cell = cell;
		}
		printf("\n");
	}
}

/* header should be like "name,mm,discard,rotational,mergeable" */
struct ts_print_table *ts_print_init_table(char *header)
{
	char *flag_split = ",";
	char *saveptr = NULL;
	char *ptitle = NULL;
	struct ts_print_table *table;
	struct ts_print_column *col;

	table = (struct ts_print_table *)calloc(1, sizeof(struct ts_print_table));
	if (!table) {
		pd_err("failed to calloc ts print table");
		goto out;
	}
	INIT_LIST_HEAD(&table->all_column);
	++(table->max_rows);

	ptitle = strtok_r(header, flag_split, &saveptr);
	while (ptitle != NULL) {
		col = (struct ts_print_column *)calloc(1, sizeof(struct ts_print_column));
		if (!col) {
			pd_err("failed to calloc ts print table col");
			goto free_table;
		}

		INIT_LIST_HEAD(&col->all_cell);
		col->title = strdup(ptitle);
		if (!col->title) {
			pd_err("failed to duplicate title %s: %s", ptitle,
			       strerror(errno));
			tsp_free_column(col);
			goto free_table;
		}
		col->width = strlen(col->title);
		list_add_tail(&col->link, &table->all_column);
		++(table->columns);

		ptitle = strtok_r(NULL, flag_split, &saveptr);
	}

out:
	return table;
free_table:
	ts_print_free_table(table);
	goto out;
}

int ts_print_insert_cell(struct ts_print_table *table,
			 const char *title, const char *data)
{
	int rv = 0, inserted = 0, data_size;
	struct ts_print_cell *cell;
	struct ts_print_column *col;

	cell = (struct ts_print_cell *)calloc(1, sizeof(struct ts_print_cell));
	if (!cell) {
		pd_err("failed to calloc cell");
		rv = -1;
		goto out;
	}

	INIT_LIST_HEAD(&cell->link);
	cell->data = strdup(data);
	if (!cell->data) {
		pd_err("failed to duplicate data %s: %s", data, strerror(errno));
		rv = -2;
		goto free_cell;
	}

	list_for_each_entry(col, &table->all_column, link) {
		if (strcmp(col->title, title))
			continue;

		list_add_tail(&cell->link, &col->all_cell);
		++(col->cells);
		if (col->cells > table->max_rows)
			table->max_rows = col->cells;
		data_size = strlen(cell->data);
		if (data_size > col->width)
			col->width = data_size;

		inserted = 1;
		break;
	}

	if (!inserted) {
		pd_err("unfounded titile : %s", title);
		rv = -3;
		goto free_cell;
	}

out:
	return rv;
free_cell:
	tsp_free_cell(cell);
	goto out;
}
