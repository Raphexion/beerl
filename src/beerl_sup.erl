%%%-------------------------------------------------------------------
%% @doc beerl top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(beerl_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    Beerl = #{id => beerl,
	      start => {beerl, start_link, []}},
    WorkerSup = #{id => beerl_worker_sup,
		  start => {beerl_worker_sup, start_link, []}},
    
    
    Children = [Beerl, WorkerSup],

    {ok, { {one_for_all, 1, 1}, Children} }.

%%====================================================================
%% Internal functions
%%====================================================================
