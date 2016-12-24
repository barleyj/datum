%%
%%   Copyright (c) 2012 - 2013, Dmitry Kolesnikov
%%   All Rights Reserved.
%%
%%   Licensed under the Apache License, Version 2.0 (the "License");
%%   you may not use this file except in compliance with the License.
%%   You may obtain a copy of the License at
%%
%%       http://www.apache.org/licenses/LICENSE-2.0
%%
%%   Unless required by applicable law or agreed to in writing, software
%%   distributed under the License is distributed on an "AS IS" BASIS,
%%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%   See the License for the specific language governing permissions and
%%   limitations under the License.
%%
%%   @description
%%      binary search tree 
-module(bst).

-export([
   new/0         %% O(1)
  ,build/1       %% O(n)
  ,apply/3       %% O(log n)
  ,insert/3      %% O(log n)
  ,lookup/2      %% O(log n)
  ,remove/2      %% O(log n)
  ,min/1         %% O(log n)
  ,max/1         %% O(log n)
  ,map/2         %% O(n)
  ,foldl/3       %% O(n)
  ,mapfoldl/3    %% O(n)
  ,foldr/3       %% O(n)
  ,mapfoldr/3    %% O(n)
  ,splitwith/2   %% O(log n)
  ,takewhile/2   %% O(log n)
  ,take/2        %% O(log n)
  ,dropwhile/2   %% O(log n)
  ,drop/2        %% O(log n)  
  ,list/1        %% O(n)
]).

-define(NULL,   nil).

-type(tree() :: {tree(), key(), val(), tree()} | ?NULL).
-type(key()  :: any()).
-type(val()  :: any()).

%%
%% create new binary search tree
-spec new() -> datum:tree().

new()  ->
   {t, ?NULL}.

%%
%% build tree from data type
-spec build(list()) -> datum:tree().

build(X)
 when is_list(X) ->
   {t, list_to_tree(X)}.

list_to_tree([]) ->
   ?NULL;
list_to_tree([{K, V}]) ->
   {?NULL, K, V, ?NULL};
list_to_tree([K])  ->
   {?NULL, K, undefined, ?NULL};
list_to_tree(List) ->
   case lists:split(length(List) div 2, List) of
      {L, [{K, V} | R]} ->
         {list_to_tree(L), K, V, list_to_tree(R)};
      {L, [K | R]} ->
         {list_to_tree(L), K, undefined, list_to_tree(R)}
   end.

%%
%% apply function on element
-spec apply(function(), key(), datum:tree()) -> datum:tree().

apply(Fun, K, {t, T}) ->
   {t, apply_el(Fun, K, T)}.

apply_el(Fun, K, ?NULL) ->
   {?NULL, K, Fun(undefined), ?NULL};
apply_el(Fun, K, {A, Kx, Vx, B})
 when K =:= Kx ->
   {A, Kx, Fun(Vx), B};
apply_el(Fun, K, {A, Kx, Vx, B})
 when K  >  Kx ->
   {A, Kx, Vx, apply_el(Fun, K, B)};
apply_el(Fun, K, {A, Kx, Vx, B})
 when K  <  Kx ->
   {apply_el(Fun, K, A), Kx, Vx, B}.


%%
%% insert element
-spec insert(key(), val(), datum:tree()) -> datum:tree().

insert(K, V, {t, T}) ->
   {t, insert_el(K, V, T)}.

insert_el(K, V, ?NULL) ->
   {?NULL, K, V, ?NULL};
insert_el(K, V, {A, Kx, _, B})
 when K =:= Kx ->
   {A, Kx, V, B};
insert_el(K, V, {A, Kx, Vx, B})
 when K  >  Kx ->
   {A, Kx, Vx, insert_el(K, V, B)};
insert_el(K, V, {A, Kx, Vx, B})
 when K  <  Kx ->
   {insert_el(K, V, A), Kx, Vx, B}.

