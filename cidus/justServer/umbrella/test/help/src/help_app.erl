%%%-------------------------------------------------------------------
%% @doc help public API
%% @end
%%%-------------------------------------------------------------------

-module(help_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    help_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
