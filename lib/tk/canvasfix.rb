module TkItemConfigOptkeys
  def itemconfig_hash_kv(id, keys, enc_mode = [], conf = [])
    hash_kv(__conv_item_keyonly_opts(id, keys), enc_mode, conf)
  end
end
