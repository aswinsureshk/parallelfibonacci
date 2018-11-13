defmodule SumSquare do

	defmodule Worker do
		def solve(manager_pid) do
		    # This will send to the Manager a ready message after processing
		    send manager_pid, {:ready, self()}

		    receive do
		      { :solve, n, k, client } ->
		        #init(n,k) will solve the problem and then the :answer is sent back to the Manager
			send client , { :answer, n, init(n, k), self() }
		        solve(manager_pid)

		      { :shutdown } ->
		        exit(0)
		    end
	    end
		#Utility method to recursively calculate the sum of squares
		defp calculate(x, k) do
			cond do 
				k > 0 -> x*x + calculate(x+1, k-1)
			 	true -> 0
			end		
		end
		#Utility method to initiate the calculation
		defp init(x, k) do 
			result = calculate(x, k)
			if checkPerfectSquare(result) do
				result
			end
		end
		#Utility method to check if the integer is a perfect square
		defp checkPerfectSquare(x) when is_integer(x) do
			sqroot = :math.sqrt(x) |> Kernel.trunc()
			:math.pow(sqroot, 2) == x
		end
	end 
end

defmodule Manager do
  #Initiates manager, queue is the list containing 1..n which is the data to process
  def run(num_processes, module, func, queue, k) do
    	# Spawns processes, and records their pids
	processes = Enum.map(1..num_processes, fn(_) -> spawn(module, func, [self()]) end)
        schedule_processes(queue, k, [], processes)
  end 
  #Coordinates Manager-Worker interaction 
  defp schedule_processes(queue, k , results, processes) do
    receive do
      #When a :ready signal is received from a Worker, Manager replies with :solve signal along with the head element from queue("i" in 1..n) and k value 
      { :ready, pid } when queue != []->
        [ head | tail ] = queue
        send pid, { :solve, head, k, self() }
        schedule_processes(tail, k, results, processes)

      #When no more data is there to process, Manager replies with a :shutdown signal to the Worker 
      { :ready, pid } ->
        send pid, :shutdown 
        if length(processes) > 1 do 
          schedule_processes(queue, k, results, List.delete(processes, pid))
        else
          Enum.sort(results)
        end

      #Manager receives :answer along with the result from a Worker when it has finished processing
      { :answer, i, result, _pid } ->
      	# If an actor returns nil, we will continue processing without appending the result i, 
        # otherwise we add the the result and continue processing
      	if result == nil do
        	schedule_processes(queue, k, results, processes)
        else
        	schedule_processes(queue, k, results ++ [i], processes)
        end
    end
  end
end

#Module to Initiate Manager and handler User interaction
defmodule Runner do
	defp keeprunning(n,k) do
		num_processes=10
		#queue will be the list from 1 to n
		queue = Enum.to_list 1..n

  		{_, result} = :timer.tc(Manager, :run, [num_processes, SumSquare.Worker, :solve, queue, k]) 
		print result	
		
	end
	defp print(data) do
		if length(data) > 0 do
			[head|tail] = data
			IO.puts head
        		print(tail)
		end
	end
	def start do
		[n_str|k_str] = System.argv
		if length(k_str) != 1 do
    			IO.puts "Incorrect arguments. Please follow the following format : mix run lib/proj1.exs 1000000 4"
		else
			{n, ""} = Integer.parse n_str
                	{k, ""} = Integer.parse Enum.at k_str, 0
    			keeprunning(n,k)
		end
	end
end

Runner.start
