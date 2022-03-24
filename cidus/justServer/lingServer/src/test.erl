%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 3月 2022 9:28
%%%-------------------------------------------------------------------
-module(test).
-author("USER").

-include("hdlt_logger.hrl").


%% API
-compile(export_all).

test()->
  ok.

sendHttp()->
  httpc:request(post,{"http://192.168.2.3:65000/lingWebHandle:test",[],"","1234"},[],[]).

testLager()->
  ?LOG("hello erverr ~n",[]),
  ?ERROR("hello erverr ~n",[]),
  ?EMERGENCY("hello erverr ~n",[]).