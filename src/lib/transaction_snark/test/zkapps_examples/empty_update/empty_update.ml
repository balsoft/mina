open Transaction_snark_tests.Util
open Core_kernel
open Mina_base
open Signature_lib
module Impl = Pickles.Impls.Step
module Inner_curve = Snark_params.Tick.Inner_curve
module Nat = Pickles_types.Nat
module Local_state = Mina_state.Local_state
module Parties_segment = Transaction_snark.Parties_segment
module Statement = Transaction_snark.Statement

let sk = Private_key.create ()

let pk = Public_key.of_private_key_exn sk

let pk_compressed = Public_key.compress pk

let account_id = Account_id.create pk_compressed Token_id.default

let tag, _, p_module, Pickles.Provers.[ prover; _ ] =
  Pickles.compile ~cache:Cache_dir.cache
    (module Zkapp_statement.Checked)
    (module Zkapp_statement)
    ~typ:Zkapp_statement.typ
    ~branches:(module Nat.N2)
    ~max_branching:(module Nat.N2) (* You have to put 2 here... *)
    ~name:"empty_update"
    ~constraint_constants:
      (Genesis_constants.Constraint_constants.to_snark_keys_header
         constraint_constants)
    ~choices:(fun ~self ->
      [ Zkapps_empty_update.rule pk_compressed; dummy_rule self ])

module P = (val p_module)

let vk = Pickles.Side_loaded.Verification_key.of_compiled tag

(* TODO: This should be entirely unnecessary. *)
let party_body = Zkapps_empty_update.generate_party pk_compressed

let party_proof =
  Async.Thread_safe.block_on_async_exn (fun () ->
      prover []
        { transaction = Party.Body.digest party_body
        ; at_party = Parties.Call_forest.empty
        })

let party : Party.t = { body = party_body; authorization = Proof party_proof }

let deploy_party_body : Party.Body.t =
  (* TODO: This is a pain. *)
  { Party.Body.dummy with
    public_key = pk_compressed
  ; update =
      { Party.Update.dummy with
        verification_key =
          Set
            { data = vk
            ; hash =
                (* TODO: This function should live in
                   [Side_loaded_verification_key].
                *)
                Zkapp_account.digest_vk vk
            }
      }
  ; account_precondition = Accept
  ; use_full_commitment = true
  }

let deploy_party : Party.t =
  (* TODO: This is a pain. *)
  { body = deploy_party_body; authorization = Signature Signature.dummy }

let protocol_state_precondition = Zkapp_precondition.Protocol_state.accept

let ps =
  (* TODO: This is a pain. *)
  Parties.Call_forest.of_parties_list
    ~party_depth:(fun (p : Party.t) -> p.body.call_depth)
    [ deploy_party; party ]
  |> Parties.Call_forest.accumulate_hashes_predicated

let memo = Signed_command_memo.empty

let transaction_commitment : Parties.Transaction_commitment.t =
  (* TODO: This is a pain. *)
  let other_parties_hash = Parties.Call_forest.hash ps in
  let protocol_state_predicate_hash =
    Zkapp_precondition.Protocol_state.digest protocol_state_precondition
  in
  let memo_hash = Signed_command_memo.hash memo in
  Parties.Transaction_commitment.create ~other_parties_hash
    ~protocol_state_predicate_hash ~memo_hash

let fee_payer =
  (* TODO: This is a pain. *)
  { Party.Fee_payer.body =
      { Party.Body.Fee_payer.dummy with
        public_key = pk_compressed
      ; balance_change = Currency.Fee.(of_int 100)
      ; protocol_state_precondition
      }
  ; authorization = Signature.dummy
  }

let full_commitment =
  (* TODO: This is a pain. *)
  Parties.Transaction_commitment.with_fee_payer transaction_commitment
    ~fee_payer_hash:(Party.digest (Party.of_fee_payer fee_payer))

(* TODO: Make this better. *)
let sign_all ({ fee_payer; other_parties; memo } : Parties.t) : Parties.t =
  let fee_payer =
    match fee_payer with
    | { body = { public_key; _ }; _ }
      when Public_key.Compressed.equal public_key pk_compressed ->
        { fee_payer with
          authorization =
            Schnorr.Chunked.sign sk
              (Random_oracle.Input.Chunked.field full_commitment)
        }
    | fee_payer ->
        fee_payer
  in
  let other_parties =
    List.map other_parties ~f:(function
      | { body = { public_key; use_full_commitment; _ }
        ; authorization = Signature _
        } as party
        when Public_key.Compressed.equal public_key pk_compressed ->
          let commitment =
            if use_full_commitment then full_commitment
            else transaction_commitment
          in
          { party with
            authorization =
              Signature
                (Schnorr.Chunked.sign sk
                   (Random_oracle.Input.Chunked.field commitment))
          }
      | party ->
          party)
  in
  { fee_payer; other_parties; memo }

let parties : Parties.t =
  sign_all { fee_payer; other_parties = [ deploy_party; party ]; memo }

let () =
  Ledger.with_ledger ~depth:ledger_depth ~f:(fun ledger ->
      let (_ : _) =
        Ledger.get_or_create_account ledger account_id
          (Account.create account_id
             Currency.Balance.(
               Option.value_exn (add_amount zero (Currency.Amount.of_int 500))))
      in
      apply_parties ledger [ parties ])
