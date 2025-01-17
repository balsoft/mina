module Container_images = struct
  type t =
    { mina : string
    ; archive_node : string
    ; user_agent : string
    ; bots : string
    ; points : string
    }
end

module Block_producer = struct
  type t = { balance : string; timing : Mina_base.Account_timing.t }
end

module Extra_accounts = struct
  type t = { keypair : Signature_lib.Keypair.t; balance : string }
end

type constants =
  { constraints : Genesis_constants.Constraint_constants.t
  ; genesis : Genesis_constants.t
  }
[@@deriving to_yojson]

type t =
  { (* temporary flag to enable/disable graphql ingress deployments *)
    requires_graphql : bool
  ; k : int
  ; delta : int
  ; slots_per_epoch : int
  ; slots_per_sub_window : int
  ; proof_level : Runtime_config.Proof_keys.Level.t
  ; txpool_max_size : int
  ; block_producers : Block_producer.t list
  ; extra_genesis_accounts : Extra_accounts.t list
  ; num_snark_workers : int
  ; num_archive_nodes : int
  ; log_precomputed_blocks : bool
  ; snark_worker_fee : string
  ; snark_worker_public_key : string
  ; work_delay : int option
  ; transaction_capacity :
      Runtime_config.Proof_keys.Transaction_capacity.t option
  ; aux_account_balance : string option
  }

let default =
  { requires_graphql = false
  ; k = 20
  ; slots_per_epoch = 3 * 8 * 20
  ; slots_per_sub_window = 2
  ; delta = 0
  ; proof_level = Full
  ; txpool_max_size = 3000
  ; block_producers = []
  ; extra_genesis_accounts = []
  ; num_snark_workers = 0
  ; num_archive_nodes = 0
  ; log_precomputed_blocks = false
  ; snark_worker_fee = "0.025"
  ; snark_worker_public_key =
      (let pk, _ = (Lazy.force Key_gen.Sample_keypairs.keypairs).(0) in
       Signature_lib.Public_key.Compressed.to_string pk)
  ; work_delay = None
  ; transaction_capacity = None
  ; aux_account_balance = None
  }
