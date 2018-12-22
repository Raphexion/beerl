-module(beerl).
-behaviour(gen_server).

-define(SERVER, ?MODULE).
-define(PORT, 9376).
-define(TCP_OPTIONS, [list, {packet, 0}, {active, false}, {reuseaddr, true}]).

-export([start_link/0]).
-export([init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3]).

%% =============================================================================
%% API
%% =============================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%====================================================================
%% Behaviour
%%====================================================================

init(_) ->
    {ok, LSock} = gen_tcp:listen(?PORT, ?TCP_OPTIONS),
    {ok, #{lsock => LSock}, 0}.

handle_call(What, _From, State) ->
    {reply, {error, What}, State}.

handle_cast(What, State) ->
    lager:warning("cast ~p not supported~n", [What]),
    {noreply, State}.

handle_info(timeout, State=#{lsock := LSock}) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    lager:debug("new connection: ~p~n", [Sock]),
    beerl_worker_sup:start_worker(Sock),
    {noreply, State, 0};

handle_info(What, State) ->
    lager:warning("info ~p not supported~n", [What]),
    {noreply, State}.

terminate(normal, #{lsock := LSock}) ->
    gen_tcp:close(LSock);

terminate(_Reason, _State) ->
    ok.

code_change(_Vsn, State, _Extra) ->
    {ok, State}.
