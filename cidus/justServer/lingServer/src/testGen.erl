%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 4月 2022 17:05
%%%-------------------------------------------------------------------
-module(testGen).
-author("USER").

-behaviour(gen_server).

%% API
-export([start_link/0]).

-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
-include("hdlt_logger.hrl").
-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
  ?LOG("start ok  ",[]),
  {ok, #state{}}.



handle_call(delayReply, _From, State = #state{}) ->
  spawn(?MODULE, doReply,[_From]),
  {noreply, State};
handle_call(_Request, _From, State = #state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #state{}) ->
  {noreply, State}.

handle_info(_Info, State = #state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #state{}) ->
  ok.

code_change(_OldVsn, State = #state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
doReply(Pid)->
  timer:sleep(3000),
  gen_server:reply(Pid,{reply,ok,1}).
