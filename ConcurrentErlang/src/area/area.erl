%%%-------------------------------------------------------------------
%%% @author adarsh
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Aug 2017 10:55 PM
%%%-------------------------------------------------------------------
-module(area).
-author("adarsh").

%% API
-export([area/0]).


area() ->
  receive
    {From,{square,X}} ->
      From ! {self(),X*X};
    {From,{rect,X,Y}}->
      From ! {self(),X*Y}
  end,
  area().




