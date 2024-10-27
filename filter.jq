.lists[]
| .name as $n
| select(
    (.subscription == "false")
    and (
      $n
      | startswith("iana-")
      | not
    )
    and (
      ["fornonlancomputers", "bogon", "The Onion Router"]
      | index($n)
      | not
    )
)
| .list
