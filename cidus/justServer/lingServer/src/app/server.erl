%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 3月 2022 17:13
%%%-------------------------------------------------------------------
-module(server).
-author("USER").

%% API
-export([start/0]).

start()->
  application:start(lingServer).
