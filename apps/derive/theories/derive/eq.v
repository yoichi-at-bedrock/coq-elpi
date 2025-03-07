(* Generates equality tests.

   license: GNU Lesser General Public License Version 2.1 or later           
   ------------------------------------------------------------------------- *)
From elpi.apps.derive Extra Dependency "eq.elpi" as eq.
From elpi.apps.derive Extra Dependency "derive_hook.elpi" as derive_hook.

From Coq Require Import Bool.
From elpi Require Import elpi.
From elpi.apps Require Import derive.

Register Coq.Numbers.Cyclic.Int63.PrimInt63.eqb as elpi.derive.eq_unit63.
Register Coq.Floats.PrimFloat.eqb as elpi.derive.eq_float64.

Elpi Db derive.eq.db lp:{{

% full resolution (composes with eq functions for parameters)
type eq-db term -> term -> term -> prop.
eq-db {{ lib:elpi.uint63 }} {{ lib:elpi.uint63 }} {{ lib:elpi.derive.eq_unit63 }} :- !.
eq-db {{ lib:elpi.float64 }} {{ lib:elpi.float64 }} {{ lib:elpi.derive.eq_float64 }} :- !.

:name "eq-db:fail"
eq-db A B F :-
  ((whd1 A A1, B1 = B); (whd1 B B1, A1 = A)), !,
  eq-db A1 B1 F.

eq-db A B _ :-
  M is "derive.eq: can't find the comparison function for terms of type " ^
          {coq.term->string A} ^ " and " ^ {coq.term->string B} ^ " respectively",
  stop M.

% quick access
type eq-for inductive -> constant -> prop.

}}.

Elpi Command derive.eq.
Elpi Accumulate File derive_hook.
Elpi Accumulate Db derive.eq.db.
Elpi Accumulate File eq.
Elpi Accumulate lp:{{
  main [str I, str O] :- !, coq.locate I (indt GR), derive.eq.main GR O _.
  main [str I] :- !, 
    coq.locate I (indt GR), coq.gref->id (indt GR) Id, O is Id ^ "_eq",
    derive.eq.main GR O _.
  main _ :- usage.

  usage :- coq.error "Usage: derive.eq <inductive type name> [<output name>]".
}}.
Elpi Typecheck.

(* hook into derive *)
Elpi Accumulate derive Db derive.eq.db.
Elpi Accumulate derive File eq.
Elpi Accumulate derive lp:{{
  
derivation (indt T) Prefix (derive "eq" (derive.eq.main T N) (eq-for T _)) :- N is Prefix ^ "eq".

}}.
