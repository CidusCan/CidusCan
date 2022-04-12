%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 3月 2022 8:49
%%%-------------------------------------------------------------------
-module(initDb).
-author("USER").

-define(LingServerPool,lingServerPool).
-define(RedisName,redisName).

%% API
-compile(export_all).


start()->
  crypto:start(),
  emysql:start(),
  addMysqlPool(),
  addRedisPool().

addMysqlPool()->
  emysql:add_pool(?LingServerPool,8,"root","137330","192.168.2.3",3306,"lingserver",utf8).

addRedisPool()->
  {ok,Pid}=eredis:start_link("192.168.2.26",6379),
  eredis_sub:sub_example("192.168.2.26",6379),
  register(?RedisName,Pid).