%%
%% lookup element
-spec lookup(key(), datum:tree()) -> val() | undefined.

lookup(K, {t, T}) ->
   lookup_el(K, T).

lookup_el(_, ?NULL) ->
   undefined;
lookup_el(K, {_, Kx, Vx, _})
 when K =:= Kx ->
   Vx;
lookup_el(K, {_, Kx,  _, B})
 when K  >  Kx ->
   lookup_el(K, B);
lookup_el(K, {A, Kx,  _, _})
 when K  <  Kx ->
   lookup_el(K, A).

%%
%% remove element
-spec remove(key(), datum:tree()) -> datum:tree().

remove(K, {t, T}) ->
   {t, remove_el(K, T)}.

remove_el(_K, ?NULL) ->
   ?NULL;
remove_el(K, {A, Kx, _, ?NULL})
 when K =:= Kx ->
   A;
remove_el(K, {?NULL, Kx, _, B})
 when K =:= Kx ->
   B;
remove_el(K, {{_, Ka, Va, _}=A, Kx, _, B})
 when K =:= Kx ->
   {remove_el(Ka, A), Ka, Va, B};
remove_el(K, {A, Kx, Vx, B})
 when K  >  Kx ->
   {A, Kx, Vx, remove_el(K, B)};
remove_el(K, {A, Kx, Vx, B})
 when K  <  Kx ->
   {remove_el(K, A), Kx, Vx, B}.


%%
%% return smallest element
-spec min(tree()) -> {key(), val()} | undefined.

min({t, T}) ->
   min_el(T).

min_el({?NULL, K, V, _}) ->
   {K, V};
min_el({A, _, _, _}) ->
   min_el(A);
min_el(?NULL) ->
   undefined.

%%
%% return largest element
-spec max(tree()) -> {key(), val()}.

max({t, T}) ->
   max_el(T).

max_el({_, K, V, ?NULL}) ->
   {K, V};
max_el({_, _, _, B}) ->
   max_el(B);
max_el(?NULL) ->
   undefined.

%%
%% map tree
-spec map(function(), datum:tree()) -> datum:tree().

map(Fun, {t, T}) ->
   {t, map_el(Fun, T)}.

map_el(_Fun, ?NULL) ->
   ?NULL;
map_el(Fun, {A, K, V, B}) ->
   {map_el(Fun, A), K, Fun(K, V), map_el(Fun, B)}.


%%
%% fold function over tree 
-spec foldl(function(), any(), datum:tree()) -> any().

foldl(Fun, Acc, {t, T}) ->
   foldl_el(Fun, Acc, T).

foldl_el(_Fun, Acc0, ?NULL) ->
   Acc0;
foldl_el(Fun, Acc0, {A, K, V, B}) ->
   foldl_el(Fun, Fun(K, V, foldl_el(Fun, Acc0, A)), B).

%%
%% map and fold function over tree
-spec mapfoldl(function(), any(), datum:tree()) -> {datum:tree(), any()}.

mapfoldl(Fun, Acc0, {t, T}) ->
   {Tx, Acc} = mapfoldl_el(Fun, Acc0, T),
   {{t, Tx}, Acc}.

mapfoldl_el(_Fun, Acc0, ?NULL) ->
   {?NULL, Acc0};
mapfoldl_el(Fun, Acc0, {A, K, V, B}) ->
   {Ax, AccA} = mapfoldl_el(Fun, Acc0, A),
   {Vx, AccK} = Fun(K, V, AccA),
   {Bx, AccB} = mapfoldl_el(Fun, AccK, B),
   {{Ax, K, Vx, Bx}, AccB}.


%% 
%% fold function over tree 
-spec foldr(function(), any(), datum:tree()) -> any().

foldr(Fun, Acc, {t, T}) ->
   foldr_el(Fun, Acc, T).

foldr_el(_Fun, Acc0, ?NULL) ->
   Acc0;
