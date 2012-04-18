//
// vec.c
//
// written by sjrct
//
// TODO:
//   fix scrolling bug
//   test/debug line continuations
//

#include <stdlib.h>
#include <fapi.h>
#include <scancodes.h>

#define SCREEN_WIDTH  80
#define SCREEN_HEIGHT 25

#define TAB_SIZE 4

#define NORM_INK COL4_GREEN
#define CUR_INK  COL4_GREEN << 4
#define INFO_INK COL4_LGREEN

typedef struct line {
	int sz;
	char ch[SCREEN_WIDTH];
	struct line * next;
	struct line * prev;
	int line_num;
	int is_cont;
} line;

static int curx;
static line *first, *view, *curline;
static const char * filename = "newfile.txt";

void draw();
void load_file(const char * fn);
void empty_file();
void save();
line * insert_line(line * p, int is_cont);
int insert_char(line * l, int x, int c);
void remove_line(line * l);
void remove_char(line * l, int x);
int curline_above_view();
int curline_below_view();
void merge_lines(line * l1, line * l2);

int main(int argc, char ** argv)
{
	int sc, c, oldink;
	int lshift, rshift;

	hidecursor();
	oldink = getink();

	if (argc > 1) load_file(argv[1]);
	else empty_file();

	draw();

	while (1)
	{		
		switch (sc = getsc()) {
		case SC_ESCAPE:
			setink(oldink);
			cls();
			exit(0);
		
		// cursor control scancodes
		case SC_LEFT_ARROW:
			if (curx > 0) {
				curx--;
				break;
			}
		case SC_UP_ARROW:
			if (curline->prev != NULL) curline = curline->prev;
			if (curx > curline->sz) curx = curline->sz;
			break;
			
		case SC_RIGHT_ARROW:
			if (curx < curline->sz && curline->ch[curx] != '\n') {
				curx++;
				break;
			}
		case SC_DOWN_ARROW:
			if (curline->next != NULL) curline = curline->next;
			if (curx > curline->sz) curx = curline->sz;
			break;
		
		case SC_HOME:
			curx = 0;
			break;
		case SC_END:
			curx = curline->sz;
			break;
		
		// remove character scancodes
		case SC_BACKSPACE:
			if (curx == 0) {
				if (curline->prev != NULL) {
					curline = curline->prev;
					curx = curline->sz;
					merge_lines(curline, curline->next);
				}
			} else {
				curx--;
				remove_char(curline, curx);
			}
			break;
		
		case SC_DELETE:
			if (curx == curline->sz) {
				if (curline->next != NULL)
					merge_lines(curline, curline->next);
			} else {
				remove_char(curline, curx);
			}
			break;
		
		// shift scancodes
		case SC_LSHIFT:
			lshift = 1;
			break;
		case SC_LSHIFT | SC_BREAK:
			lshift = 0;
			break;
		case SC_RSHIFT:
			rshift = 1;
			break;
		case SC_RSHIFT | SC_BREAK:
			rshift = 0;
			break;

		// normal add character to screen
		default:
			if (!IS_KEY_BREAK(sc) && sc < ASCII_MAP_SIZE) {
				if (lshift || rshift) c = shift_sc_to_ascii_map[sc];
				else c = sc_to_ascii_map[sc];
				
				if (c != 0) {
					if (c == '\t') {
						for (; curx % (TAB_SIZE + 1) != TAB_SIZE; curx++)
							insert_char(curline, curx, ' ');
					} else {
						insert_char(curline, curx, c);
						curx++;
					}

					if (c == '\n') {
						curline = curline->next;
						curx = 0;
					} else if (curx >= SCREEN_WIDTH) {
						if (!curline->next->is_cont)
							insert_line(curline, 1);
						curline = curline->next;
						curx = 0;
					}
				}
			}
		}
		
		if (view->prev != NULL && curline_above_view()) view = view->prev;
		if (curline_below_view()) view = view->next;
		
		draw();
	}

	return 0;
}

