%%%-------------------------------------------------------------------
%%% @author adarsh
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Aug 2017 11:18 PM
%%%-------------------------------------------------------------------
-module(pong).
-author("adarsh").

%% API
-export([setup/0, ping/0]).

ping() ->
  receive
    {Pid,ping} ->
      Pid ! pong,
    ping()
  end,
  ping().


setup() ->
  Server = spawn(pong,ping,[]),
  register(server,Server).