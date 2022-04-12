%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(db_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  initDb:start(),
  DbGen = #{id => 'dbGen',
    start => {'dbGen', start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => ['dbGen']},

  {ok, {#{strategy => one_for_one,
    intensity => 5,
    period => 30},
    [DbGen]}
  }.
