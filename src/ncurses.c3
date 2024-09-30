module ncurses @public;

extern fn void* initscr();
extern fn CInt mvprintw(CInt, CInt, ZString);
extern fn CInt start_color();
extern fn CInt init_pair(CShort pair, CShort f, CShort b);
extern fn CInt attron(int attrs);
extern fn CInt attroff(int attrs);
extern fn CInt printw(ZString fmt, ...);
extern fn CInt refresh();
extern fn CInt getch();
extern fn void clear();
extern fn void endwin();
extern fn CInt move(CInt, CInt);
extern fn CInt curs_set(CInt);
extern fn CInt noecho();

