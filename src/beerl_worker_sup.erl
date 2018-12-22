-module(beerl_worker_sup).
-behaviour(supervisor).

-define(SERVER, ?MODULE).

-export([start_link/0,
	 start_worker/1]).

-export([init/1]).

%% =============================================================================
%% API
%% =============================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_worker(Sock) ->
    supervisor:start_child(?SERVER, [Sock]).

%%====================================================================
%% Behaviour
%%====================================================================

init([]) ->
    WorkerSpec = {beerl_worker, {beerl_worker, start_link, []},
		  temporary, 2000, worker, [beerl_worker]},
    {ok, {{simple_one_for_one, 1, 1}, [WorkerSpec]}}.
