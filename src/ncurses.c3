module ncurses @public;

import std::thread;

def Window = void*;

extern fn Window initscr();
extern fn CInt nodelay(Window, bool);
extern fn CInt keypad(Window, bool);
extern fn CInt mvprintw(CInt, CInt, ZString);
extern fn CInt start_color();
extern fn CInt init_pair(CShort pair, CShort f, CShort b);
extern fn CInt attron(int attrs);
extern fn CInt attroff(int attrs);
extern fn CInt printw(ZString fmt, ...);
extern fn CInt erase();
extern fn CInt refresh();
extern fn CChar getch();
extern fn void clear();
extern fn void endwin();
extern fn CInt move(CInt, CInt);
extern fn CInt curs_set(CInt);
extern fn CInt noecho();

