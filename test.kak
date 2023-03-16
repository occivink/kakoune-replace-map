try %{
    require-module replace-map
} catch %{
    source replace-map.kak
    require-module replace-map
}

define-command assert-command-fails -params 1 %{
    eval -save-regs e %{
        reg e ''
        try %{
            eval %arg{1}
            reg e 'fail "TODO, but should have"'
        }
        eval %reg{e}
    }
}

define-command assert-selections-are -params 1 %{
    eval %sh{
        if [ "$1" != "$kak_quoted_selections" ]; then
            printf 'fail "Check failed"'
        fi
    }
}

edit -scratch *replace-map-test-1*

# error case checks
# -----------------

exec '%dia<esc>h'
reg dquote 'a' 'b'
assert-command-fails %{ replace-map }
assert-command-fails %{ replace-map -dry-run }
assert-command-fails %{ replace-map '=' }
assert-command-fails %{ replace-map '=' -dry-run }
assert-command-fails %{ replace-map dquote dquote }
assert-command-fails %{ replace-map dquote -not-found-value }
assert-command-fails %{ replace-map dquote -map-order }
assert-command-fails %{ replace-map dquote -map-order '' }
assert-command-fails %{ replace-map dquote -map-order 'aabb' }
assert-command-fails %{ replace-map dquote -map-order 'kvvk' }
assert-command-fails %{ replace-map dquote -target-register }
assert-command-fails %{ replace-map dquote -target-register '=' }

reg dquote
assert-command-fails %{ replace-map dquote }
reg dquote 'a'
assert-command-fails %{ replace-map dquote }
reg dquote 'a' 'b' 'c'
assert-command-fails %{ replace-map dquote }
reg dquote 'a' 'b' 'a' 'b'
assert-command-fails %{ replace-map dquote }

reg dquote 'a' 'b'
replace-map 'dquote' -dry-run # should not fail

reg dquote 'a' 'b' 'a' 'b'
assert-command-fails %{ replace-map -dry-run 'dquote' } # duplicate keys
replace-map -dry-run 'dquote' -allow-duplicate-keys
replace-map -dry-run 'dquote' -map-order kkvv

reg dquote 'c' 'a'
assert-command-fails %{ replace-map -dry-run 'dquote' } # absent key
replace-map -dry-run 'dquote' -not-found-keep
replace-map -dry-run 'dquote' -not-found-value 'a'

# actual replace checks
# ---------------------

# no switches
exec '%difoo<esc>%H<ret>'
reg dquote 'foo' 'bar' 'baz' 'bee'
replace-map 'dquote'
assert-selections-are "'bar'"

# different register
exec '%dibaz<esc>%H<ret>'
reg b 'foo' 'bar' 'baz' 'bee'
replace-map b
assert-selections-are "'bee'"

# -map-order
exec '%diabc<esc>%Hs.<ret>'
reg dquote 'a' 'd' 'b' 'e' 'c' 'f'
replace-map 'dquote' -map-order kvkv
assert-selections-are "'d' 'e' 'f'"

reg dquote 'd' 'e' 'f' 'a' 'b' 'c'
replace-map 'dquote' -map-order kkvv
assert-selections-are "'a' 'b' 'c'"

reg dquote 'd' 'a' 'e' 'b' 'f' 'c'
replace-map 'dquote' -map-order vkvk
assert-selections-are "'d' 'e' 'f'"

reg dquote 'a' 'b' 'c' 'd' 'e' 'f'
replace-map 'dquote' -map-order vvkk
assert-selections-are "'a' 'b' 'c'"

# -not-found-keep
exec '%diabc def ghi<esc>%HS <ret>'

reg dquote 'abc' 'hello'
replace-map 'dquote' -not-found-keep
assert-selections-are "'hello' 'def' 'ghi'"

reg dquote 'does not appear' 'wow'
replace-map 'dquote' -not-found-keep
assert-selections-are "'hello' 'def' 'ghi'"

# -not-found-value
exec '%diabc def ghi<esc>%HS <ret>'

reg dquote 'def' 'wow'
replace-map 'dquote' -not-found-value 'not-found'
assert-selections-are "'not-found' 'wow' 'not-found'"

reg dquote 'does not appear' 'bad'
replace-map 'dquote' -not-found-value 'default'
assert-selections-are "'default' 'default' 'default'"

# -allow-duplicate-keys
exec '%difoo bar<esc>%HS <ret>'

reg dquote 'foo' 'fah' 'bar' 'bah' 'foo' 'fib'
replace-map 'dquote' -allow-duplicate-keys
assert-selections-are "'fib' 'bah'"

reg dquote 'bah' 'boo' 'fib' 'fab' 'fib' 'fob' 'fib' 'fub'
replace-map 'dquote' -allow-duplicate-keys
assert-selections-are "'fub' 'boo'"

# -target-register
exec '%disimple example<esc>%HS <ret>'

reg dquote 'simple' 'complex' 'example' 'test'
replace-map 'dquote' -target-register 'r'
assert-selections-are "'simple' 'example'"
exec '"rR'
assert-selections-are "'complex' 'test'"

reg dquote 'complex' 'trivial' 'test' 'case'
replace-map 'dquote' -target-register 'dquote'
assert-selections-are "'complex' 'test'"
exec R
assert-selections-are "'trivial' 'case'"

# bonus: endless loop
exec '%diping pong<esc>%HS <ret>'

reg dquote 'ping' 'pong' 'pong' 'ping'
replace-map 'dquote'
assert-selections-are "'pong' 'ping'"
replace-map 'dquote'
assert-selections-are "'ping' 'pong'"
replace-map 'dquote'
assert-selections-are "'pong' 'ping'"
replace-map 'dquote'
assert-selections-are "'ping' 'pong'"

delete-buffer
