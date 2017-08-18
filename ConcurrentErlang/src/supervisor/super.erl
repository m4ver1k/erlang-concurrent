-module(super).
-export([super/0]).

super() ->
    process_flag(trap_exit, true),

    Echo = reg_new_echo(),
    io:format("echo spawned.~n"),

    Worker = reg_new_worker(),
    io:format("worked spawned as Pid ~w.~n",[whereis(talk)]),
    loop(Echo, Worker).

loop(Echo,Worker) ->
     receive
       {'EXIT',Echo,_Reason} ->
         timer:sleep(1000),
         loop(reg_new_echo(),Worker);
       {'EXIT',Worker,_Reason} ->
         loop(Echo,reg_new_worker())
    end.


reg_new_worker() ->
  Worker = spawn_link(talk,worker,[]),
  register(worker, Worker),
  Worker.

reg_new_echo () ->
  Echo = spawn_link(echo,listener,[]),
  register(echo,Echo),
  Echo.


%% After making 1 sec delay, When Echo process is killed we get error, talk / worker crash when it tries to send message to a
%% terminated process.
%%When we kill the worker process, it reset and start send message with count 0
%% if we kill super process the other processes are killed as well.



    

