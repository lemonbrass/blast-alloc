module blast_alloc::threads;

import std::thread, std::io, std::collections::list, std::collections::map;
import ncurses;

const POLL_TIME = 5;
def Callback = fn void(void*);

struct CallbackPair {
  void* args;
  Callback callback;
}

def CallbackList = List(<CallbackPair>);
def CallMap = HashMap(<char, CallbackList>);

struct IOThread {
  Mutex mut;
  bool running;
  Thread th;
  CallMap callbacks;
}

IOThread iothread;

fn void lock_mutex(Mutex* mut){
  while (iothread.mut.try_lock() == false){
    thread::sleep_ms(POLL_TIME);
  }
}


fn void unlock_mutex(Mutex* mut){
  if (catch err = mut.unlock()) {
    io::printfn("Error: %s", err);
    thread::sleep_ms(POLL_TIME);
    unlock_mutex(mut);
  }
}

macro @ncurses_run(;@body()) @builtin {
  lock_mutex(&iothread.mut);
  @body();
  unlock_mutex(&iothread.mut);
}


macro @expect(#errtype) @builtin {
  $if $typeof(#errtype).typeid == void!.typeid:
    if (catch err = #errtype){
      io::printfn("Exception (void!) : %s", err);
    }
    return null;
  $else
    any! errt = #errtype;
    if (catch err = errt){
      io::printfn("Exception: %s", err);
    }
    return errt;
  $endif
}


fn int io_thread_func(void* data){
  while (true){
    @ncurses_run(){
      if (iothread.running == false) break;
    };
    char ch = (char)ncurses::getch();
    CallbackList! callbacks = iothread.callbacks[ch];
    if (catch err = callbacks) continue;
    foreach (callback : callbacks){
      callback.callback(callback.args);
    }
    thread::sleep_ms(10);
  }
  return 0;
}

fn void run_iothread(){
  if (iothread.running == false){
    Thread zeroinit;
    iothread.th = zeroinit;
  }
  iothread.callbacks.new_init();
  iothread.running = true;
  @expect(iothread.mut.init());
  unlock_mutex(&iothread.mut);
  @expect(iothread.th.create(&io_thread_func, null));
  @expect(iothread.th.detach());
}

fn void iothread_add_callback(char event, Callback cback, void* arg){
  CallbackList! callbacks = iothread.callbacks[event];
  if (catch err = callbacks){
    CallbackList zero;
    zero.new_init();
    CallbackPair cbackpair;
    cbackpair.args = arg;
    cbackpair.callback = cback;
    zero.push(cbackpair);
    iothread.callbacks.set(event, zero);
  }
  else{
    CallbackPair cbackpair;
    cbackpair.args = arg;
    cbackpair.callback = cback;
    callbacks.push(cbackpair);
  }
}

fn void stop_iothread(){
  @ncurses_run(){
    iothread.running = false;
  };
}
