%%%-------------------------------------------------------------------
%%% @author USER
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 3月 2022 15:19
%%%-------------------------------------------------------------------
-author("USER").



-define(LOG(F, A), lager:info(F, A)).
-define(ERROR(F, A), lager:error(F, A)).
-define(EMERGENCY(F, A), lager:emergency(F, A)).