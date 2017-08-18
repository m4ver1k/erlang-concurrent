%%%-------------------------------------------------------------------
%%% @author adarsh
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%% Frequency server to allocate and deallocate Freq to client.
%%% @end
%%% Created : 11. Aug 2017 11:57 PM
%%%-------------------------------------------------------------------
-module(frequency).
-author("adarsh").

%% API
-export([start/0, allocate/0, deallocate/1, stop/0, init/0, start_client/1, client/0]).


%% Hard coded list of frequencies.
get_frequencies() -> [10,11,12,13,14,15].

%% Allocate function matching empty list for available frequencies.
allocate({[],Allocated},_Pid) ->
  {{[],Allocated},{error,no_frequenncy}};

%% Method to allocate frequency, if the client already have a frequency allocated an error is raised.
allocate({[Freq | Free],Allocated},Pid) ->
  case lists:keymember(Pid,2,Allocated) of
    true ->
      {{[Freq|Free],Allocated},{error,already_allocated}};
    false ->
        link(Pid),
        {{Free,[{Freq,Pid}| Allocated]},{ok,Freq}}
  end.

%% Method to deallocate frequency, if the client dosent own the freq he is trying to deallocate a error is raised.
deallocate({Free,Allocated},Freq,Pid) ->
  case lists:member({Freq,Pid},Allocated) of
    true ->
      NewAllocated = lists:keydelete(Freq,1,Allocated),
      unlink(Pid),
      {{[Freq | Free],NewAllocated},{ok,deallocated}};
    false ->
      {{Free,Allocated},{ok,nothing_to_deallocate}}
  end.

%% Main application loop
loop(Frequencies) ->
  receive
    {request,Pid,allocate} ->
      {NewFrequencies,Reply} = allocate(Frequencies,Pid),
      Pid ! Reply,
      loop(NewFrequencies);
    {request,Pid,{deallocate,Freq}} ->
      {NewFrequencies,Reply} = deallocate(Frequencies,Freq,Pid),
      Pid ! Reply,
      loop(NewFrequencies);
    {request,Pid,stop} ->
      Pid ! stopped;
    {'EXIT',Pid,_Reason} ->
      NewFrequencies = exited(Frequencies,Pid),
      loop(NewFrequencies)
  end.

%% App initialization
init()->
  process_flag(trap_exit,true),
  loop({get_frequencies(),[]}).

%% App Starting point.
start() ->
  register(frequency,spawn(frequency,init,[])).


%% Client API to allocate freq
allocate()->
  frequency ! {request,self(),allocate},
  receive
    {_Msg,Reply} -> Reply
  after
      3000 ->
        timeout
  end.
%% Client API to deallocate freq
deallocate(Freq) ->
  frequency ! {request,self(),{deallocate,Freq}},
  receive
    {_Msg,Reply} -> Reply
  after
    3000 ->
      timeout
  end.

%% Client API to stop the server.
stop()->
    frequency ! {request,self(),stop },
  receive
    Msg -> Msg
  end.

%% Api to clear the  Mail Box and print Messages
%%clear() ->
%%  receive
%%    Res -> io:format("~p~n",[Res]),
%%    %{_Code,Reply} -> io:format("Clearing Mail box Stale Msg [~s]~n",[Reply]),
%%      clear()
%%  after
%%      0 -> done
%%  end.

exited({Free,Allocated}, Pid) ->
  case lists:keyfind(Pid,2,Allocated) of
    {Freq,Pid} ->
      NewAllocated = lists:keydelete(Freq,1,Allocated),
      {[Freq|Free],NewAllocated};
    false ->
      {Free,Allocated}
  end.


start_client(Name) ->
  register(Name,spawn(frequency,client,[])).

client() ->
  Ref=frequency:allocate(),
  frequency:deallocate(Ref),client().