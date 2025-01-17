open Mina_base

module Test_input : Transaction_snark_tests.Test_zkapp_update.Input_intf =
struct
  let test_description = "zkapp_uri"

  let snapp_update =
    { Party.Update.dummy with
      zkapp_uri = Zkapp_basic.Set_or_keep.Set "https://www.minaprotocol.com"
    }
end

let%test_module "Update account snapp URI" =
  ( module struct
    include Transaction_snark_tests.Test_zkapp_update.Make (Test_input)
  end )