void draw()
{
	int x, y = 0;
	line * l = view;
	
	cls();
	setink(NORM_INK);

	while (l != NULL && y < SCREEN_HEIGHT - 2) {
		for (x = 0; x < l->sz; x++) {
			if (l == curline && x == curx) setink(CUR_INK);
			if (l->ch[x] != '\n') outc(x, y, l->ch[x]);
			if (l == curline && x == curx) setink(NORM_INK);
		}
		
		if (l == curline && curx >= l->sz) {
			setink(CUR_INK);
			outc(curx, y, ' ');
			setink(NORM_INK);
		}
		
		y++;
		l = l->next;
	}
	
	setink(INFO_INK);
	for (x = 0; x < SCREEN_WIDTH; x++)
		outc(x, SCREEN_HEIGHT - 2, '-');
	
	setcursor(0, SCREEN_HEIGHT - 1);
	puts("Ln");
	puth(curline->line_num + 1);
	puts(" | Ch");
	puth(curx + 1);
	puts(" | ");
	puts(filename);
}

void recalc_line_nums()
{
	line * l = first;
	int n = -1;
	while (l != NULL) {
		if (!l->is_cont) n++;
		l->line_num = n;
		l = l->next;
	}
}

line * insert_line(line * p, int is_cont)
{
	line *r;
	r = malloc(sizeof(line));
	
	r->is_cont = is_cont;
	r->sz = 0;
	r->prev = p;
	
	if (p != NULL) {
		r->next = p->next;
		if (r->next != NULL) r->next->prev = r;
		p->next = r;
		recalc_line_nums();
	} else {
		r->next = NULL;
		r->line_num = 0;
	}
	
	return r;
}

int insert_char(line * l, int x, int c)
{
	int i;
	line * nl;

	if (c == '\n') {
		nl = insert_line(l, 0);
		nl->sz = l->sz - x;
		
		for (i = x; i < l->sz; i++) {
			nl->ch[i - x] = l->ch[i];
		}

		l->sz = x;
		
		return 1;
	} else {
		l->sz++;
		if (l->sz > SCREEN_WIDTH) {
			if (!l->next->is_cont) nl = insert_line(l, 1);
			l->sz = SCREEN_WIDTH;
			insert_char(l->next, 0, l->ch[SCREEN_WIDTH - 1]);
			return 1;
		}

		for (i = l->sz - 1; i > x; i--) {
			l->ch[i] = l->ch[i - 1];
		}
		l->ch[x] = c;
	}
	
	return 0;
}

void remove_line(line * l)
{
	if (l->prev != NULL) l->prev->next = l->next;
	if (l->next != NULL) {
		l->next->prev = l->prev;
		recalc_line_nums();
	}
	free(l);
}

void merge_lines(line * l1, line * l2)
{
	int x;
	
	if (l1->sz == SCREEN_WIDTH) {
		l2->is_cont = 1;
		return;
	}
	
	for (x = 0; x < l2->sz; x++) {
		if (insert_char(l1, l1->sz, l2->ch[x]))
			l1 = l1->next;
	}
	
	remove_line(l2);
}

void remove_char(line * l, int x)
{
	int i;
	if (x < l->sz) {
		l->sz--;	
		for (i = x; i < l->sz; i++) {
			l->ch[i] = l->ch[i + 1];
		}
	}
}

int curline_above_view()
{
	line * l = view->prev;
	while (l != NULL) {
		if (l == curline) return 1;
		l = l->next;
	}
	return 0;
}

int curline_below_view()
{
	int y = 0;
	line * l = view;
	while (l != NULL && y < SCREEN_HEIGHT - 2) {
		if (l == curline) return 0;
		l = l->next;
		y++;
	}
	
	while (l != NULL) {
		if (l == curline) return 1;
		l = l->next;
	}
	
	return 0;
}

void empty_file()
{
	first = curline = view = insert_line(NULL, 0);
}

void load_file(const char * fn)
{
	f300_ptr ptr = f300_locate_node(fn);
	
	if (ptr == 0) {
		filename = fn;
		empty_file();
	} else {
		// TODO
		exit(0);
	}
}

void save()
{
	//TODO
}
