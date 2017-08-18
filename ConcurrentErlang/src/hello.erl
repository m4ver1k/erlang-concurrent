%%%-------------------------------------------------------------------
%%% @author adarsh
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Aug 2017 1:17 AM
%%%-------------------------------------------------------------------
-module(hello).
-author("adarsh").

%% API
-export([hello/0, world/1, bazz/0]).

hello() ->
  io:format("hello~n").

world(Pid) ->
  Pid!"hello world".

bazz() ->
  receive
      stop ->
        io:format("Stopped ~n");
      Msg ->
          io:format("Got ~s~n",[Msg]),
          bazz()
  end.