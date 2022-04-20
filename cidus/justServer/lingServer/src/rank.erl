%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 4月 2022 9:38
%%%-------------------------------------------------------------------
-module(rank).
-author("USER").

%% API
-export([]).

-compile(export_all).

sortAllRank(Data)->
  SortData=lists:keysort(2,Data),
  formatRank(split(SortData,10)).


% 将列表分成N份
split(L, N) -> [].











formatRank(SortData)->
  ok.