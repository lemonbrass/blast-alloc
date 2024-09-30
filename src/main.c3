module blast_alloc;
import std::io;
import std::math::random;
import std::core::string;
import blast_alloc::chunk;
import blast_alloc::visualizer;

fn int main(String[] args)
{
  ChunkAlloc alloc;
  alloc.create(512);
  for (int i=0;i<256;i++){
    int ran_d = rand(512);
    char* str = alloc.alloc(ran_d)!!;
    for (int j=0;j<ran_d;j++){
      str[j] = (char)ran_d;
    }
  }
  alloc.viz.play(); // play the recorded biography of my dear chunk alloc
  alloc.destroy();
	return 0;
}
