%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 3月 2022 10:55
%%%-------------------------------------------------------------------
-module(lingWebHandle).
-author("USER").

%% API
-export([sendBack/2,test/3]).


sendBack(SessionId,Data)->
  mod_esi:deliver(SessionId,Data).

test(SessionID, Env, Input)->
  io:format("~p~n",[[?MODULE,?LINE,SessionID, Env, Input]]),
  sendBack(SessionID,"nihao").