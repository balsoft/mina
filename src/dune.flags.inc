(env
  (_
    (flags (:standard
      -short-paths
      -ccopt=-fuse-ld=lld
      ; -ccopt=-Wl,--allow-multiple-definition
      ;-ccopt=-B/nix/store/y2habf5wqpnhv4dr6b2k17dry40l3v4l-ld-wrapper-/bin/ld
      -cclib=-ljemalloc ; We use jemalloc as an allocator everywhere
      -w @a-4-29-40-41-42-44-45-48-58-59-60-66
))))
