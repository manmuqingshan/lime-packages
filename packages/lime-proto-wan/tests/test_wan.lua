local libuci = require 'uci'
local test_utils = require 'tests.utils'
local wan = require 'lime.proto.wan'

local uci

describe('LiMe WAN protocol tests #protowan', function()
    it('does not allow link-local traffic from WAN', function()
        wan.setup_interface('eth0', {})

        assert.is.equal('eth0', uci:get('network', 'wan', 'device'))
        assert.is_nil(uci:get('firewall', 'lime_allow_wan_all_link_local'))
    end)

    before_each('', function()
        uci = test_utils.setup_test_uci()
        stub(libuci, 'cursor', function() return uci end)
    end)

    after_each('', function()
        libuci.cursor:revert()
        test_utils.teardown_test_uci(uci)
    end)
end)
