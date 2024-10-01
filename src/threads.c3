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

fn int io_thread_func(void* data){
  while (true){
    lock_mutex(&iothread.mut);
    if (iothread.running == false) break;
    iothread.mut.unlock()!!; // TODO 1: Exception handling
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
  iothread.mut.init()!!;
  iothread.th.create(&io_thread_func, null)!!;
  iothread.th.detach()!!;
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
  lock_mutex(&iothread.mut);
  iothread.running = false;
  iothread.mut.unlock()!!; // TODO 1
}
