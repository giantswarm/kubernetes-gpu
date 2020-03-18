#include <iostream>
#include <cuda.h>
using namespace std;

int *a, *b;  // host data
int *c, *c2;  // results

__global__ void vecAdd(int *A,int *B,int *C,int N)
{
   int i = blockIdx.x * blockDim.x + threadIdx.x;
   C[i] = A[i] + B[i]; 
}

void vecAdd_h(int *A1,int *B1, int *C1, int N)
{
   for(int i=0;i<N;i++)
      C1[i] = A1[i] * B1[i];
}

int main(int argc,char **argv)
{
   printf("Begin \n");
   int n=10000000;
   int nBytes = n*sizeof(int);
   int block_size, block_no; 
   a = (int *)malloc(nBytes);
   b = (int *)malloc(nBytes);
   c = (int *)malloc(nBytes);
   c2 = (int *)malloc(nBytes);
   int *a_d,*b_d,*c_d;
   block_size=4000;
   block_no = n/block_size;
   dim3 dimBlock(block_size,1,1);
   dim3 dimGrid(block_no,1,1);
   for(int i=0;i<n;i++)
      a[i]=i,b[i]=i;
   printf("Allocating device memory on host..\n");
   cudaMalloc((void **)&a_d,n*sizeof(int));
   cudaMalloc((void **)&b_d,n*sizeof(int));
   cudaMalloc((void **)&c_d,n*sizeof(int));
   printf("Copying to device..\n");
   cudaMemcpy(a_d,a,n*sizeof(int),cudaMemcpyHostToDevice);
   cudaMemcpy(b_d,b,n*sizeof(int),cudaMemcpyHostToDevice);
   clock_t start_d=clock();
   printf("Doing GPU Vector add\n");
   vecAdd<<<block_no,block_size>>>(a_d,b_d,c_d,n);
   cudaThreadSynchronize();
   clock_t end_d = clock();
   clock_t start_h = clock();
   printf("Doing CPU Vector add\n");
   vecAdd_h(a,b,c2,n);
   clock_t end_h = clock();
   double time_d = (double)(end_d-start_d)/CLOCKS_PER_SEC;
   double time_h = (double)(end_h-start_h)/CLOCKS_PER_SEC;
   cudaMemcpy(c,c_d,n*sizeof(int),cudaMemcpyDeviceToHost);
   printf("%d %f %f\n",n,time_d,time_h);
   cudaFree(a_d);
   cudaFree(b_d);
   cudaFree(c_d);
   return 0;
}
