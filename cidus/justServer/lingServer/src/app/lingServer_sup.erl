%%%-------------------------------------------------------------------
%% @doc lingServer top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(lingServer_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1, addChild/0]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  lager:start(),
  WebServer = #{id => webServer,
    start => {webServer, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => ['webServer']},

  DbSup= #{id => dbSup,
    start => {db_sup, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => supervisor,
    modules => ['dbSup']},

  TestGen =#{id => testGen,
    start => {testGen, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => ['testGen']},

  {ok, {#{strategy => one_for_one,
    intensity => 5,
    period => 30},
    [WebServer,DbSup,TestGen]}
  }.
%% internal functions

addChild()->
  supervisor:start_child(?SERVER,{testGen,{testGen,start_link,[]},permanent,2000,worker,[testGen]}).
