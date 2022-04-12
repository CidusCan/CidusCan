%%coding: latin-1
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
-define(LingServerPool, lingServerPool).
-define(RedisName, redisName).
-compile([export_all, nowarn_unused_vars]).
-include_lib("stdlib/include/ms_transform.hrl").
-include_lib("stdlib/include/qlc.hrl").
-on_load(on_load123/0).

-rabbit_boot_step({codec_correctness_check,
    [{description, "codec correctness check"},
        {mfa, {rabbit_binary_generator,
            check_empty_frame_size,
            []}},
        {requires, pre_boot},
        {enables, external_infrastructure}]}).


-define(DEFAULT, default).

test() ->
    ok1.

sendHttp() ->
    httpc:request(post, {"http://192.168.2.3:65000/lingWebHandle:test", [], "", "1234"}, [], []).

testLager() ->
    ?LOG("hello erverr ~n", []),
    ?ERROR("hello erverr ~n", []),
    ?EMERGENCY("hello erverr ~n", []).

%%  dbpool LingServerPool
testDb() ->
    IP = "113.69.245.134",
    Sql = "select registered_country_geoname_id from (select * from ip_mapping where inet6_aton(\'" ++ IP ++ "\')  >= network_start order by network_start desc limit 1 ) net where inet6_aton(\'" ++ IP ++ "\') <= network_end",
    emysql:execute(?LingServerPool, Sql).


%% unicode 输出
testOutput() ->
    io:format("~tc", [25105]).

testdun() ->
    "、".





on_load123() ->
    io:format("我到底加载了没？？？？？").

compile1(File) ->
    compile:file(File).


start1() ->
    io:format("no!!!").


try1(Arg) ->
    try
        list_to_binary(Arg)
    catch
        Why:Why1 ->
            Why1
    end.


try2() ->
    A = try1(1),
    io:format("A:~p~n", [A]).

dofile() ->
    {ok, File} = file:open("./dofiletest.txt", [read]),
    A = file:read(File, 1024 * 1024),
    file:close(File),
    A.

dowrite() ->
    {ok, File} = file:open("write.txt", [write, raw]),
    A = 134,
    file:write(File, io_lib:format("~w", [A])),
    file:close(File).

dowrite1(Arg) ->
    {ok, File} = prim_file:open("./filetest.txt", [write, append]),
    prim_file:write(File, Arg),
    ok = file:sync(File),
    file:close(File).

reName() ->
    prim_file:rename("./filetest.txt", "filetest1.txt").

try1() ->
    try
        ok1
    catch
        _:_ ->
            ok
    after
        io:format("after")
    end.

rand1() ->
    random:seed(1, 1, 1),
    io:format("1:~p~n", [random:seed()]),
    erlang:spawn(fun() -> io:format("2:~p~n", [random:seed()]) end),
    io:format("1:~p~n", [random:seed()]).

ets1() ->
    ets:new(a, [set, named_table]),
    lists:duplicate(1000, {a, 1}),
    lists:foreach(fun(Data) -> ets:insert(a, Data) end, [[{people, 1}, {a, 2}, {s, 3}]]),
    F = ets:fun2ms(fun(A) -> A end),
    ets:select(a, F).

dropwhile(Arg) ->
    lists:dropwhile(fun(E) -> E =:= 1 end, Arg).

fun1(F) ->
    filename:absname(filename:rootname(F, ".config") ++ ".config").

writeFile(File) ->
    io:format("~p~n", [is_binary(File)]),
    file:write_file("write.txt", [io_lib:format("~w~n", [File1]) || File1 <- File], []).

fun2() ->
    fun3(fun() -> now() end).

fun3(Fun) ->
    Fun().

etsFun() ->
    Tab = ets:new(test, [set, named_table]),
    ets:insert(test, [{a, 1}, {b, 2}]),
    ets:update_element(test, a, {2, 999}),
    ets:lookup_element(test, a, 2).

etsFoldl() ->
    ets:new(test4, [set, named_table]),
    ets:insert(test4, [{a, 1}, {b, 1}, {c, 3}]),
    ets:foldl(fun({_, Value}, Acc) -> Acc + Value end, 0, test4).

sendAfter() ->
    erlang:send_after(2000, self(), {hello}).

getTest() ->
    erlang:put('a', 1),
    erlang:put('b', 2),
    erlang:put('c', 3),
    L = [Value || {c, Value} <- erlang:get()],
    L.

etsCounter() ->
    Tab = ets:new(test, [set, named_table]),
    ets:insert(test, [{a, 1}, {b, 2}]),
    ets:update_counter(test, a, 1),
    ets:update_counter(test, a, {2, 1}).

testWall_clock() ->
    erlang:statistics(wall_clock),
    Time1 = os:timestamp(),

    [X || X <- lists:seq(1, 10000000)],


    Time2 = os:timestamp(),
    Diff = timer:now_diff(Time2, Time1),
    {_, WallTime} = erlang:statistics(wall_clock),
    io:format("Time:~p,~p", [Diff, WallTime]).

etsSelectCount() ->
    ets:new(test4, [set, named_table]),
    ets:insert(test4, [{a, 1}, {b, 1}, {c, 3}, {d, 4}]),
    F = ets:fun2ms(fun({A, B}) when B =:= 1 andalso A =:= a -> true end),
    ets:select_count(test4, F).

etsSelectLimit() ->
    ets:new(test4, [set, named_table]),
    ets:insert(test4, [{a, 1}, {b, 1}]),
    F = ets:fun2ms(fun({A, B}) when B =:= 1 -> true end),
    ets:select(test4, F, 2).

etsLast() ->
    ets:new(test4, [set, named_table]),
    ets:insert(test4, [{a, 1}, {b, 1}, {c, 3}, {d, 4}]),
    ets:last(test4).

readtxt() ->
    io:format("~p~n", [file:list_dir(".")]),
    {ok, File} = file:open("read.txt", [read]),
    file:close(File),
    io:format("ok!"),
    case file:consult("read.txt") of
        {error, Error} ->
            file:format_error(Error);
        {ok, File1} ->
            File1
    end.

etSort(Table) ->
    lists:sort(ets:tab2list(Table)).

-record(test, {filed1, filed2}).

