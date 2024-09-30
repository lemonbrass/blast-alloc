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


const ulong FRAMETIME = 1000/10;

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
  bool pause;
}

struct Visualizer {
  Components components; 
  Framializer framie;
}

fn Framializer Framializer.create(&self, Frames frames){
  self.frames = frames;
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
  while (threads::iothread.mut.try_lock() == false){
    thread::sleep_ms(threads::POLL_TIME);
  }
  ncurses::move(0, 0);
  ncurses::printw(frame.zstr_copy());
  ncurses::refresh();
  threads::iothread.mut.unlock()!!;
}

fn void Framializer.add_frame(&self, String frame){
  self.frames.push(frame);
}

fn void on_pause(void* framializer){
  Framializer* framie = (Framializer*) framializer;
  framie.pause = !framie.pause;
}

fn void Framializer.play(&self){
  Window win = ncurses::initscr();
  ncurses::noecho();
  ncurses::nodelay(win, true);
  ncurses::keypad(win, true);
  threads::run_iothread();
  threads::iothread_add_callback(' ', &on_pause, self);
  ncurses::curs_set(0);
  while (self.frames.len() != 0){
    self.update();
    thread::sleep_ms(FRAMETIME);
  }
  ncurses::printw("End...");
  ncurses::nodelay(win, false);
  ncurses::wait_enter(); // wait till user presses Enter
  threads::stop_iothread();
  ncurses::endwin();
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
