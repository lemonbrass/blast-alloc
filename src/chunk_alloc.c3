module blast_alloc::chunk;
import blast_alloc::visualizer;
import std::io;
import std::collections::list;
import std::core::mem;


const usz MAX_FRAGMENTATION = 32;

struct Chunk {
  void* mem;
  usz used;
}

def PtrList = list::List(<Chunk>);

struct ChunkAlloc {
  usz size;
  usz used_chunks;
  usz allocated_chunks;
  PtrList chunks;
  Visualizer viz;
}


fault ChunkAllocError {
  ALLOC_GREATER_THAN_CHUNK_SIZE, // size greater than chunk size
}


fn void ChunkAlloc.create(&self, usz size){
  self.chunks.new_init();
  self.chunks.push(create_chunk(size));
  self.size = size;
  Components comps;
  CompData data;
  data.alloc = self;
  Component comp;
  comp.first = CHUNK_ALLOC;
  comp.second = data;
  comps.push(comp);
  self.viz.create(comps);
  io::printn("Made new chunk alloc!");
}

fn Chunk create_chunk(usz size){
  Chunk chunk;
  chunk.mem = mem::malloc(size);
  chunk.used = 0;
  return chunk;
}

fn void*! ChunkAlloc.alloc(&alloc, usz size){
  if (size >= alloc.size){
    return ChunkAllocError.ALLOC_GREATER_THAN_CHUNK_SIZE?;
  }

  Chunk* chunk = &alloc.chunks[alloc.used_chunks];
  usz id = alloc.used_chunks;
  while (chunk.used != 0 && (alloc.size-chunk.used) < size){
    if (id >= alloc.allocated_chunks){
      alloc.chunks.push(create_chunk(alloc.size));
      alloc.allocated_chunks++;
    }
    if (id == alloc.used_chunks && (alloc.size - chunk.used) <= MAX_FRAGMENTATION){
      alloc.used_chunks++;
    }
    id++;
    chunk = &alloc.chunks[id];
  }
  void* ptr = chunk.mem + chunk.used;
  chunk.used += size;
  alloc.viz.push();
  return ptr;
}

fn void ChunkAlloc.destroy(&alloc){
  foreach (id, chunk : alloc.chunks){
    // io::printf("%d: ", id);
    for (int i=0;i<alloc.size;i++) {
      char a = *(char*)(chunk.mem+i);
      // io::printf(" %d ", a);
    }
    // io::printfn("\n%d\n",chunk.used);
    mem::free(chunk.mem);
  }
  alloc.chunks.free();
  // io::printn("Destroyed a chunk alloc!!");
}
