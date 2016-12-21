%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2007-2016 Pivotal Software, Inc.  All rights reserved.
%%

-module(credential_validation_SUITE).

-compile(export_all).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

all() ->
    [
     basic_unconditionally_accepting_succeeds,
     min_length_fails,
     min_length_succeeds
    ].

init_per_testcase(_, Config) ->
    Config.

end_per_testcase(_, Config) ->
    Config.


%%
%% Test Cases
%%

basic_unconditionally_accepting_succeeds(_Config) ->
    F = fun rabbit_credential_validator_accept_everything:validate_password/1,

    Pwd1 = crypto:strong_rand_bytes(1),
    ?assertEqual(ok, F(Pwd1)),
    Pwd2 = crypto:strong_rand_bytes(5),
    ?assertEqual(ok, F(Pwd2)),
    Pwd3 = crypto:strong_rand_bytes(10),
    ?assertEqual(ok, F(Pwd3)),
    Pwd4 = crypto:strong_rand_bytes(50),
    ?assertEqual(ok, F(Pwd4)),
    Pwd5 = crypto:strong_rand_bytes(100),
    ?assertEqual(ok, F(Pwd5)),
    Pwd6 = crypto:strong_rand_bytes(1000),
    ?assertEqual(ok, F(Pwd6)).

min_length_fails(_Config) ->
    F = fun rabbit_credential_validator_min_length:validate_password/2,

    Pwd1 = crypto:strong_rand_bytes(1),
    ?assertMatch({error, _}, F(Pwd1, 5)),
    Pwd2 = crypto:strong_rand_bytes(5),
    ?assertMatch({error, _}, F(Pwd2, 6)),
    Pwd3 = crypto:strong_rand_bytes(10),
    ?assertMatch({error, _}, F(Pwd3, 15)),
    Pwd4 = crypto:strong_rand_bytes(50),
    ?assertMatch({error, _}, F(Pwd4, 60)).

min_length_succeeds(_Config) ->
    F = fun rabbit_credential_validator_min_length:validate_password/2,

    ?assertEqual(ok, F(crypto:strong_rand_bytes(1), 1)),
    ?assertEqual(ok, F(crypto:strong_rand_bytes(6), 6)),
    ?assertEqual(ok, F(crypto:strong_rand_bytes(7), 6)),
    ?assertEqual(ok, F(crypto:strong_rand_bytes(20), 20)),
    ?assertEqual(ok, F(crypto:strong_rand_bytes(40), 30)),
    ?assertEqual(ok, F(crypto:strong_rand_bytes(50), 50)).