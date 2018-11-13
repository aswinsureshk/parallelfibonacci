How to Run : 

$ cd sum_of_squares 
$ mix run lib/proj1.exs 1000000 2



1. Size of work unit/explanation : 


a. In the problem, each worker gets a value i (in the range 1..n) and the k value. The workers are managed by the Manager (which corresponds to the Boss in the problem statement) module. The defualt value for num of workers (num_processes) worker is set to 10.
 
b. This figure of 10 was arrived after testing with various values of {n, k} pair and by using various values for number_of_workers, also conidering the fact that the machine used for testing was of 4 CPU. Each unit of work that a worker gets is to calculate sum of squares starting from i to i+k. If the result is a perfect square, then the worker will print it.


Note : The arguments are passed from console where the first one is n and second is k. 



2.Result of Running the program for:
Output of the program for "mix run lib/proj1.exs 1000000 4" - No output on console because there were no matching sequences found.

  

3. Calculation of Running time for the above

time mix run lib/proj1.exs 1000000 4



Following was the result:


real	0m3.453s

user	0m5.398s

sys	0m2.116s


(user + sys)/real = 2.33 (lower value of k)

Understanding for higher values of "k" which improves performance
Since each Worker gets to calculate square from i to i+k, we see more effecifient parallelism when k value is higher since the probability of two Workers finishing at the same time is reduced. Hence a test was performed for the following input : 

n = 10000000
 k = 1000



time mix run lib/proj1.exs 10000000 1000



Following was the result:


real	2m33.999s

user	9m6.243s

sys	0m3.007s



Calculation : 
No. of cores = (user + sys) / real  = (9m6s + 3s)/2m33s = 9.15/2.57 = 3.56 (closer to 4 i.e. the no.of CPUs)


4. The largest problem we managed to solve is for n=100000000 k=1000

5. Observations for running on multiple machines
The following process was followed:

On machine 1:
iex --sname aswin --cookie elixir
Node.connect :"akshay@LAPTOP-1992"

On machine 2
iex --sname akshay --cookie elixir

We used Node.spawn (:"akshay@LAPTOP-1992", __MODULE__, :func, []) and spawn (__MODULE__, :func, []) to divide the processes on both the machines.
The output integer values were obtained on multiple machines as well.
