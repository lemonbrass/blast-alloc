module blast_alloc::visualizer;

import blast_alloc::chunk;
import blast_alloc::threads; 
import ncurses;
import std::collections::list;
import std::collections::tuple;
import std::thread;
import std::core::dstring;
import libc;
import std::io;


enum  CompType {
  CHUNK_ALLOC
}

union CompData {
  ChunkAlloc* alloc;
}

def Frames = List(<String>);
def Component = Tuple(<CompType, CompData>);
def Components = List(<Component>);

struct Framializer {
  Frames frames;
  // TODO: Race conditions may occur, add a mutex for pause and quit
  bool pause;
  int fps;
  ulong frametime;
  bool quit;
}

struct Visualizer {
  Components components; 
  Framializer framie;
}

fn void inc_fps(void* framieraw){
  Framializer* framie = (Framializer*)framieraw;
  framie.fps += 5;
  framie.frametime = 1000/framie.fps;
}


fn void dec_fps(void* framieraw){
  Framializer* framie = (Framializer*)framieraw;
  framie.fps -= 5;
  framie.frametime = 1000/framie.fps;
}

fn Framializer Framializer.create(&self, Frames frames){
  self.frames = frames;
  self.fps = 10;
  self.frametime = 1000/self.fps;
  return *self;
}

fn void Framializer.update(&self){
  if (self.pause){
    return;
  }
  String! frame = self.frames.pop_first();
  if (catch excuse = frame){
    return; // no frame to play
  }
  threads::lock_mutex(&threads::iothread.mut);
  ncurses::move(0, 0);
  ncurses::printw(frame.zstr_copy());
  ncurses::refresh();
  threads::unlock_mutex(&threads::iothread.mut);
}

fn void Framializer.add_frame(&self, String frame){
  self.frames.push(frame);
}

fn void on_pause(void* framializer){
  Framializer* framie = (Framializer*) framializer;
  framie.pause = !framie.pause;
}

fn void on_quit(void* framializer){
  Framializer* framie = (Framializer*) framializer;
  framie.quit = !framie.quit;
}

fn void rerender(void* framializer){
  Framializer* framie = (Framializer*) framializer;
  threads::lock_mutex(&threads::iothread.mut);
  ncurses::clear();
  ncurses::refresh();
  if (framie.pause){
    ncurses::printw("Paused...");
  }
  threads::unlock_mutex(&threads::iothread.mut);
}

fn Window ncurses_init() @private {
  Window win = ncurses::initscr();
  ncurses::noecho();
  ncurses::nodelay(win, true);
  ncurses::keypad(win, true);
  threads::run_iothread();
  return win;
}

fn void ncurses_end() @private {
  threads::stop_iothread();
  ncurses::endwin();
}

fn void Framializer.play(&self){
  ncurses_init();
  self.fps = 10;
  self.frametime = 1000/10;
  threads::iothread_add_callback(' ', &on_pause, self);
  threads::iothread_add_callback('+', &inc_fps, self);
  threads::iothread_add_callback('-', &dec_fps, self);
  threads::iothread_add_callback('q', &on_quit, self);
  threads::iothread_add_callback('r', &rerender, self);
  ncurses::curs_set(0);
  while (self.frames.len() != 0){
    if (self.quit) break;
    self.update();
    thread::sleep_ms(self.frametime);
  }
  if (!self.quit){
    ncurses::printw("Finished visualizing, press q.....");
    while (!self.quit){ 
      thread::sleep_ms(self.frametime);
    }
  }
  ncurses_end();
}

fn void Visualizer.update(&self) @private {
  self.framie.update();
}

fn void Visualizer.create(&self, Components comps) {
  self.components = comps;
}

fn void Visualizer.push(&self) {
  DString str;
  foreach(comp : self.components){
    str.appendf(parse(comp));
  }
  self.framie.add_frame(str.copy_str());
}

fn void Visualizer.play(&self) {
  self.framie.play();
}

fn String parse(Component comp){
  DString string;
  switch (comp.first)
  {
    case CHUNK_ALLOC: 
    {
      string.appendf("\nChunk Alloc [%s] {\n", comp.second.alloc);
      string.appendf("  size = %d\n", comp.second.alloc.size);
      string.appendf("  used = %d\n", comp.second.alloc.used_chunks);
      string.appendf("  allocated = %d\n", comp.second.alloc.allocated_chunks);
      string.appendf("  chunks = {\n");
      foreach (id, chunk : comp.second.alloc.chunks){
        string.appendf("  [%d: %d],",id , chunk.used);
      }
      string.appendf("\n  }\n");
      string.appendf("}\n");
    }
  }

  return string.copy_str();
}
