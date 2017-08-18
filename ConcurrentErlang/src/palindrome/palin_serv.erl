%%%-------------------------------------------------------------------
%%% @author adarsh
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Aug 2017 11:33 PM
%%%-------------------------------------------------------------------
-module(palin_serv).
-author("adarsh").

%% API
-export([server/1]).

rem_punc(Str) ->
  lists:filter(fun (Ch) ->
                  not (lists:member(Ch,"\"\'\t\n "))
               end,
              Str).

to_low(Str)->
  lists:map(fun (Ch) ->
              case ($A =<Ch andalso Ch=<$Z) of
                    true -> Ch+32;
                    false -> Ch
              end
            end,Str).

palin_check(Str) ->
    Normalise = rem_punc(to_low(Str)),
    lists:reverse(Normalise) == Normalise.

server(Pid) ->
  receive
    stop ->
        io:format("Terminated~n");
    Msg ->
        case (palin_check(Msg)) of
          true -> Pid !{result,lists:flatten(io_lib:format("~s is a palindrome ~n",[Msg]))};
          false -> Pid !{result,lists:flatten(io_lib:format("~s is not a palindrome ~n",[Msg]))}
        end,
        server(Pid)
  end.
