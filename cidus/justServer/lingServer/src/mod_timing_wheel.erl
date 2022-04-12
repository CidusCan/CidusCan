%%%-------------------------------------------------------------------
%%% @author zhongwencool@gmail.com
%%% @doc 一个简单的分层时间轮实现：类似于3维数组实现时钟
%%% 根据 http://www.embeddedlinux.org.cn/RTConforEmbSys/5107final/LiB0071.html 实现
%%% 1.时钟原理说明：
%%%  1.1. 初始化一个三层时间轮:秒刻盘：0~59个SecList, 分刻盘：0~59个MinList, 时刻盘：0~12个HourList;
%%%  1.2. SecTick由外界推动,每跳一轮(60格),SecTick复位至0,同时MinTick跳1格;
%%%  1.3. 同理MinTick每跳一轮(60格),MinTick复位至0,同时HourTick跳1格;
%%%  1.4. 最高层：HourTick跳一轮(12格）,HourTick复位至0，一个时间轮完整周期完成.
%%% 2.事件原理说明：
%%%  2.1. 设置时间为TimeOut的事件时,根据TimeOut算出发生此事件时刻的指针位置{TriggerHour,TriggerMin,TriggerSec};
%%%  2.2. 用{TriggerHour,TriggerMin,TriggerSec}与当前指针{NowHour,NowMin,NowSec}对比得出事件存放在哪一个指针(Tick);
%%%  2.3. 所有层的指针每跳到下一格(Tick01)都会触发格子的事件列表,处理每一个事件Event01：
%%%      2.3.1 根据事件Event01的剩余TimeOut算出Event01应该存在上一层(跳得更快)层的位置Pos;
%%%      2.3.2 把事件更新到新的Pos(更新TimeOut);
%%%      2.3.3 重复处理完Tick01里面所有的事件;
%%%      2.3.4 清空Tick01的事件;
%%%      2.3.5 最底层(跳最快)层所有的事件遇到指针Tick都会立即执行;
%%% 3. Tip:
%%%    3.1. 在编译时使用c(mod_timeing_wheel,[{d,'DEBUGMODE'}]).打开debug开关
%%%    3.2. 所有的API只能在定时器所在进程调用
%%% @end
%%% Created : 25. Jun 2014 10:41 PM
%%%-------------------------------------------------------------------
-module(mod_timing_wheel).

%% API 所有的API只能在定时器所在进程调用
-export([
    start/0,
    pull_tick/0,
    stop/0,
    set_timer/4,
    del_timer/1
]).

-export([
    state/0,
    func/2,

    click_test/0,
    start_click/1,
    stop_click/0,
    add_event/4,
    batch_add_print/0,
    del_timer_test/0,
    print/1,
    print_now_tick/0
]).

%% 三个时间轮序号：类似3维数组
-define(TIME_WHEEL1, 1).
-define(TIME_WHEEL2, 2).
-define(TIME_WHEEL3, 3).

-define(TWHEEL_LIST, [1, 2, 3]).%% 时间轮列表，三级
-define(MAX_WHEEL_NUM,3).%%(最高层)转得最慢时间轮序号
-define(INIT_TICK,0).%%开始时tick位置

%% 每个时间轮默认的槽数 可以根据需求调整，这里只是模拟时钟
-define(TIME_WHEEL1_SLOT_NUM, 60).%%256
-define(TIME_WHEEL2_SLOT_NUM, 60).%%64
-define(TIME_WHEEL3_SLOT_NUM, 12).%%64
-define(MAX_TIME_OUT, ?TIME_WHEEL1_SLOT_NUM*?TIME_WHEEL2_SLOT_NUM*?TIME_WHEEL3_SLOT_NUM).%% 支持的最大超时（S)

-define(SLOT, slot).
-define(CUR_SLOT, cur_slot).

%% 在编译时使用c(mod_timeing_wheel,[{d,'DEBUGMODE'}]).打开debug开关
-ifdef(DEBUGMODE).
-define(DEBUG(Format,ArgList), io:format(Format,ArgList)).
-else.
-define(DEBUG(Format,ArgList), ok).
-endif.
%%----------------------------------------------------------------------
%% API
%%----------------------------------------------------------------------
%% @doc 定时器初始化
start() ->
    start(?TWHEEL_LIST).

stop() ->
    stop(?TWHEEL_LIST).

%% @doc 最快指针（相当于时钟秒指针）触发的每一跳 inner tick
pull_tick() ->
    CurSlot = get_cur_slot_by_wheel(?TIME_WHEEL1),
    EventList = get_event_list_by_slot(?TIME_WHEEL1, CurSlot),
    trigger_event(EventList),
    %% 更新(转得最快)层slot的定时器列表
    set_event_list_to_slot(?TIME_WHEEL1, CurSlot,[]),
    pull_next_tick(?TIME_WHEEL1, CurSlot).

