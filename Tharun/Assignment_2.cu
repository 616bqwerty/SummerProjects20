#include<iostream>
using namespace std;
int Array_Size_x,Array_Size_y;

__global__ void Sum(float* d_in1,float* d_in2, float* d_out,int* d_array_size_x,int* d_array_size_y)
{
	int j = threadIdx.x + blockIdx.x * blockDim.x;
    int k = threadIdx.y + blockIdx.y * blockDim.y;
    
	int i = j + k * *d_array_size_y;
	
    if (j < *d_array_size_y && k < *d_array_size_x) 
       d_out[i] = d_in1[i] + d_in2[i];
}
int main()
{
    cout << "Enter the array size (row , col) : ";
    cin >> Array_Size_x >> Array_Size_y;
	
    int Array_Bytes = Array_Size_x * sizeof(float) * Array_Size_y;  
	
	float *h_in1, *h_in2, *h_out;

    h_in1 = (float*)malloc(Array_Bytes);
    h_in2 = (float*)malloc(Array_Bytes);
    h_out = (float*)malloc(Array_Bytes);
	
    for(int i=0; i<Array_Size_x; i++)
    {
		for(int j = 0; j < Array_Size_y; j++)
			{ 
			h_in1[i*Array_Size_y + j] = i + 0.1;
            h_in2[i*Array_Size_y + j] = i + 0.2; 
			}
    }
	
	/*
	for(int i=0; i<Array_Size_x; i++)
		{for(int j = 0; j < Array_Size_y; j++)
			cout << h_in1[i*Array_Size_y + j] << " ";
			cout << endl;
			}
	for(int i=0; i<Array_Size_x; i++)
		{for(int j = 0; j < Array_Size_y; j++)
			cout << h_in2[i*Array_Size_y + j] << " ";
			cout << endl;
			}
		*/	
			
    float *d_in1,*d_in2, *d_out;
	int *d_array_size_x,*d_array_size_y;
	
    cudaMalloc((void**)&d_in1, Array_Bytes);
	cudaMalloc((void**)&d_in2, Array_Bytes);
    cudaMalloc((void**)&d_out, Array_Bytes);
	cudaMalloc((void**)&d_array_size_x, sizeof(int));
	cudaMalloc((void**)&d_array_size_y, sizeof(int));

    cudaMemcpy(d_in1, h_in1, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_in2, h_in2, Array_Bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_array_size_y, &Array_Size_y, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_array_size_x, &Array_Size_x, sizeof(int), cudaMemcpyHostToDevice);
	
	 dim3 dimBlock(32, 32);
	 dim3 dimGrid((int)ceil(1.0*Array_Size_y/dimBlock.x),(int)ceil(1.0*Array_Size_x/dimBlock.y));
	 
    Sum<<<dimGrid, dimBlock>>>(d_in1, d_in2, d_out,d_array_size_x,d_array_size_y);
	
    cudaMemcpy(h_out, d_out, Array_Bytes, cudaMemcpyDeviceToHost);

	for(int i=0; i<Array_Size_x; i++)
		{for(int j = 0; j < Array_Size_y; j++)
			cout << h_out[i*Array_Size_y + j]<< " ";
			cout << endl;
			}
			
    cudaFree(d_in1);
	cudaFree(d_in2);
    cudaFree(d_out);
	cudaFree(d_array_size_x);
	cudaFree(d_array_size_y);
}