foldr_el(Fun, Acc0, {A, K, V, B}) ->
   foldr_el(Fun, Fun(K, V, foldr_el(Fun, Acc0, B)), A).

%%
%% map and fold function over tree
-spec mapfoldr(function(), any(), datum:tree()) -> {datum:tree(), any()}.

mapfoldr(Fun, Acc0, {t, T}) ->
   {Tx, Acc} = mapfoldr_el(Fun, Acc0, T),
   {{t, Tx}, Acc}.

mapfoldr_el(_Fun, Acc0, ?NULL) ->
   {?NULL, Acc0};
mapfoldr_el(Fun, Acc0, {A, K, V, B}) ->
   {Bx, AccB} = mapfoldl_el(Fun, Acc0, B),
   {Vx, AccK} = Fun(K, V, AccB),
   {Ax, AccA} = mapfoldl_el(Fun, AccK, A),
   {{Ax, K, Vx, Bx}, AccA}.

%%
%% split tree on left and right according to predicate function.
%% the predicate function returns true for leftist keys and false otherwise. 
%% the function behaves as follows: {takewhile(...), dropwhile(...)}
-spec splitwith(function(), datum:tree()) -> {datum:tree(), datum:tree()}.

splitwith(Fun, {t, T}) ->
   {A, B} = splitwith_el(Fun, T),
   {{t, A}, {t, B}}.

splitwith_el(_Fun, ?NULL) ->
   {?NULL, ?NULL};

splitwith_el(Fun, {A, K, V, B}) ->
   case Fun(K) of
      false ->
         {Ax, Bx} = splitwith_el(Fun, A),
         {Ax, {Bx, K, V, B}};
      true  ->
         {Ax, Bx} = splitwith_el(Fun, B),
         {{A, K, V, Ax}, Bx}
   end.

%%
%% takes elements from tree while predicate function return true
-spec takewhile(function(), datum:tree()) -> datum:tree().

takewhile(Fun, {t, T}) ->
   {t, takewhile_el(Fun, T)}.

takewhile_el(_Fun, ?NULL) ->
   ?NULL;

takewhile_el(Fun, {A, K, V, B}) ->
   case Fun(K) of
      false ->
         takewhile_el(Fun, A);
      true  ->
         {A, K, V, takewhile_el(Fun, B)}
   end.

%%
%%
-spec take(integer(), tree()) -> tree().

take(N, {t, T}) ->
   {t, erlang:element(2, take_el(N, T))}.

take_el(N, ?NULL) ->
   {N, ?NULL};
take_el(N, {A, K, V, B}) ->
   case take_el(N, A) of
      {0, Ax} ->
         {0, Ax};
      {M, Ax} ->
         {R, Bx} = take_el(M - 1, B),
         {R, {Ax, K, V, Bx}}
   end.

%%
%% drops elements from tree while predicate function return true
-spec dropwhile(function(), tree()) -> tree().

dropwhile(Fun, {t, T}) ->
   {t, dropwhile_el(Fun, T)}.

dropwhile_el(_Fun, ?NULL) ->
   ?NULL;

dropwhile_el(Fun, {A, K, V, B}) ->
   case Fun(K) of
      false ->
         {dropwhile_el(Fun, A), K, V, B};
      true  ->
         dropwhile_el(Fun, B)
   end.

%%
%%
-spec drop(integer(), tree()) -> tree().

drop(N, {t, T}) ->
   {t, erlang:element(2, drop_el(N, T))}.

drop_el(N, ?NULL) ->
   {N, ?NULL};
drop_el(N, {A, K, V, B}) ->
   case drop_el(N, A) of
      {0, Ax} ->
         {0, {Ax, K, V, B}};
      {M,_Ax} ->
         drop_el(M - 1, B)
   end.

%%
%% 
-spec list(tree()) -> list().

list(Tree) ->
   foldr(
      fun(Key, Val, Acc) -> [{Key, Val} | Acc] end,
      [],
      Tree
   ).