%% @doc 设置一个定时器 return
-spec set_timer(TimeOut, Module, Method, Args) -> {ok,Key}|{error,bad_time_out,TimeOut} when
    TimeOut ::integer(),
    Module :: atom(),
    Method :: atom(),
    Args   :: list(),
    Key    :: erlang:make_ref().
set_timer(TimeOut, Module, Method, Args) when TimeOut < ?MAX_TIME_OUT andalso TimeOut> 0 ->
    set_timer2(TimeOut, Module, Method, Args);
set_timer(TimeOut,_Module, _Method, _Args) ->
    {error,bad_time_out,TimeOut}.

%% @doc 删除一个定时器
-spec del_timer(Key) -> ok|{error,not_exist} when
    Key    :: erlang:make_ref().%% 从set_timer的返回值得到
del_timer(Key) ->
    case get_key_mapping(Key) of
        {error,_Reason}=Err -> Err;
        {TWheel,Slot} ->
            EventList = get_event_list_by_slot(TWheel, Slot),
            set_event_list_to_slot(TWheel, Slot, lists:keydelete(Key,1,EventList)),
            ok
    end.

%%----------------------------------------------------------------------
%% Internal Function
%%----------------------------------------------------------------------

start([]) ->
    ok;
start([TWheel|Tail]) ->
    init_twheel_slot(TWheel),
    start(Tail).

stop([]) ->
    ok;
stop([TWheel|Tail]) ->
    erase_twheel_slot(TWheel),
    stop(Tail).

%% @doc 初始化时间轮
init_twheel_slot(TWheelNum) ->
    %% 初始化tick指针位置
    set_cur_slot_by_wheel(TWheelNum, ?INIT_TICK),
    init_twheel_slot(TWheelNum, get_max_slot_by_wheel(TWheelNum)).

init_twheel_slot(TWheel, ?INIT_TICK) ->
    set_event_list_to_slot(TWheel, ?INIT_TICK, []);
init_twheel_slot(TWheel, Slot) ->
    set_event_list_to_slot(TWheel, Slot-1, []),
    init_twheel_slot(TWheel, Slot - 1).

erase_twheel_slot(TWheelNum) ->
    erase_cur_slot_by_wheel(TWheelNum),
    erase_twheel_slot(TWheelNum, get_max_slot_by_wheel(TWheelNum)).

erase_twheel_slot(TWheel, ?INIT_TICK) ->
    erase_event_list_to_slot(TWheel, ?INIT_TICK);
erase_twheel_slot(TWheel, Slot) ->
    erase_event_list_to_slot(TWheel, Slot-1),
    erase_twheel_slot(TWheel, Slot - 1).

pull_next_tick(UpperTWheel, UpperCurSlot) ->
    UpperMaxSlot = get_max_slot_by_wheel(UpperTWheel),
    pull_next_tick2(UpperTWheel, UpperCurSlot, UpperMaxSlot).

%% 已到最高层的最后一个tick(相当于时钟已到00:59,下一跳就是00：00)
pull_next_tick2(?MAX_WHEEL_NUM, UpperCurSlot, UpperMaxSlot)when UpperCurSlot >= UpperMaxSlot-1 ->
    set_cur_slot_by_wheel(?MAX_WHEEL_NUM,?INIT_TICK);
%% 上一层指针已跑满一轮（相当于时钟11:00:59 或11：59：00下一跳会使时钟next tick跳一下到：11:01:00或00：00：00）
pull_next_tick2(UpperTWheel, UpperCurSlot, UpperMaxSlot) when UpperCurSlot >= UpperMaxSlot-1 ->
    %% 复位上一层时间轮指针
    set_cur_slot_by_wheel(UpperTWheel, ?INIT_TICK),
    %% 从这层时间轮取出定时器列表
    CurTWheel = get_next_wheel(UpperTWheel),
    CurSlotT = get_cur_slot_by_wheel(CurTWheel),
    CurSlot = case CurSlotT >= get_max_slot_by_wheel(CurTWheel)-1 of
                   true -> ?INIT_TICK;
                   false -> CurSlotT +1
               end,
    EventList = get_event_list_by_slot(CurTWheel, CurSlot),
    %% 更新这层slot的定时器
    set_event_list_to_slot(CurTWheel, CurSlot, []),
    %% 放入上一层的时间轮
    ?DEBUG("Tick:::::::EventList:~w~n",[EventList]),
    handle_event_list(CurTWheel, EventList),
    pull_next_tick(CurTWheel, CurSlotT);
%% 上一层没有跑完一轮
pull_next_tick2(UpperTWheel, UpperCurSlot, _UpperMaxSlot) ->
    set_cur_slot_by_wheel(UpperTWheel, UpperCurSlot+1).

handle_event_list(_TWheel,[]) ->
    ok;
