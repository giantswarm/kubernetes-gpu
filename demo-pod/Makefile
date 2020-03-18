NVCC = /usr/local/cuda/bin/nvcc

all: vecadd

%.o : %.cu
	$(NVCC) -c $< -o $@

vecadd : vecadd.o
	$(NVCC) $^ -o $@

clean:
	rm -rf *.o *.a vecadd
