-module(beerl_worker).
-behaviour(gen_server).

-export([start_link/2]).

-export([init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3]).

%% =============================================================================
%% API
%% =============================================================================

start_link(Sock, Uniq) ->
    gen_server:start_link(?MODULE, {Sock, Uniq}, []).

%% ====================================================================
%% Behaviour
%% ====================================================================

init({Sock, Uniq}) ->
    {ok, #{sock => Sock, uniq => Uniq}, 500}.

handle_call(What, _From, State) ->
    {reply, {error, What}, State}.

handle_cast(What, State) ->
    lager:warning("unhandle cast to beerl_worker ~p", [What]),
    {noreply, State}.

handle_info(timeout, State=#{sock := Sock, uniq := Uniq}) ->
    lager:debug("beerl_worker timeout"),
    case do_recv(Sock, Uniq) of
	ok ->
	    {noreply, State, 100};
	closed ->
	    {stop, normal, State}
    end;

handle_info(_What, State) ->
    {noreply, State}.

terminate(normal, #{sock := Sock}) ->
    lager:debug("worker close connection: ~p~n", [Sock]),
    gen_tcp:close(Sock);

terminate(_Reason, _State) ->
    ok.

code_change(_Vsn, State, _Extra) ->
    {ok, State}.

%% ====================================================================
%% Private
%% ====================================================================

do_recv(Sock, Uniq) ->
    case gen_tcp:recv(Sock, 0, 100) of
	{ok, B} ->
	    lager:debug("line from tcp/client: ~p~n", [B]),
	    gen_tcp:send(Sock, Uniq ++ "," ++ B),
	    ok;

	{error, enotconn} ->
	    closed;

	{error, closed} ->
	    closed;

	{error, timeout} ->
	    ok
    end.