handle_event_list(TWheel, EventList) ->
    {NowTick,NowH,NowM,NowS} = get_all_time_tick(),
    handle_event_list2(TWheel, EventList, NowTick, NowH, NowM, NowS).

handle_event_list2(TWheel, [{Key, TimeOut, Module, Method, Arg}|Tail], NowTick, NowH, NowM, NowS) ->
    {NewTWheel, NewSlot, NewTimeOut} = get_slot_by_timeout(TimeOut,NowTick,NowH,NowM,NowS),

    EventList = get_event_list_by_slot(NewTWheel, NewSlot),
    set_event_list_to_slot(NewTWheel, NewSlot, [{Key,NewTimeOut, Module, Method, Arg}|EventList]),

    update_key_mapping(Key,{NewTWheel,NewSlot}),

    handle_event_list(TWheel, Tail).

%% 触发定时器事件
trigger_event([]) ->
    ok;
trigger_event([{Key, _TimeOut, Module, Method, Arg}|Tail]) ->
    try
        erlang:apply(Module, Method, Arg)
    catch _E:_Reason ->
        io:format("trigger event error:~p,Reason:~p  Module:~p Method:~p Arg:~p~n",[_E,_Reason,Module,Method,Arg])
    end,
    erase_key_mapping(Key),
    trigger_event(Tail).

set_timer2(TimeOut, Module, Method, Arg) ->
    {NowTick,NowH,NowM,NowS} = get_all_time_tick(),
    {TWheel, Slot, TimeOut2} = get_slot_by_timeout(TimeOut,NowTick,NowH,NowM,NowS),
    ?DEBUG("Set timer:wheel~w:Slot:~w:TimeOut:~w~n",[TWheel, Slot, TimeOut2]),
    EventList = get_event_list_by_slot(TWheel, Slot),
    Key = erlang:make_ref(),
    set_event_list_to_slot(TWheel, Slot, [{Key, TimeOut2, Module, Method, Arg}|EventList]),
    update_key_mapping(Key,{TWheel,Slot}),
    {ok,Key}.

%% return {WheelNum,slot,Timeout}
get_slot_by_timeout(0,_NowTick,_NowH,_NowM,_NowS) ->
    {?TIME_WHEEL1, get_cur_slot_by_wheel(?TIME_WHEEL1), 0};
get_slot_by_timeout(TimeOut,NowTick,NowH,NowM,NowS) ->
    TriggerTime = NowTick+TimeOut,
    {TriggerH,TriggerM,TriggerS} = get_tick_pos(TriggerTime),
    if TriggerTime >= ?MAX_TIME_OUT ->
        {?TIME_WHEEL3, TriggerH, TriggerTime - ?MAX_TIME_OUT};
        TriggerH =/= NowH ->
        {?TIME_WHEEL3, TriggerH, cal_timeout_hour(TriggerM,TriggerS)};
        TriggerM =/= NowM ->
            {?TIME_WHEEL2, TriggerM, TriggerS};
        TriggerS =/= NowS ->
            {?TIME_WHEEL1, TriggerS, 0};
        true ->
            io:format("error:TimeOut~w:~w::~w:~n",[TimeOut,{NowH,NowM,NowS},{TriggerH,TriggerM,TriggerS}])
    end.

cal_timeout_hour(TriggerM,TriggerS) ->
    ?DEBUG("Line:~w,cal_timeout_hour:~w~n",[?LINE,TriggerM*get_wheel_max_tick(?TIME_WHEEL1) + TriggerS]),
    TriggerM*get_wheel_max_tick(?TIME_WHEEL1) + TriggerS.

%%通过总tick得到3个指针的位置
get_tick_pos(Tick) ->
    SecPre = get_wheel_max_tick(?TIME_WHEEL2),
    MinPre = get_wheel_max_tick(?TIME_WHEEL1),
    Secs0 = Tick rem get_wheel_max_tick(?TIME_WHEEL3),
    Hour = Secs0 div SecPre,
    Secs1 = Secs0 rem SecPre,
    Minute =  Secs1 div MinPre,
    Second =  Secs1 rem MinPre,
    {Hour, Minute, Second}.

%% return {NowTick总数,HourPos,MinPos,SecPos}
get_all_time_tick() ->
    ThirdPos = get_cur_slot_by_wheel(?TIME_WHEEL3),
    SecPos = get_cur_slot_by_wheel(?TIME_WHEEL2),
    FirstPos = get_cur_slot_by_wheel(?TIME_WHEEL1),
    {ThirdPos*get_wheel_max_tick(?TIME_WHEEL2)+
        SecPos*get_wheel_max_tick(?TIME_WHEEL1)+
        FirstPos, ThirdPos, SecPos, FirstPos}.