recordTest() ->
    TestRecord = #test{filed1 = 1, filed2 = 2},
    [Num || #test{filed1 = 1, filed2 = Num} <- [TestRecord]].

-record(rabbit, {name, sex}).
-record(rabbit1, {name, sex}).

rabbit() ->
    Rabbit = #rabbit1{name = 1, sex = 2},
    case Rabbit of
        Rabbit1 = #rabbit{} ->   % 这个写法相当于 is_record
            Rabbit1;
        _ ->
            100
    end.

rabbit1() ->
    Rabbit = #rabbit1{name = 1, sex = 2},
    case Rabbit of
        Rabbit1 when is_record(Rabbit1, rabbit) ->   % 这个写法相当于 is_record
            Rabbit1;
        _ ->
            100
    end.

clause() ->
    % {1,3}={A,B},  没有定义A,B不能这样用
    ok.

when1() ->
    case 1 of
        A when A == 1, A == 2 ->
            ok;
        _ ->
            no
    end.

perms([]) -> [[]];

perms(L) ->
    [[A | T] || A <- L, T <- perms(L--[A])].

f2() ->
    L = [1, 2, 3],
    [A || A <- L, T <- [[]]].

readFile(A) ->
    {ok, File} = prim_file:open("write.txt", []),
    prim_file:read(File, A).

delayReceive() ->
    self() ! ok,
    self() ! no,
    io:format("messages:~p~n", [erlang:process_info(self(), messages)]),
    timer:sleep(2000),
    io:format("wake up"),
    receive
        ok ->
            receiveokOK
    end,
    io:format("messages:~p~n", [erlang:process_info(self(), messages)]),
    receive
        no ->
            receivenoOK
    end,
    io:format("messages:~p~n", [erlang:process_info(self(), messages)]).

insertNew() ->
    ets:new(test, [set, protected, named_table]),
    A = ets:insert_new(test, {a, 1}),
    B = ets:insert_new(test, {a, 2}),
    [A, B, ets:tab2list(test)].

zipwith() ->
    %%两个列表数量相同，都当参数，而且顺序需要一致使用
    lists:zipwith(fun(A, B) -> put(A, B) end, [a, b, c], [1, 2, 3]).

gbtree() ->
    T = gb_trees:empty(),
    T1 = gb_trees:insert(a, 1, T),
    T2 = gb_trees:insert(b, 1, T1),
    [gb_trees:delete_any(a, T2)].

reserveBinarynot(A) ->
    <<<<X>> || <<X:1>><=A>>.

listTest() ->
    [begin
         io:format("X ~p~n", [X]),
         X end || X <- [1, 2, 3]
    ].

reserveBinary(A) ->
    list_to_binary(lists:reverse(binary_to_list(A))).

term_to_packet(Term) ->
    A = term_to_binary(Term),
    Length = byte_size(A),
    io:format("Length~p~n", [Length]),
    catch [A, Length, <<Length:1/unit:32, A/binary>>].

reverse1(A) ->
    list_to_binary(lists:reverse([X || <<X:1>><=A])).

apply() ->
    apply(erlang, put, [a, 1]).

% tupleFun()->
% 	A={test,1,2,3},
% 	A:tupleFun1(1).

tupleFun1(A, {test, 1, 2, 3}) ->
    A.

fdy(A) ->
    dyok.

fdy1() ->
    lists:map(fun fdy/1, [1, 2, 3]).

clausestring("begin" ++ T) ->
    begin1;

clausestring("end" ++ T) ->
    end1.

testwhen1() ->
    true and (io:format("1")).

startclock(Time) ->
    register(clock, spawn(fun() -> clock(Time, fun() -> io:format("now time is ~p~n", [erlang:now()]) end) end)).

clock(Time, Fun) ->
    receive
        stop ->  %我真是吐了，一个发送消息的时候忘记填句号，整了半天
            void
    after Time ->
        Fun(),
        io:format("self is :~p~n", [self()]),
        clock(Time, Fun)
    end.

startAtom() ->
    A = (catch startAnAtom(test1, fun() -> receive ok -> ok end end)),
    B = (catch startAnAtom(test1, fun() -> receive ok -> ok end end)),
    % 	A=startAnAtom(test1,fun()->receive ok-> ok end end ),
    % B=  startAnAtom(test1,fun()->receive ok-> ok end end ),
    [A, B].

startAnAtom(AnAtom, Fun) ->
    register(AnAtom, spawn(Fun)).

circle(Num, Times) ->
    L = spawn1(Num),
    hd(L) ! {1, L, Times, "receive"}.
circleFun() ->
    receive
        {Pos, L, M, Msg} ->
            io:format("~p receive a message!!!", [Pos]),
            case catch getPid(Pos + 1, L, M) of
                over ->
                    io:format("over");
                Pid ->
                    io:format("Pid ~p~n", [Pid]),
                    Pid ! {Pos + 1, L, M, Msg},
                    circleFun()
            end
    end.

spawn1(Num) ->
    [spawn(fun() -> circleFun() end) || X <- lists:seq(1, Num)].

getPid(Pos, L, M) ->
    Length = length(L),
    case Pos > Length of
        true when (Pos - 1) div Length >= M ->
            io:format("lunci~p~n", [Pos div Length]),
            over;
        true when Pos rem Length =/= 0 ->
            lists:nth(Pos rem Length, L);
        _ when Pos rem Length == 0 ->
            lists:nth(Length, L);
        _ ->
            lists:nth(Pos, L)
    end.

% keep_alive()->
% 	register(test,Pid=spawn(fun()-> receive ok-> ok end end )),
% 	on_exit(Pid,fun(_Why)-> keep_alive() end ).


on_exit(Pid) ->  %通过monitor创建一个监视
    erlang:spawn(fun() ->
        Ref = erlang:monitor(process, Pid),
        receive
            {'DOWN', Ref, process, Pid, Why} ->
                io:format("dead")
        end end).

my_spawn() ->
    erlang:statistics(runtime),
    {Pid, Ref} = spawn_monitor(fun() -> receive after 1000 -> ok end end),
    receive
        {'DOWN', Ref, process, Pid, Why} ->
            {_, Time} = erlang:statistics(runtime),
            % Time=timer:now_diff(Time2,Time1),
            io:format("Why~p~n,TIme ~p~n", [Why, Time]),
            my_spawn()
    end.

mydestory(Time) ->
    spawn(fun() -> receive after Time -> io:format("destory") end end).

runmonitor() ->
    spawn(fun monitor1/0).

monitor1() ->
    Pid = spawn(fun() -> running() end),
    erlang:register(test4, Pid),
    Ref = erlang:monitor(process, Pid),
    receive
        {'DOWN', Ref, process, Pid, Why} ->
            monitor1()
    end.


running() ->
    receive after 5000 ->
        io:format("i'm runing "),
        running()
    end.

% monitortest2()->
% 	spawn(fun()-> monitort2(1),

% monitort2(A)->
% 	spawn_monitor(fun()-> io:format("number is :~p~n",[A]), receive after 3000 -> ok end end ).

% worker100(A)->
% 	receive
% 		after 3000->
% 			io:format("number is :~p~n",[A]),
% 			worker100(A)
% 	end.

r() ->
    erlang:group_leader(whereis(user), self()),
    io:format("hello").

z(File) ->
    Out = compile:file(["./", atom_to_list(File), ".erl"],
        [{outdir, "./"}, {i, "./src/"}, debug_info]),
    Out.

ctest() ->
    [c:l(test1)].

etsFun111() ->
    Tab = ets:new(test, [bag, named_table]),
    ets:insert(test, [{a, 1}, {b, 2}]).


hnl(Mod) ->
    case code:get_object_code(Mod) of
        {_Module, Bin, Fname} ->
            rpc:eval_everywhere(nodes(hidden), load_binary, [Mod, Fname, Bin]);
        Other ->
            Other
    end.

words(Words) ->
    lists:flatten([0 || _X <- lists:seq(1, Words div 2)]).



substrings(S) ->
    Slen = length(S),
    [string:sub_string(S, B, E) ||
        B <- lists:seq(1, Slen), E <- lists:seq(B, Slen)].

fat_processes() ->
    fat_processes(10).
fat_processes(C) ->
    L = lists:sort([{proplists:get_value(heap_size, L),
        P,
        proplists:get_value(initial_call, L),
        proplists:get_value(current_function, L)}
        || {L, P} <- [{process_info(P), P} || P <- processes()]]),
    lists:reverse(lists:nthtail(length(L) - C, L)).


intervals(Start, Stop, _) when Start > Stop ->
    [];
intervals(Start, Stop, N) when Start == Stop; (Start + N) > Stop ->
    [{Start, Stop}];
intervals(Start, Stop, N) ->
    [{Start, Start + N} | intervals(Start + N + 1, Stop, N)].

%% md5加密
md5test(F) ->
    {ok, File} = file:open(F, [raw, binary, read]),
    {ok, Bin} = file:read(File, filelib:file_size(F)),
    file:close(File),
    io:format("~s~n", [binary_to_list(Bin)]),
    lists:flatten([io_lib:format("~2.16.0b", [D]) || D <- binary_to_list(erlang:md5(Bin))]).

md5BigFile(F) ->
    {ok, File} = file:open(F, [raw, binary, read]),
    Context = erlang:md5_init(),
    Size = filelib:file_size(F),
    Result1 = readBigFile(File, 0, Size div 10, Size, Context),
    Result = erlang:md5_final(Result1),
    file:close(File),
    Result.

readBigFile(F, Start, ReadLength, Size, Context) when Start >= Size ->
    Context;

readBigFile(F, Start, ReadLength, Size, Context) ->
    {ok, Bin} = file:pread(F, Start, ReadLength),
    io:format("read over one times"),
    readBigFile(F, Start + ReadLength, ReadLength, Size, erlang:md5_update(Context, Bin)).

findlib() ->
    filelib:fold_files("F:/", ".*.jpg", true, fun(F1, AccIn1) -> [F1 | AccIn1] end, []).

putfile(F) ->
    {ok, File} = file:open(F, [raw, binary, read]),
    {ok, Bin} = file:read(File, filelib:file_size(F)),
    file:close(File),
    Time = filelib:last_modified(F),
    Data = erlang:md5(Bin),
    put(fileCache, {F, Data, Time}).

nano_get_url() ->  %联网的简单实例
    nano_get_url("www.baidu.com").
nano_get_url(Host) ->
    {ok, Socket} = gen_tcp:connect(Host, 80, [binary, {packet, 0}]),
    ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),
    receive_data(Socket, []).

receive_data(Socket, Sofar) ->
    receive
        {tcp, Socket, Bin} ->
            receive_data(Socket, [Bin | Sofar]);
        {tcp_closed, Socket} ->
            list_to_binary(lists:reverse(Sofar))
    end.


string2value(L) -> string2value(L, []).
string2value([], N) -> list_to_tuple(lists:reverse(N));
string2value([H | T], N) -> string2value(T, [H | N]).

start_nano_server() ->
    {ok, Listen} = gen_tcp:listen(2346, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loopSocket(Socket).

loopSocket(Socken) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Server received binary =~p~n", [Bin]),
            Str = binary_to_term(Bin),
            io:format("Server (unpacked) ~p~n", [Str]),
            Reply = string2value(Str),
            io:format("Server replying =~p~n", [Reply]),
            gen_tcp:send(Socket, term_to_binary(Reply)),
            loopSocket(Socket);
    % {tcp_closed,Socket}->
    % 	io:format("Server socket closed ~n");
        Data ->
            io:format("~p~n", [Data])
    end.

nano_client_eval(Str) ->
    {ok, Socket} = gen_tcp:connect("localhost", 2346, [binary, {packet, 4}, {active, true}]),
    ok = gen_tcp:send(Socket, term_to_binary(Str)),
    receive
        {tcp, Socket, Bin} ->
            io:format("Client received binary =~p~n", [Bin]),
            Val = binary_to_term(Bin),
            io:format("Client result =~p~n", [Val]),
            gen_tcp:close(Socket);
        Data ->
            io:format("~p~n", [Data])
    end.


downInfoLog(Node) ->
    Path = rpc:call(Node, user_default, getInfoLogPos, []),
    {ok, Bin} = rpc:call(Node, file, read_file, [Path]),
    file:write_file(atom_to_list(Node) ++ ".log", Bin).




getInfoLogPos() ->
    {ok, Path} = file:get_cwd(),
    Pos = string:str(Path, "gameserver"),
    Path1 = string:sub_string(Path, 1, Pos - 1),
    filename:join(Path1, "data/log/gameserver_info.log").

testguo() ->
    "我" =:= "我".

testbag() ->  %%bag表key可以相同，但是不可以kv都相同
    ets:new(test, [named_table, bag]),
    ets:insert(test, {a, 1}),
    A = ets:tab2list(test),
    ets:insert(test, {a, 2}),
    B = ets:tab2list(test),
    ets:insert(test, {a, 1}),
    C = ets:tab2list(test),
    ets:insert(test, {b, 1}),
    D = ets:tab2list(test),
    ets:insert(test, {b, 2}),
    E = ets:tab2list(test),
    [A, B, C, D, E].

unicodetest() ->
    Str = "我",
    A = list_to_binary(Str),
    io:format("~w~n", [Str]),
    unicode:characters_to_list(A).


dbg1() ->
    dbg:stop_clear(),
    dbg:start(),
    dbg:tracer(),
    Match = dbg:fun2ms(fun([Arg]) when is_integer(Arg) -> return_trace() end),
    dbg:p(all, call),
    dbg:tpl(test, testtracer, '_', Match).

testtracer(A) ->
    ok.


erl_(Str) ->
    {ok, Tokens, _} = erl_scan:string(Str, 2),
    io:format("~w~n", [Tokens]),
    erl_parse:parse_exprs(Tokens).

string2value1(Str) ->
    {ok, Tokens, _} = erl_scan:string(Str ++ "."),
    {ok, Exprs} = erl_parse:parse_exprs(Tokens),
    Bindings = erl_eval:new_bindings(),
    {value, Value, _} = erl_eval:exprs(Exprs, Bindings),
    Value.

% open(File)->
% 	io:format("dets opened:~p~n",[File]),
% 	Bool=filelib:is_file(File),
% 	case dets:open_file(?MODULE,[{file,File}]) of
% 		{ok,?MODULE}->
% 			case BOOL of
% 				true ->
% 					void;
% 					false->
% 						ok=dets:insert(?MODU-connect_all false LE,{free,1})
% 					end,
% 					true;
% 					{error,Reason}->
% 						io:format("cannot open dets table~n"),
% 						exit({eDetesOpen,File,Reason}) end.
% close()-> dets:close(?MODULE).

-record(shop, {item, quantity, cost}).
-record(cost, {name, price}).


do_this_noce() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(shop, [{attributes, record_info(fields, shop)}]),
    mnesia:create_table(cost, [{attibutes, record_info(fields, cost)}]),

    mnesia:stop().

mnesiadotest() ->
    mnesia:start(),

    mnesia:create_table(cost, [{attributes, record_info(fields, cost)}]),
    mnesia:create_table(shop, [{attributes, record_info(fields, shop)}]).

mnesiaDirtyUpdate() ->
    [erlang:spawn(fun() ->
        Time = calendar:datetime_to_gregorian_seconds({{2022, 2, 7}, {13, 58, 00}})
            - calendar:datetime_to_gregorian_seconds(erlang:localtime()),
        timer:sleep(Time * 1000),
        mnesia:dirty_write({cost, X, 1}) end) || X <- lists:seq(1, 1000)],
    [erlang:spawn(fun() ->
        Time = calendar:datetime_to_gregorian_seconds({{2022, 2, 7}, {13, 58, 00}})
            - calendar:datetime_to_gregorian_seconds(erlang:localtime()),
        timer:sleep(Time * 1000),
        Fun = fun() -> mnesia:write({cost, X, 1}) end,
        mnesia:transaction(Fun) end) || X <- lists:seq(1, 10000)].

mnesiaFindAll() ->
    Fun = fun() -> qlc:e(qlc:q([X || #cost{} = X <- mnesia:table(cost)])) end,
    mnesia:transaction(Fun).


print(A) when is_list(A) ->
    io:format("1:~p~n", [A]);

print(A) when not is_list(A) ->
    io:format("1:~p~n", [A]);

print([A, B]) ->
    io:fromat("1:~p~n  2:~p~n", [A, B]).
testets() ->
    Pid1 = spawn(fun() -> ets:new(test, [named_table]), receive ok -> ok end end),
    A = erlang:is_process_alive(Pid1),
    print(A),
    Pid2 = spawn(fun() -> ets:new(test, [named_table]), receive ok -> ok end end),
    B = erlang:is_process_alive(Pid2),
    print(B),
    [Pid1, Pid2, A, B].

testets1() ->
    ets:new(test, [named_table]),
    print(123).

listsmapfold() ->
    F = fun(X, Acc) ->
        {{1, X}, Acc + 1}
        end,
    lists:mapfoldl(F, 0, [1, 2, 3]).

demo11(select_shop) ->
    qlc:q([X || #shop{} = X <- mnesia:table(shop)]).

wait() ->  %%等待转换服务器
    receive
        {become, F} -> F()
    end.

http() ->
    {ok, {_State, _Heda, Body}} = httpc:request("http://erlang.org/pipermail/erlang-questions/"),
    file:write_file("F:/erlangTest/write.txt", Body).


% http://192.168.1.13:64801/webplatform:joinGameAccountRegister
% {"platform":7,"device_type":"MS-7A74 (MSI)","device_rp":"1131X636","mac":"a588af8b17d54a2a7091016f763991f6","sdk_client_id":"1",
% "duid":"a588af8b17d54a2a7091016f763991f6","account":"zcdhha1994","password":"123456"}


readtest() ->
    {ok, Bin} = file:read_file("F:/erlangTest/write.txt"),
    iolist_to_binary(Bin).

loadcode() ->
    code:add_path("F:/erlangTest/"),
    code:add_path("F:/erlangTest/sherlock/src").


parse_index() ->   %% term 写入文件
    {ok, Bin} = file:read_file("F:/erlangTest/write.txt"),
    Tree = mochiweb_html:parse(Bin),
    Rows = sherlock_get_mails:findall([<<"html">>, <<"body">>, <<"table">>, <<"tr">>], Tree),
    {ok, File} = file:open("f:/erlangTest/row1.txt", [write]),
    io:format(File, "~p~n", [Rows]),
    file:close(File).

porttest() ->
    Port = erlang:open_port({fd, 0, 0}, [binary, eof]),
    process_flag(trap_exit, true),
    Port ! {command, <<1>>},
    receive
        Msg ->
            Msg,
            io:format("Msg is ~p~n", [Msg])
    end.

loopRecive() ->
    receive
        Msg ->
            Msg,
            io:format("Msg is ~p~n", [Msg]),
            loopRecive()
    end.

my_exec(Command) ->
    Port = open_port({spawn, Command}, [stream, in, eof, hide, exit_status]),
    Result = get_data(Port, []),
    Result.
get_data(Port, Sofar) ->
    receive
        {Port, {data, Bytes}} ->
            get_data(Port, [Sofar | Bytes]);
        {Port, eof} ->
            Port ! {self(), close},
            receive
                {Port, closed} ->
                    true
            end,
            receive
                {'EXIT', Port, _} ->
                    ok
            after 1 ->              % force context switch
                ok
            end,
            ExitCode =
                receive
                    {Port, {exit_status, Code}} ->
                        Code
                end,
            {ExitCode, lists:flatten(Sofar)}
    end.

inport() ->
    Port = spawn(fun ioserver/0),
    Port ! read.


ioserver() ->
    Port = erlang:open_port({fd, 0, 1}, [binary, eof]),
    io:format("Port is ~p~n", [Port]),
    process_flag(trap_exit, true),
    receive
        read ->
            read()
    end.

read1() ->
    receive
        {Port, {data, Bytes}} ->
            io:format("Bytes is ~p~n", [Bytes]),
            write(Port, [<<33>>]);
        {Port, eof} ->
            print(2),
            ok;
        {'EXIT', Port, badsig} ->
            print(3),
            ok;
        {'EXIT', Port, Why} ->
            io:format("WHy is ~p~n", [Why]),
            ok
    end.

write(Port, Bytes) ->
    Port ! {command, Bytes}.

% -import(lists, [member/2, map/2, reverse/1]).

main() ->
    make_server(io,
        fun start_io/0, fun handle_io/2).

read() -> rpc(io, read).
write(X) -> rpc(io, {write, X}).

start_io() ->
    Port = open_port({fd, 0, 1}, [eof, binary]),
    process_flag(trap_exit, true),
    {false, Port}.

handle_io(read, {true, Port}) ->
    {eof, {true, Port}};
handle_io(read, {false, Port}) ->
    receive
        {Port, {data, Bytes}} ->
            {{ok, Bytes}, {false, Port}};
        {Port, eof} ->
            {eof, {true, Port}};
        {'EXIT', Port, badsig} ->
            handle_io(read, {false, Port});
        {'EXIT', Port, _Why} ->
            {eof, {true, Port}}
    end;
handle_io({write, X}, {Flag, Port}) ->
    Port ! {self(), {command, X}},
    {ok, {Flag, Port}}.

make_server(Name, FunD, FunH) ->
    make_global(Name,
        fun() ->
            Data = FunD(),
            server_loop(Name, Data, FunH)
        end).

server_loop(Name, Data, Fun) ->
    receive
        {rpc, Pid, Q} ->
            case (catch Fun(Q, Data)) of
                {'EXIT', Why} ->
                    Pid ! {Name, exit, Why},
                    server_loop(Name, Data, Fun);
                {Reply, Data1} ->
                    Pid ! {Name, Reply},
                    server_loop(Name, Data1, Fun)
            end;
        {cast, Pid, Q} ->
            case (catch Fun(Q, Data)) of
                {'EXIT', Why} ->
                    exit(Pid, Why),
                    server_loop(Name, Data, Fun);
                Data1 ->
                    server_loop(Name, Data1, Fun)
            end;
        {eval, Fun1} ->
            server_loop(Name, Data, Fun1)
    end.

rpc(Name, Q) ->
    Name ! {rpc, self(), Q},
    receive
        {Name, Reply} ->
            Reply;
        {Name, exit, Why} ->
            exit(Why)
    end.

cast(Name, Q) ->
    Name ! {cast, self(), Q}.

make_global(Name, Fun) ->
    case whereis(Name) of
        undefined ->
            Self = self(),
            Pid = spawn(fun() ->
                make_global(Self, Name, Fun)
                        end),
            receive
                {Pid, ack} ->
                    Pid
            end;
        Pid ->
            Pid
    end.
make_global(Pid, Name, Fun) ->
    case register(Name, self()) of
        {'EXIT', _} ->
            Pid ! {self(), ack};
        _ ->
            Pid ! {self(), ack},
            Fun()
    end.

loop() ->
    case read() of
        eof ->
            true;
        {ok, X} ->
            write([X]),
            loop()
    end.

monitorall() ->
    MonitorList = [begin
                       spawn_monitor(fun() -> ok end) end || _ <- lists:seq(1, 100)],
    io:format("LIst is ~p~n", [MonitorList]),
    [begin
         receive
             {'DOWN', Ref, process, PID, _Reason} ->
                 io:format("reason is ~p~n", [_Reason])
         end end || {PID, Ref} <- MonitorList
    ],
    io:format("ok!!!").

term_to_packet11(Term) ->
    Bin = term_to_binary(Term),
    Len = byte_size(Bin),
    <<Len:32, Bin:Len/binary>>.

packet_to_term(Packet) ->
    <<Len:32, Left/binary>> = Packet,
    binary_to_term(Left).

reverseBit(<<>>) ->
    <<>>;
reverseBit(Bin) ->
    <<X:1/bits, Left/bits>> = Bin,
    O = reverseBit(Left),
    <<O/bits, X/bits>>.
reverseBit2(Bin) ->  %%反转二进制包含的位
    reverseBit2(Bin, <<>>).
reverseBit2(<<>>, Rever) ->
    Rever;
reverseBit2(<<X:1/bits, Left/bits>>, Rever) ->
    io:format("X,Left ~p~n ", [Rever]),
    reverseBit2(Left, <<X/bits, Rever/bits>>).

practice827() ->  %%827习题
    CodeList = [Code || {Code, _} <- code:all_loaded()],
    %% 返回最长的那个列表对应的函数名，顺便构造一个{函数名，次数}的列表，返回只有一个模块中出现的函数
    {TimesList, VeryLong} = fetchCode(CodeList, [], {0, 0}),
    OneTimes = [Func || {Func, 1} <- TimesList],
    FunAndTimes = lists:last(lists:keysort(2, TimesList)),
    [FunAndTimes, VeryLong, OneTimes].

fetchCode([], TimesList, VeryLong) ->
    {TimesList, VeryLong};

fetchCode([Code | CodeList], TimesList, {OldCode, Length} = OldLong) ->
    FunctionList = [Function || {Function, _} <- proplists:get_value(exports, Code:module_info())],
    NewVeryLong = case length(FunctionList) > Length of
                      true ->
                          {Code, length(FunctionList)};
                      false ->
                          OldLong
                  end,
    F = fun(Func, Acc) ->
        case lists:keyfind(Func, 1, Acc) of
            false ->
                lists:keystore(Func, 1, Acc, {Func, 1});
            {_, Times} ->
                lists:keystore(Func, 1, Acc, {Func, Times + 1})
        end end,
    NewTimesList = lists:foldl(F, TimesList, FunctionList),
    fetchCode(CodeList, NewTimesList, NewVeryLong).

start129(AnAtom, Fun) ->
    Pid = spawn(fun() -> Fun() end),
    register(AnAtom, Pid).

randomstring() ->
    random:uniform(26) - 1 + $a.

testpid(Pid) when is_pid(Pid) ->
    pid;
testpid(Pid) when is_integer(Pid) ->
    integer.

isRecompile(File) ->
    {ok, Cwd} = file:get_cwd(),
    ModulePath = Cwd ++ "/src/",
    Time1 = filelib:last_modified(ModulePath ++ atom_to_list(File) ++ ".erl"),
    io:format("Paht is ~p~n", [ModulePath ++ atom_to_list(File) ++ ".erl"]),
    BeamPath = Cwd ++ "/ebin/",
    Time2 = filelib:last_modified(BeamPath ++ atom_to_list(File) ++ ".beam"),
    [Time2, Time1].

etsinfo() ->
    ets:new(etstest, [named_table, bag]),
    dets:open_file(?MODULE, [{file, "dets.txt"}, {type, bag}]),
    LibPath = code:lib_dir(),
    {ok, MoudleList} = file:list_dir(LibPath),
    F = fun(RawMoudleName, Bcc) ->
        DirName = filename:join(LibPath, RawMoudleName),
        ReallyModuleList = filelib:wildcard("*.beam", DirName ++ "/ebin"),
        F2 = fun(BeamName, Acc) ->
            MoudleNameStr = filename:basename(BeamName, ".beam"),
            MoudleName = list_to_atom(MoudleNameStr),
            ExportsList = MoudleName:module_info(exports),
            [begin
                 ets:insert(etstest, {Key, MoudleName}),
                 dets:insert(?MODULE, {Key, MoudleName}) end ||
                Key <- ExportsList
            ] ++ Acc
             end,
        lists:foldl(F2, Bcc, ReallyModuleList)
        end,
    lists:foldl(F, [], MoudleList).
testlength() ->
    length1([1, 2, 3]).
length1(L) ->
    "list is ok".
length2() ->
    receive
        ok ->
            ok
    end.

testSpawn() ->
    spawn(length2 / 0).

monitor111() ->
    Pid = spawn(fun() -> receive ok -> ok after 3000 -> 1 / 0 end end),
    monitor(process, Pid),
    receive
        Msg ->
            Msg
    end.

monitor2() ->
    Pid = self(),
    erlang:spawn(fun() ->
        erlang:monitor(process, Pid),
        receive Msg ->
            io:format("~p", [Msg])
        end end).


trycatch11() ->
    try
        1 / 0
    catch
        _:Error ->
            Error
    end.

ordersetets() ->
    ets:new(orderset, [named_table, ordered_set]),
    ets:insert(orderset, {33, erlang:make_ref()}),
    ets:insert(orderset, {12, erlang:make_ref()}),
    ets:insert(orderset, {44, erlang:make_ref()}),
    ets:tab2list(orderset).

testloop() ->
    receive
        ok ->
            ok
    end.

testhibernate() ->
    io:format("i,m wakeup").

testhibernate1() ->  %%谁调用休眠，谁睡觉，醒来只执行当前栈
    Pid = spawn(fun() -> erlang:hibernate(test, testhibernate, []) end).

erlangtraceloop() ->
    receive
        ok ->
            ok
    end.

erlangtrace() ->
    Pid = erlang:spawn(fun erlangtraceloop/0),
    erlang:trace(Pid, true, ['receive']),
    % erlang:trace_pattern({test,'_','_'},[{'_',[],[{return_trace}]}],[local]),
    erlang:register(zc13, Pid).

-record(zc, {name}).

testrecord() ->
    Zc = {},

    case Zc of
        Zc1 when Zc1#zc.name == 1 ->
            shide;
        _ ->
            bushi
    end.

yuanzu() ->
    M = {?MODULE, testyuanzu},
    M:testyuanzu().


testyuanzu({?MODULE, testyuanzu}) ->
    testyuanzu123455.

pmap(F, L) ->   %% 并发执行map
    Ref = erlang:make_ref(),
    S = self(),
    Pids = [spawn(fun() -> do_f(S, Ref, F, I) end) || I <- L],
    gather(Pids, Ref).

gather([Pid | T], Ref) ->
    receive
        {Pid, Ref, Ret} ->
            [Ret | gather(T, Ref)]
    end;
gather([], _Ref) ->
    [].

do_f(S, Ref, F, I) ->
    S ! {self(), Ref, catch (F(I))}.

pmap(F, L, Max) ->   %并发执行，并设定最大次数
    Ref = erlang:make_ref(),
    S = self(),
    Length = length(L),
    Fun = fun(I, {Times, L}) ->
        NewL = case Times < Max of
                   true ->
                       spawn(fun() -> do_f(S, Ref, F, I) end),
                       L;
                   false ->
                       receive
                           {Pid, Ref, Ret} ->
                               spawn(fun() -> do_f(S, Ref, F, I) end),
                               [Ret | L]
                       end
               end,
        {Times + 1, NewL}
          end,
    {Times, L1} = lists:foldl(Fun, {0, []}, L),
    Result = collect(min(Times, Max), L1),
    [Result, length(Result)].

collect(0, L) ->
    L;
collect(Times, L) ->
    receive
        {Pid, Ref, Ret} ->
            collect(Times - 1, [Ret | L])
    end.

sendSelf(Pid) ->  %% 测试在其他节点分裂进程
    Pid ! Pid.

testspawn() ->
    erlang:spawn(hd(nodes()), test, sendSelf, [self()]).

pmapNode(F, L) ->   %% 随机节点分裂进程
    Ref = erlang:make_ref(),
    S = self(),
    Nodes = nodes(),
    NodeNumber = length(Nodes),
    Length = length(L),
    Div = Length div NodeNumber,
    Pids = [erlang:spawn(lists:nth(random:uniform(NodeNumber), Nodes), test, node_do_f, [S, Ref, F, I]) || I <- L],
    gather(Pids, Ref).
pr(Arg) ->
    io:format("~p~n", [Arg]).

pmapNodeBalance(F, L) ->   %% 负载均衡的节点处理
    Ref = erlang:make_ref(),
    S = self(),
    Nodes = [node() | nodes()],
    pr(Nodes),
    NodeNumber = length(Nodes),
    Length = length(L),
    Div = Length div NodeNumber,
    Pids = [erlang:spawn(lists:nth((Num rem NodeNumber) + 1, Nodes), test, node_do_f, [S, Ref, F, lists:nth(Num, L)]) || Num <- lists:seq(1, Length)],
    gather(Pids, Ref).

node_do_f(S, Ref, F, I) ->
    S ! {self(), Ref, catch (F(I))}.

testexit12332() ->
    receive
    after 2000 ->
        io:format("我还或者")
    end.

prt(Arg) ->
    io:format("Arg is ~p~n", [Arg]).

testexit12333() ->
    spawn(fun() -> exit(testexit12332()) end).

netmonitor() ->
    net_kernel:monitor_nodes(true),
    receive
        Msg ->
            prt(Msg)
    end.

nodeRestart(Pid) ->  %% 节点重启
    Ref = erlang:monitor(process, Pid),
    io:format("Node Restart    start!!!!!!!!"),
    receive
        {'DOWN', Ref, process, Pid, Reason} ->
            rpc:call(hd(nodes()), primeapp, start, []);
        Msg ->
            prt([Msg])
    end.


start(A, B) ->
    Pid = spawn(fun() -> receive ok -> ok end end),
    {ok, Pid}.

%% 把一个列表分成n份
splitList(L, N) ->
    splitList1(L, [[] || _X <- lists:seq(1, N)]).

splitList1([], Result) ->
    Result;

splitList1([H | T], [H1 | T1]) ->
    splitList1(T, T1 ++ [[H | H1]]).

sendIo() ->
    erlang:group_leader(whereis(user), self()),
    io:format("nihao a,self is ~p~n", [self()]).
sendself() ->

    io:format("nihao a,self is ~p~n", [self()]).

deletebag() ->
    TabId = ets:new(test, [bag, named_table]),
    ets:insert(TabId, [{a, 1}, {b, 2}, {a, 3}]),
    ets:delete(TabId, a),
    ets:tab2list(TabId).

-record(zcc, {a, b, c}).
xplusone(X) ->
    X + 1.

testList123() ->
    A = #zcc{a = 1, b = 2},
    B = {},
    L = [A, B],
    [X || X <- L, begin C = #zcc{a = 1, b = 2}, 1 == 1 end, begin io:format("123~n"), C#zcc.a == 1 end].

testfoldr123() ->

    F = fun(X, Acc) ->
        1
        end,
    lists:foldl(F, [], [1, 2, 3]).


whenTest() ->
    A = 0,
    case 1 of
        1 when A > 1, A < 1 ->
            io:format("123~n");
        _ ->
            ok
    end.


levelIsIn(Level, HRLAlreadyValue) ->
    Left = Level - 1,
    BandValue = 1 bsl Left,
    HRLAlreadyValue band BandValue > 0.

levelStore(Level, HRLAlreadyValue) ->
    Left = Level - 1,
    BandValue = 1 bsl Left,
    HRLAlreadyValue + BandValue.

convert([Name]) ->
    list_to_binary(Name).
guojia() ->
    "国家".

testLoop123() ->
    receive
        ok ->
            ok
    end.

errorArity1() ->
    error(1).

errorArity2() ->
    error(1, [erlang:get_stacktrace()]).

errorArity3() ->
    error(1, ["what the fuck is "]).

errorArity4(A, B, C) ->
    error(1, none).

testandalso() ->
    false andalso (true orelse io:format("w qu ")).

testcase111() ->
    Type = 1,
    case Type == 2 of
        true ->
            print(123);
        false ->
            print(234)
    end.

testSpawnLink() ->
    erlang:process_flag(trap_exit, true),
    erlang:spawn_link('zc2@PC54854', fun() -> ok end),
    receive
        Msg ->
            io:format("~p~n", [Msg])
    end.

testSpawn134() ->
    [spawn(fun() -> ok end) || _ <- lists:seq(1, 1111111)], io:format("ok!!!").

timerTest() ->
    Ref = erlang:start_timer(55555, zc, test),
    timer:sleep(1000),
    [erlang:read_timer(Ref), Ref].

testCatch() ->
    case catch hd([]) of
        1 ->
            ok;
        Error ->
            Error
    end.

%% hibernate 之后，try catch失效测试

tryHibernate() ->
    try
        proc_lib:hibernate(?MODULE, test111111111, [])
    catch
        Error:Erro1 ->
            print(["error", Erro1])
    end.

test111111111() ->
    1 / 0,
    receive
        ok ->
            ok1
    end.

httpdStart() ->
    inets:start(),
    Result = inets:start(httpd, [
        {port, 64803},
        {server_name, "web_gs"},
        {server_root, "."},
        {document_root, "."},
        {bind_address, {192, 168, 7, 29}},
        % {erl_script_alias, {"", [web_gs]}},
        {erl_script_nocache, true}
    ]),
    [Result, self()].

requestSome(A, B, C) ->
    print([A, B, C]),
    ok.

timestamp() ->
    {A, B, C} = os:timestamp(),
    A * 1000000 + B.


encrypt(String) ->
    AppKey = "X9jUhGsfMOHIo6ka",
    Md5_16 = erlang:md5(String ++ AppKey),
    Md5_list = binary_to_list(Md5_16),
    lists:flatten(list_to_hex(Md5_list)).

list_to_hex(L) ->
    lists:map(fun(X) -> int_to_hex(X) end, L).

int_to_hex(N) when N < 256 ->
    [hex(N div 16), hex(N rem 16)].

hex(N) when N < 10 ->
    $0 + N;
hex(N) when N >= 10, N < 16 ->
    $a + (N - 10).


sendWebTest() ->
    {ok, Socket} = gen_tcp:connect("www.baidu.com", 80, []),
    gen_tcp:send(Socket, "./web_gs/mapData"),
    gen_tcp:close(Socket).

-record(record, {a, b, c}).

testRecord() ->
    #record{}
    #record{a = 1}.

testRecord1() ->
    #record{} == {record, undefined, undefined, undefined}.

create_file_slow(Name) ->
    {ok, Fd} = file:open(Name, [raw, write, delayed_write, binary]),
    create_file_slow_1(Fd, 4 bsl 20),
    file:close(Fd).

create_file_slow_1(_Fd, 0) ->
    ok;
create_file_slow_1(Fd, M) ->
    ok = file:write(Fd, <<0>>),
    create_file_slow_1(Fd, M - 1).

create_file(Name) ->
    {ok, Fd} = file:open(Name, [raw, write, delayed_write, binary]),
    create_file_1(Fd, 4 bsl 20),
    file:close(Fd),
    ok.

create_file_1(_Fd, 0) ->
    ok;
create_file_1(Fd, M) when M >= 128 ->
    ok = file:write(Fd, <<0:(128)/unit:8>>),
    create_file_1(Fd, M - 128);
create_file_1(Fd, M) ->
    ok = file:write(Fd, <<0:(M)/unit:8>>),
    create_file_1(Fd, M - 1).

-define(Trace(_), ok).

testSuite(Arg) ->
    ?Trace(Argq).

startAccept(Port) ->
    {ok, Socket} = gen_tcp:listen(Port, []),
    gen_tcp:accept(Socket),
    loopstartAccept().

startAccept1(Port) ->
    {ok, Socket} = gen_tcp:listen(Port, []),
    gen_tcp:accept(Socket),
    receive
        ok ->
            ok
    end.

loopstartAccept() ->
    receive
        {tcp_closed, _Socket} ->
            gen_tcp:close(_Socket);
        Msg ->
            io:format("MSG is ~p~n", [Msg]),
            loopstartAccept()
    end.

startUdp(Port) ->
    {ok, Socket} = gen_udp:open(Port),
    loopUdp().

loopUdp() ->
    receive
    % {tcp_closed, _Socket}->
    % 	gen_tcp:close(_Socket);
        Msg ->
            io:format("MSG is ~p~n", [Msg]),
            loopUdp()
    end.

%% block_call不像call一样spawn进程来执行function
testBlockCall(Node) ->
    rpc:block_call(Node, timer, sleep, [2000]),
    io:format("ok").
%% block_call不像call一样spawn进程来执行function
testCommonCall(Node) ->
    rpc:call(Node, timer, sleep, [2000]),
    io:format("ok").

%%beam文件转化成代码文件
beamTranslateErl(Beam) ->
    {ok, {Name, [{abstract_code, {_, AC}}]}} = beam_lib:chunks(Beam, [abstract_code]),
    file:write_file(atom_to_list(Name) ++ ".txt", erl_prettypr:format(erl_syntax:form_list(AC))).
% io:fwrite("~s~n", [erl_prettypr:format(erl_syntax:form_list(AC))]).

createEts() ->
    ets:new(test, [named_table]),
    ets:insert(test, [{a, 1}, {b, 2}]).

testMessages() ->
    [self() ! N || N <- [1, 2, 3, 4, 5]],
    print([erlang:process_info(self(), messages)]),
    timer:sleep(1000),
    print([erlang:process_info(self(), messages)]),
    timer:sleep(1000),
    print([erlang:process_info(self(), messages)]),
    timer:sleep(1000),
    print([erlang:process_info(self(), messages)]),
    timer:sleep(1000),
    print([erlang:process_info(self(), messages)]),
    receive
        MSg ->
            print([MSg])
    end.

bctunckDets() ->
    dets:open_file(test, {file, "123.txt"}),
    {Continuation, Data} = dets:bchunk(test, start),
    print([dets:info(test), Data]),
    dobctrunk(Continuation).

dobctrunk(Continuation) ->
    case dets:bchunk(test, Continuation) of
        {Continuation1, Data} ->
            print([Data]),
            dobctrunk(Continuation1);
        Msg ->
            print([Msg])
    end.

testTcpTimeout(Port) ->
    {ok, Socket} = gen_tcp:connect("127.0.0.1", Port, [{send_timeout, 2}, {send_timeout_close, true}]),
    List = lists:merge([["21212121212121212121212121212"] || _ <- lists:seq(1, 10000000)]),
    inet:setopts(Socket, [{send_timeout, 2}, {send_timeout_close, true}, {nodelay, true}]),
    Size = iolist_size(List),
    print([Size, erlang:localtime(), prim_inet:getopts(Socket, [send_timeout])]),
    spawn(test, testTcpTimeout2, [Socket, List]),
    spawn(test, testTcpTimeout1, [Socket]),
    % [spawn(test,testTcpTimeout1,[Socket])||_<-lists:seq(1,10000)],

    ok.

testTcpTimeout1(Socket) ->
    Result = gen_tcp:send(Socket, "123qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq"),
    case Result of
        {error, timeout} ->
            print([Result]);
        _ ->
            testTcpTimeout1(Socket)
    end.

testTcpTimeout2(Socket, List) ->
    print([erlang:localtime()]),
    Result = gen_tcp:send(Socket, List),
    print([Result, erlang:localtime(), prim_inet:getopts(Socket, [send_timeout])]).


startTest(Port) ->
    {ok, Socket} = gen_tcp:listen(Port, []),
    gen_tcp:accept(Socket),
    startTest1().

startTest1() ->
    receive
        {tcp_closed, _Socket} ->
            gen_tcp:close(_Socket);
        Msg ->
            startTest1()
    end.

%% 2021-12-24 practice
commonPrefix(List) ->
    lists:reverse(recursion(List, [], [])).

recursion([[H | T], [H | T1]], Temp, Result) ->
    recursion([T, T1 | Temp], [], [H | Result]);
recursion([[], _ | _], Temp, Result) ->
    Result;
recursion([_, [] | _], Temp, Result) ->
    Result;
recursion([[H | T], [H | T1] | OtherList], Temp, Result) ->
    recursion([[H | T1] | OtherList], [T | Temp], Result);
recursion([[H | T], [_ | T1] | OtherList], _, Result) ->
    Result.

testErl_parse() ->
    {ok, Tokens, Location} = erl_scan:string("{123}."),
    [erl_parse:parse_form(Tokens), erl_parse:parse_exprs(Tokens), Tokens, erl_parse:parse_term(Tokens)].

testExpr() ->
    Abs = erl_parse:abstract("1+B."),
    erl_eval:exprs(Abs, [{'B', 1}]).

testExps11(String, Binding) ->
    {ok, Tokens, _} = erl_scan:string(String),
    {ok, P} = erl_parse:parse_exprs(Tokens),
    erl_eval:exprs(P, Binding).

%% 使用compile:form replace module  手动写一个form，来替换加载的模块
replaceModule() ->
    {ok, Tokens, _} = erl_scan:string("test()-> replaceok."),
    {ok, Forms} = erl_parse:parse_form(Tokens),
    NewForm = [{attribute, 1, module, test}, {attribute, 2, export, [{test, 0}]}, Forms],
    {ok, test, Binary} = compile:forms(NewForm),
    code:purge(test),
    code:load_binary(test, test, Binary).

%% 解析文本成abstractcode
analysisString2Abstract(Sting) ->
    {ok, Tokens, _} = erl_scan:string(Sting),
    {ok, Forms} = erl_parse:parse_form(Tokens).
doAnalysisString2Abstract() ->
    String = "
initGameServer() ->
  gameserver:setValue(marchSpeed, 0),
  gameserver:setValue(battleSpeed, 0),
  gameserver:setValue(besetCity, 0),
  gameserver:setValue(formationDefeat,true),
  gameserver:setValue(beaconTowerTime, 0),
  gameserver:initBattleUrl(),
  gameserver:initMapDataPath().",
    analysisString2Abstract(String).


osGetData() ->
    Pid = spawn(fun() -> receive ok -> ok after 1 -> print([timeout]) end end),
    Pid.

%% 试试没啥用的 init_table
testInitTable() ->
    case ets:info(test) of
        undefined ->
            ets:new(test, [named_table]);
        _ ->
            ets:delete(test),
            ets:new(test, [named_table])
    end,
    ets:init_table(test, fun initTableFun/1).

initTableFun(read) ->
    {[{a, 1}, {b, 1}], fun initTableFun1/1};
initTableFun(close) ->
    print(["i,m here"]).

initTableFun1(read) ->
    {[{c, 1}], fun initTableFun2/1}.

initTableFun2(read) ->
    'end_of_input';
initTableFun2(close) ->
    print(["i,m2 here"]).



etsHeir() ->
    Pid = self(),
    spawn(fun() -> ets:new(heir, [{heir, Pid, 'imyours'}]), receive ok -> ok after 20000 -> print([over]) end end).

testKeyMerge() ->
    A = [{a, 6}, {b, 2}, {c, 4}],
    B = [{c, 3}, {d, 2}, {e, 4}],
    lists:keymerge(2, lists:keysort(2, A), lists:keysort(2, B)).

listsUsort() ->
    SortFun = fun(A, B) ->
        A =< (B - 1)
              end,
    lists:usort(SortFun, [5, 4, 1, 2, 7, 3, 1]).

testShadow() ->
    PlayerID = 1,
    L = [PlayerID || PlayerID <- [1, 2, 3, 4, 5]],
    {PlayerID, L}.

test111() ->
    erlang:binary_to_list(unicode:characters_to_binary("绽")).

test112(PlayerName) ->
    ConvertName = erlang:binary_to_list(unicode:characters_to_binary(PlayerName)),
    unicode:characters_to_list(PlayerName) == ConvertName.

translateIp(Ip) ->
    {ok, {A, B, C, D}} = inet:parse_address(Ip),
    L = lists:append([ipTranslateHandle(erlang:integer_to_list(X, 2)) || X <- [A, B, C, D]]),
    {A, B, C, D, L, erlang:list_to_integer(L, 2)}.

ipTranslateHandle(Arg) ->
    case length(Arg) of
        Length when Length =< 8 ->
            [$0 || _ <- lists:seq(1, 8 - length(Arg))] ++ Arg;
        _ ->
            false
    end.

%% 时间差
timeDiff() ->
    Time1 = erlang:now(),
    timer:sleep(1000),
    Time2 = erlang:now(),
    timer:now_diff(Time2, Time1).

timeDiff2() ->
    timer:tc(fun timeDiff/0).

integer_to_hexlist(Num) ->
    print(get_size(Num)),
    integer_to_hexlist(Num, get_size(Num), []).

integer_to_hexlist(Num, Pot, Res) when Pot < 0 ->
    print([Num | Res]),
    convert_to_ascii([Num | Res]);

%%
integer_to_hexlist(Num, Pot, Res) ->
    Position = (16 bsl (Pot * 4)),
    PosVal = Num div Position,
    integer_to_hexlist(Num - (PosVal * Position), Pot - 1, [PosVal | Res]).

get_size(Num) ->
    get_size(Num, 0).

get_size(Num, Pot) when Num < (16 bsl (Pot * 4)) ->
    Pot - 1;

get_size(Num, Pot) ->
    get_size(Num, Pot + 1).

convert_to_ascii(RevesedNum) ->
    convert_to_ascii(RevesedNum, []).

%% 将数字转化成ascii码
convert_to_ascii([], Num) ->
    Num;
convert_to_ascii([Num | Reversed], Number)
    when (Num > -1) andalso (Num < 10) ->
    convert_to_ascii(Reversed, [Num + 48 | Number]);
convert_to_ascii([Num | Reversed], Number)
    when (Num > 9) andalso (Num < 16) ->
    convert_to_ascii(Reversed, [Num + 55 | Number]).


%% 获得rfc1123_date格式的日期
rfc1123_date() ->
    {{YYYY, MM, DD}, {Hour, Min, Sec}} = calendar:universal_time(),
    DayNumber = calendar:day_of_the_week({YYYY, MM, DD}),
    lists:flatten(
        io_lib:format("~s, ~2.2.0w ~3.s ~4.4.0w ~2.2.0w:~2.2.0w:~2.2.0w GMT",
            [day(DayNumber), DD, month(MM), YYYY, Hour, Min, Sec])).


day(1) -> "Mon";
day(2) -> "Tue";
day(3) -> "Wed";
day(4) -> "Thu";
day(5) -> "Fri";
day(6) -> "Sat";
day(7) -> "Sun".

%% month

month(1) -> "Jan";
month(2) -> "Feb";
month(3) -> "Mar";
month(4) -> "Apr";
month(5) -> "May";
month(6) -> "Jun";
month(7) -> "Jul";
month(8) -> "Aug";
month(9) -> "Sep";
month(10) -> "Oct";
month(11) -> "Nov";
month(12) -> "Dec".


test1333() ->
    L1 = [1, 2, 3],
    L2 = [2, 3, 4],
    [{A, B} || A <- L1, B <- L2].


%%  转换abstract code
parse_transform(Asd, Options) ->
    FinalAsd = my_walk([], Asd),
    print(Options),
    file:write_file("Maphelper.txt", io_lib:format("~p.~n", [FinalAsd])),
    Asd.

% walk_ast(Acc, []) ->
%     case get(print_records_flag) of
%         true ->
%             insert_record_attribute(Acc);
%         false ->
%             lists:reverse(Acc)
%     end;
% walk_ast(Acc, [{attribute, _, module, {Module, _PmodArgs}}=H|T]) ->
%     %% A wild parameterized module appears!
%     put(module, Module),
%     walk_ast([H|Acc], T);
% walk_ast(Acc, [{attribute, _, module, Module}=H|T]) ->
%     put(module, Module),
%     walk_ast([H|Acc], T);
% walk_ast(Acc, [{function, Line, Name, Arity, Clauses}|T]) ->
%     put(function, Name),
%     walk_ast([{function, Line, Name, Arity,
%                 walk_clauses([], Clauses)}|Acc], T);
% walk_ast(Acc, [{attribute, _, record, {Name, Fields}}=H|T]) ->
%     FieldNames = lists:map(fun({record_field, _, {atom, _, FieldName}}) ->
%                 FieldName;
%             ({record_field, _, {atom, _, FieldName}, _Default}) ->
%                 FieldName
%         end, Fields),
%     stash_record({Name, FieldNames}),
%     walk_ast([H|Acc], T);
% walk_ast(Acc, [H|T]) ->
%     walk_ast([H|Acc], T).

my_walk(Acc, []) ->
    lists:reverse(Acc);
my_walk(Acc, [{function, Line, test1333, Arity, Clauses} | T]) ->
    my_walk([{function, Line, test1333, Arity,
        walk_clauses([], Clauses)} | Acc], T);
my_walk(Acc, [H | T]) ->
    my_walk([H | Acc], T).

transform_statement({match, Line,
    {var, _, 'L1'},
    {cons, _,
        {integer, _, 1},
        {cons, _, {integer, _, 2}, {cons, 1749, {integer, _, 3}, {nil, _}}}}} = Stmt) ->
    {match, Line,
        {var, Line, 'L1'},
        {cons, Line,
            {integer, Line, 11},
            {cons, Line, {integer, Line, 12}, {cons, Line, {integer, Line, 13}, {nil, 1749}}}}};
transform_statement(Stmt) when is_tuple(Stmt) ->
    list_to_tuple(transform_statement(tuple_to_list(Stmt)));
transform_statement(Stmt) when is_list(Stmt) ->
    [transform_statement(S) || S <- Stmt];
transform_statement(Stmt) ->
    Stmt.


walk_clauses(Acc, []) ->
    lists:reverse(Acc);
walk_clauses(Acc, [{clause, Line, Arguments, Guards, Body} | T]) ->
    walk_clauses([{clause, Line, Arguments, Guards, walk_body([], Body)} | Acc], T).

walk_body(Acc, []) ->
    lists:reverse(Acc);
walk_body(Acc, [H | T]) ->
    walk_body([transform_statement(H) | Acc], T).

testEts_new() ->
    case ets:info(test) of
        undefined ->
            ets:new(test, [bag, named_table]);
        _ ->
            ok
    end,
    ets:insert_new(test, [{a, 1}, {b, 1}, {c, 1}]),
    ets:insert_new(test, [{d, 1}, {e, 1}, {c, 1}]).

testListComprehension() ->
    L = [114, 101, 112, 108, 97, 99, 101, 32, 105, 110, 116, 111, 32, 98, 105, 95, 109, 97, 105, 108, 50, 48, 50, 50, 48, 49, 40, 109, 97, 105, 108,
        95, 105, 100, 44, 111, 119, 110, 101, 114, 95, 105, 100, 44, 116, 121, 112, 101, 44, 116, 101, 120, 116, 105, 100, 44, 114, 101, 97, 115, 111,
        110, 51, 44, 115, 101, 110, 100, 95, 116, 105, 109, 101, 44, 116, 101, 120, 116, 95, 116, 105, 116, 108, 101, 83, 116, 114, 44, 116, 101, 120,
        116, 83, 116, 114, 44, 97, 99, 99, 101, 115, 115, 111, 114, 121, 44, 109, 97, 105, 108, 95, 115, 116, 97, 116, 101, 44, 115, 116, 97, 116, 101,
        95, 116, 105, 109, 101, 95, 115, 116, 97, 109, 112, 44, 115, 101, 110, 100, 101, 114, 41, 32, 118, 97, 108, 117, 101, 115, 32, 40, 49, 57, 51,
        50, 55, 53, 52, 53, 50, 52, 54, 53, 51, 52, 56, 54, 48, 56, 51, 44, 49, 57, 51, 50, 55, 53, 48, 49, 50, 54, 54, 48, 54, 57, 55, 52, 57, 55, 55, 44, 49,
        49, 48, 49, 48, 48, 48, 48, 44, 57, 51, 44, 49, 49, 48, 52, 49, 44, 49, 54, 52, 50, 55, 53, 50, 55, 54, 53, 44, 39, "{formatArg,2,4,[]}", 39, 44,
        39, 39, 44, 39, 91, 123, 48, 44, 50, 57, 44, 52, 53, 48, 48, 125, 44, 123, 48, 44, 51, 48, 44, 52, 53, 48, 48, 125, 93, 39, 44, 52, 44, 49, 54, 52, 50,
        55, 53, 52, 49, 53, 51, 44, 48, 41],
    erlang:iolist_to_binary(L).

tryTest() ->
    try
        1
    after
        print(2)
    end.
tryTest1() ->
    tryTest(),
    print(over).

group_tokens(Ts) -> [lists:reverse(G) || G <- group_tokens([], Ts)].


group_tokens([], []) -> [];
group_tokens(Cur, []) -> [Cur];
group_tokens(Cur, [T = {dot, _} | Ts]) -> [[T | Cur] | group_tokens([], Ts)];
group_tokens(Cur, [T | Ts]) -> group_tokens([T | Cur], Ts).

-record(amazing, {a, b, c}).

recordAmazing() ->
    #amazing{_ = '_'},
    [record_info(size, amazing), record_info(fields, amazing)].

% "3.5.3"
reCompile() ->
    {ok, RE} = re:compile("^\\d\\.\\d+\\.\\d$"),
    Opts = [{capture, all, list}],
    re:run("3.55555.3", RE, Opts).


testListTp() ->
    io:format("~p", [io:getopts()]),
    list_to_binary("我").

randomAndrand() ->
    case random:uniform() of
        0.0 ->
            print(["ok"]);
        _ ->
            randomAndrand()
    end.
randomAndrand1() ->
    case rand:uniform() of
        0.0 ->
            print(["ok"]);
        _ ->
            randomAndrand1()
    end.

nullbegin() ->
    [begin ok, X end || X <- [1, 2, 3]].

testCast1() ->
    case 0 of
        A when 1 / A == 1 ->
            woshi;
        _ ->
            wobushi
    end.

testList1() ->
    [{A} || A <- [1, 0, 2, 3], is_integer(testList1_(A))].

testList1_(A) ->
    1 / A.

testList2() ->
    [B || {_, A} = B <- [{a, 1}, {b, 0}, {c, 2}, {d, 3}]].

%% 3s
testTime() ->
    print("start"),
    Nums = lll(),
    timer:tc(test, max_sliding_window, [lll(), 50000]).

max_sliding_window(Nums, K) ->
    Dict = comeDict(dict:new(), Nums, 1, length(Nums) + 1),

    case ets:info(test) of
        undefined ->
            ok;
        _ ->
            ets:delete(test)
    end,

    ets:new(test, [named_table, ordered_set]),
    slidingWindow1(Dict, K, 1, length(Nums) + 1, []),
    ok
.

slidingWindow1(Dict, K, Final, Final, Result) ->
    lists:reverse(Result);
slidingWindow1(Dict, K, Index, Final, Result) ->
    Queue1 = case ets:first(test) of
                 '$end_of_table' ->
                     ok;
                 Key1 ->
                     case Key1 =< Index - K of
                         true ->
                             ets:delete(test, Key1);
                         _ ->
                             ok
                     end end,
    % print([1,ets:tab2list(test)]),
    Queue2 = case ets:first(test) of
                 '$end_of_table' ->
                     ets:insert(test, {Index, 0});
                 _ ->
                     case dict:fetch(Index, Dict) > dict:fetch(ets:last(test), Dict) of
                         true ->
                             ets:insert(test, {Index, 0}),
                             Limit = dict:fetch(Index, Dict),
                             ets:foldl(
                                 fun({K1, _}, Acc) ->

                                     case dict:fetch(K1, Dict) < Limit of
                                         true ->

                                             ets:delete(test, K1);
                                         _ ->
                                             ok
                                     end,
                                     Acc end,
                                 Limit,
                                 test);
                         _ ->
                             ets:insert(test, {Index, 0})
                     end end,
    % print([2,ets:tab2list(test)]),
    case Index >= K of
        true ->
            slidingWindow1(Dict, K, Index + 1, Final, [dict:fetch(ets:first(test), Dict) | Result]);
        _ ->
            slidingWindow1(Dict, K, Index + 1, Final, Result)

    end.
comeDict(Dict, _, Length, Length) ->
    Dict;
comeDict(Dict, [H | T], Index, Length) ->
    comeDict(dict:store(Index, H, Dict), T, Index + 1, Length).

getHeadEts(Tree) ->
    {Key, _} = ets:first(Tree),
    Key.
getTailEts(Tree) ->
    {Key, _} = gb_trees:largest(Tree),
    Key.
treeIn(Key, Tree) ->
    gb_trees:enter(Key, 0, Tree).

lll() ->
    L = [10000, 10000, 10000, 10000, 10000, 10000, 10000, 1, 1, 1].

testMap() ->
    L = lll(),
    print(length(L)),
    L1 = lists:zip(lists:seq(1, length(L)), L),
    Maps = maps:from_list(L1),
    print(gogogogo1),
    [maps:get(100000, Maps) || _ <- lists:seq(1, 10000)],
    print(gogogogo2),
    [lists:keyfind(100000, 1, L1) || _ <- lists:seq(1, 10000)],
    print(gogogogo3).


-record(testRecord, {a, b, c, d}).
testRecordCopy() ->
    A = #testRecord{a = lll(), b = 2},
    B = A#testRecord.b,
    print(["self", self(), process_info(self(), memory)]),
    erlang:spawn(fun() -> print(["a", self(), process_info(self(), memory)]), print(is_record(A, testRecord)),
        print(["a", self(), process_info(self(), memory)]) end),
    erlang:spawn(fun() -> print(["b", self(), process_info(self(), memory)]), print(B) end).

testMemory() ->
    print(["a", self(), process_info(self())]),
    A = lll(),
    print(["a", self(), process_info(self())]),
    length(A).

%%
sendList() ->
    Pids = get(pid),
    [Pid ! lll() || Pid <- Pids],
    ok.
sendList1() ->
    Pids = get(pid),
    A = lll(),
    [Pid ! A || Pid <- Pids],
    ok.
sendBinary() ->
    A = term_to_binary(lll()),
    <<B/binary>> = A,
    Pids = get(pid),
    [Pid ! B || Pid <- Pids].


testsendmemory() ->
    Pids = [spawn(fun() -> receive 1 -> ok end end) || _ <- lists:seq(1, 10000)],
    put(pid, Pids).

testbinary() ->
    A = binary:copy(<<1>>, 100),
    <<C/binary>> = A,
    {byte_size(A), binary:referenced_byte_size(A)}.


trycatchtest() ->
    try
        1 / 0
    catch
        E:W:S ->
            asd
    end.

testtry() ->
    trycatchtest().

%% ftp copy
-define(ServerPath, "trunk/server/gameserver/data").

-define(IP, "192.168.2.3").
-define(LocalPath,"/home/zc/erlang/bootserver").


-define(User, 1).
-define(Password, 1).
-define(SyncFile,["gsbidbconfig.txt","dbconfig.txt","bidbconfig.txt"]).


start() ->
    start(?LocalPath, ?ServerPath).

startftp(LocalPath, ServerPath) ->
    ftp:start(),
    {ok, Pid} = ftp:open(?IP),
    ftp:user(Pid, ?User, ?Password),
    ftp:lcd(Pid,LocalPath),
    ftp:cd(Pid,ServerPath),
    [syncFile(Pid,SyncFile) || SyncFile <- ?SyncFile],
    ftp:close(Pid).

syncFile(Pid,FileName)->
    ftp:recv(Pid,FileName,FileName).


sync(Pid, RemotePath, LocalPath) ->
    file:make_dir(LocalPath),
    ftp:cd(Pid, RemotePath),
    ftp:lcd(Pid, LocalPath),
    {ok, PathString} = ftp:ls(Pid),
    {Dir, FileList} = ftpSplit(PathString),
    doSync(Pid, Dir, FileList).

doSync(Pid, Dirs, FileList) ->
    [ftp:recv(Pid, File) || File <- FileList],
    [sync(Pid, DirTemp, DirTemp) || DirTemp <- Dirs].

%% 分割ls之后的字符串，得出dir和filelist
ftpSplit(String) ->
    List1 = string:tokens(String, "\r\n "),
    doSplit(List1, [], []).
doSplit([], Dir, FileList) ->
    {Dir, FileList};
doSplit([_, _, "<DIR>", B | T], Dir, FileList) ->
    doSplit(T, [B | Dir], FileList);
doSplit([_, _, _, B | T], Dir, FileList) ->
    doSplit(T, Dir, [B | FileList]).

%% mysql连接
mysqlTest() ->
    {ok, Socket} = gen_tcp:connect("192.168.2.3", 3306, [binary, {packet, raw}, {active, false}, {recbuf, 8192}]).


%% 向web服务器发起http请求
sendWeb() ->
    TimeString = integer_to_list(timestamp()),
    SignString = encrypt(integer_to_list(timestamp())),
    JSON = "{\"timestamp\":" ++ TimeString ++ ",\"sign\":\"" ++ SignString ++ "\",\"type\":[\"3\",\"4\",\"1\",\"2\",\"5\"],\"state\":1,\"level\":1,}",
    % JSON="{\"BattleID\":123,\"ExternalActions\":123,\"ActionsType\":123,\"BattleData\":123}",
    httpc:request(post, {"http://192.168.2.6:64802/web_gs:onGmClearFormation", [], "application/json", JSON}, [], []).


%% http请求注册账号
requestRegist() ->
    JSON = "{\"platform\":7,\"device_type\":\"MS-7A74 (MSI)\",\"device_rp\":\"1131X636\",\"mac\":\"a588af8b17d54a2a7091016f763991f6\",\"sdk_client_id\":\"1\",
 \"duid\":\"a588af8b17d54a2a7091016f763991f6\",\"account\":\"zcdhha1993\",\"password\":\"123456\"}",
    httpc:request(post, {"http://192.168.1.13:64801/webplatform:joinGameAccountRegister", [], "application/json", JSON}, [], []).

-record(perpe1, {name, zc}).


getClientTrueIp() ->
    Env = [{server_software, "inets/7.3.2.2"}, {server_name,
        "webplatform"},
        {host_name,
            "iZj6c88f6l8jwlheipckkfZ"},
        {gateway_interface,
            "CGI/1.1"},
        {server_protocol,
            "HTTP/1.1"},
        {server_port,
            64801},
        {request_method,
            "POST"},
        {remote_addr,
            "127.0.0.1"},
        {peer_cert,
            undefined},
        {script_name,
            "/webplatform:gamelist"},
        {http_other,
            [{"x-forwarded-for",
                "118.112.75.53"},
                % {"x-real-ip",
                %  "118.112.75.53"},
                {"x-unity-version",
                    "2017.4.40f1"}]},
        {http_host,
            "127.0.0.1:64801"},
        {http_connection,
            "close"},
        {http_content_length,
            "50"},
        {http_content_type,
            "application/octet-stream"},
        {http_user_agent,
            "Dalvik/2.1.0 (Linux; U; Android 10; ANA-AN00 Build/HUAWEIANA-AN00)"},
        {http_accept_encoding,
            "gzip"}],
    case proplists:get_value(http_other, Env) of
        undefined ->
            proplists:get_value(remote_addr, Env);
        HttpOther ->
            case lists:keyfind("x-real-ip", 1, HttpOther) of
                false ->
                    proplists:get_value(remote_addr, Env);
                {_, IP} ->
                    IP
            end
    end.

-record(testRecord2, {name}).

%% 不得行
testRecord2() ->
    [record_info(fields, testRecord2), string2value1("record_info(fields,testRecord2)")].


testUnrigester() ->
    Pid = erlang:spawn(fun doalot/0),
    erlang:register(zc, Pid),
    erlang:is_process_alive(Pid) andalso
        begin timer:sleep(1000), catch erlang:unregister(zc) end.


doalot() ->
    ok.

testExit() ->
    Pid = self(),
    erlang:register(test, erlang:spawn(fun() -> receive ok -> io:format("hhhh") end end)),
    erlang:spawn(fun() -> Ref = erlang:send_after(5000, test, ok), Pid ! Ref end),
    timer:sleep(2333),
    receive
        Ref ->
            erlang:read_timer(Ref)
    end.

test1445() ->
    case true andalso 3818 of
        3818 ->
            yes;
        _ ->
            busji
    end.

test3200() ->
    {ok, S} = gen_tcp:connect("192.168.2.26", 4369, [{packet, 2}]),
    Binary = list_to_binary("bootclient"),
    gen_tcp:send(S, <<122, Binary/binary>>).

requestAllName() ->
    {ok, S} = gen_tcp:connect("192.168.2.26", 4369, [{packet, 2}]),
    Binary = list_to_binary("110"),
    gen_tcp:send(S, <<110>>).

request4369(Integer) ->
    {ok, S} = gen_tcp:connect("192.168.2.26", 4369, [{packet, 2}]),
    Binary = list_to_binary("110"),
    gen_tcp:send(S, <<Integer>>).

requestString(Integer) ->
    {ok, S} = gen_tcp:connect("192.168.2.26", 4369, [{packet, 2}]),
    Binary = list_to_binary("110"),
    gen_tcp:send(S, Integer).

requestStrin(Integer) ->
    {ok, S} = gen_tcp:connect("192.168.2.26", 44881, [{packet, 2}]),
    Binary = list_to_binary("110"),
    gen_tcp:send(S, Integer).

requestStr(Integer) ->
    {ok, S} = gen_tcp:connect("192.168.2.26", 35317, [{packet, 2}]),
    Binary = list_to_binary("110"),
    gen_tcp:send(S, Integer).

requestNStr() ->
    {ok, S} = gen_tcp:connect("192.168.2.26", 44881, [{packet, 2}]),
    Binary = list_to_binary("110"),
    gen_tcp:send(S, "n"),
    receive
        Msg ->
            ?LOG("msg ~p", [Msg])
    end.

requestRegister() ->
    io:format("~~~~~~~~~~~~~~~~~~~~~~"),
    Result = httpc:request(post, {"http://192.168.2.26:44881/", [], "", "n"}, [], []),
    io:format("~~~~~~~~~~~~~~~~~~~~~~"),
    ok.

requestRegister1() ->
    io:format("~~~~~~~~~~~~~~~~~~~~~~"),
    ok.

hhahahah() ->
    io:format("~~~~~~~~~~~~~~~~~~~~~~"),
    ok.

testexit(Index) ->
    Name = list_to_atom("zc" ++ integer_to_list(Index)),
    Pid = spawn(fun() -> register(Name, self()),
        timer:sleep(3),
        exit(normal) end),
    timer:sleep(3),
    case whereis(Name) of
        undefined->
            ok111;
        _->
        test:is_process_alive(Pid) andalso   io:format("~p",[test:is_process_alive(Pid)])
    end.

%%检查进程是否存活
is_process_alive(Pid)
    when is_pid(Pid) ->
    rpc:call(node(Pid), erlang, is_process_alive, [Pid]);
is_process_alive(_Pid) ->
    false.

%%    erlang:is_process_alive(Pid) andalso  process_info(Pid).
%%  lists:member({true,undefined},L).

%%   L=[{whereis(list_to_atom(Name)),erlang:is_process_alive(Pid)}||_<-lists:seq(1,6000)].
%%  lists:member({undefined,true},L).

%%    [{whereis(list_to_atom(Name)), process_info(Pid,status),erlang:is_process_alive(Pid)} || _ <- lists:seq(1, 10000)].
testexitpar() ->
    [ erlang:spawn(?MODULE,testexit,[Index])|| Index <- lists:seq(1, 500)].
testexit() ->
    [ ?MODULE:testexit(Index)|| Index <- lists:seq(1, 100000)].

testunregist()->
    register(cc,self()),
    unregister(cc),
    exit(normal).

sshCon()->
    ok=application:ensure_started(ssh),
    {ok,SSHConnRef}=ssh:connect("192.168.2.26",22,[{user,"root"},{password,"123456"}],infinity),
    {ok, SSHChannelId} = ssh_connection:session_channel(SSHConnRef, infinity),
    ssh_connection:exec(SSHConnRef, SSHChannelId,"erl -detached -noinput -setcookie WEJYJFMEKBNWIPXYZWNF -name z2222@192.168.2.26 ", infinity).
sshCon(M)->
    ok=application:ensure_started(ssh),
    {ok,SSHConnRef}=ssh:connect("192.168.2.26",22,[{user,"root"},{password,"123456"}],infinity),
    {ok, SSHChannelId} = ssh_connection:session_channel(SSHConnRef, infinity),
    ssh_connection:exec(SSHConnRef, SSHChannelId,M, infinity).

case123()->
    case {1>0,2>0} of
        {ture,ture}->
            333;
        _->
            444
    end.

when123()->
    lists:foldl(
        fun(Number,Acc) when Number >2 ->
                [Number|Acc];
            (_Number,Acc)->
                Acc
        end,[],[1,2,3,4]).

