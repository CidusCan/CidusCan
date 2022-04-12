%%%-------------------------------------------------------------------
%% @doc lingServer top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(lingServer_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

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

  {ok, {#{strategy => one_for_one,
    intensity => 5,
    period => 30},
    [WebServer,DbSup]}
  }.
%% internal functions