print_now_tick() ->
    NowTick = {get_cur_slot_by_wheel(?TIME_WHEEL3),
        get_cur_slot_by_wheel(?TIME_WHEEL2),
        get_cur_slot_by_wheel(?TIME_WHEEL1)},
    io:format("Tick:~w ~n",[NowTick]),
    NowTick.

%% 获取下一级时间轮序号
get_next_wheel(WheelNum) ->
    WheelNum+1.

%% 这一层时间轮最大的tick数
get_wheel_max_tick(TWheel) ->
    get_wheel_max_tick(TWheel, 1).

get_wheel_max_tick(0, Tick) ->
    Tick;
get_wheel_max_tick(TWheel, Tick) ->
    get_wheel_max_tick(TWheel-1, Tick * get_max_slot_by_wheel(TWheel)).

%% 获取指定时间轮时间slot个数
get_max_slot_by_wheel(?TIME_WHEEL1) ->
    ?TIME_WHEEL1_SLOT_NUM ;
get_max_slot_by_wheel(?TIME_WHEEL2) ->
    ?TIME_WHEEL2_SLOT_NUM  ;
get_max_slot_by_wheel(_) ->
    ?TIME_WHEEL3_SLOT_NUM .

%%----------------------------------------------------------------------
%% 进程字典相关 INTERVAL FUNC
%%----------------------------------------------------------------------

get_cur_slot_by_wheel(TWheelNum) ->
    erlang:get({?MODULE, ?CUR_SLOT, TWheelNum}).

set_cur_slot_by_wheel(TWheel, Index) ->
    erlang:put({?MODULE, ?CUR_SLOT, TWheel}, Index).

erase_cur_slot_by_wheel(TWheelNum) ->
    erlang:erase({?MODULE, ?CUR_SLOT, TWheelNum}).

set_event_list_to_slot(TV, Slot, List) ->
    erlang:put({?MODULE, ?SLOT, TV, Slot}, List).

get_event_list_by_slot(TWheelNum, Slot) ->
    erlang:get({?MODULE, ?SLOT, TWheelNum, Slot}).

erase_event_list_to_slot(TWheel, Slot) ->
    erlang:erase({?MODULE, ?SLOT, TWheel, Slot}).

update_key_mapping(Key,Pos) ->
    erlang:put(Key,Pos).

get_key_mapping(Key) ->
    case erlang:get(Key) of
        undefined -> {error,not_exist};
        Pos -> Pos
    end.

erase_key_mapping(Key) ->
    erlang:erase(Key).

%%----------------------------------------------------------------------
%% Only For Test
%%----------------------------------------------------------------------

click_test() ->
    start_click(350),
    timer:sleep(350*11),%%开始事件，让最后几个事件也加到此00:00:00hour里面测试
    batch_add_print().

start_click(Tick) ->
    erlang:register(?MODULE,erlang:spawn(fun() -> start_click2(Tick) end)).

stop_click() ->
    erlang:send(?MODULE, stop).

add_event(TimeOut, Module, Method, Arg) ->
    erlang:send(?MODULE,{add_event,[{TimeOut, Module, Method, Arg}]}).

batch_add_print() ->
    EventList = [begin {TimeOut, ?MODULE, print, [TimeOut]} end||TimeOut<- lists:seq(1,?MAX_TIME_OUT)],
    erlang:send(?MODULE,{add_event,EventList}).

start_click2(Tick) ->
    start(),
    erlang:send_after(Tick,self(),loop),
    loop(Tick).

loop(Tick) ->
    receive
        loop ->
            erlang:send_after(Tick,self(),loop),
            pull_tick(),
            loop(Tick);
        {add_event,EventList} ->
            [begin set_timer(TimeOut, Module, Method, Arg) end|| {TimeOut, Module, Method, Arg} <- EventList],
            loop(Tick);
        {func,From,Method,Arg} ->
            Res = erlang:apply(?MODULE, Method, Arg),
            erlang:send(From,Res),
            loop(Tick);
        stop ->
            {stop,Tick}
    end.
%% @doc 查定时器状态
state() ->
    erlang:process_info(whereis(?MODULE)).

%% @doc 外部执行函数
func(Method,Arg) ->
    erlang:send(?MODULE, {func, self(), Method, Arg}).

print(TimeOut) ->
    io:format("TimeOutEvent:~w::",[TimeOut]),
    print_now_tick().

%% only for test
del_timer_test() ->
    {ok,Key} = set_timer(65, ?MODULE, print, ["zhongwencool"]),
    {TWheel, Slot} = get_key_mapping(Key),
    io:format("set_time:~w::EventList:~p ~n",[{TWheel, Slot},get_event_list_by_slot(TWheel, Slot)]),
    Res = del_timer(Key),
    io:format("del_time:Res~p::EventList:~p~n",[Res,get_event_list_by_slot(TWheel, Slot)]),
    ok.