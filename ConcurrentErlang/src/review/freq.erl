-module(freq).
-export([init/0, start/0, allocate/0, deallocate/1, stop/0, clear/0]).

start() ->
  register(frequency,
    spawn(freq, init, [])).

%% These are the start functions used to create and
%% initialize the server.

init() ->
  Frequencies = {get_frequencies(), []},
  loop(Frequencies).

%% Hard Coded
get_frequencies() -> [10,11,12,13,14,15].
get_timeout() -> 1000.

%% The Main Loop

loop(Frequencies) ->
  timer:sleep(get_timeout() * 4),
  io:format("~p~n", [Frequencies]),
  receive
    {request, Pid, allocate} ->
      {NewFrequencies, Reply} = allocate(Frequencies, Pid),
      Pid ! {reply, Reply},
      loop(NewFrequencies);
    {request, Pid , {deallocate, Freq}} ->
      NewFrequencies = deallocate(Frequencies, Freq),
      Pid ! {reply, ok},
      loop(NewFrequencies);
    {request, Pid, stop} ->
      Pid ! {reply, stopped}
  end.

%% functional API
request(Type) ->
  Msg = {request, self(), Type},
  frequency ! Msg,
  receive
    {reply, Reply} -> Reply
  after get_timeout() ->
    io:format("~p could not be processed~n", [Msg]),
    clear()
  end.

allocate() ->
  request(allocate).

deallocate(Freq) ->
  request({deallocate, Freq}).

clear() ->
  receive
    _Msg -> clear()
  after 0 ->
    io:format("cleared queue~n", [])
  end.

stop() ->
  frequency ! {request, self(), stop},
  receive
    {reply, Reply} -> Reply
  end.

%% The Internal Help Functions used to allocate and
%% deallocate frequencies.

allocate({[], Allocated}, _Pid) ->
  {{[], Allocated}, {error, no_frequency}};
allocate({[Freq|Free], Allocated}, Pid) ->
  {{Free, [{Freq, Pid}|Allocated]}, {ok, Freq}}.

deallocate({Free, Allocated}, Freq) ->
  NewAllocated=lists:keydelete(Freq, 1, Allocated),
  {[Freq|Free], NewAllocated}.

