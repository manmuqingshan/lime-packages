#!/usr/bin/lua

--! LibreMesh community mesh networks meta-firmware
--!
--! Copyright (C) 2014-2023  Gioacchino Mazzurco <gio@eigenlab.org>
--! Copyright (C) 2023  Asociación Civil Altermundi <info@altermundi.net>
--!
--! SPDX-License-Identifier: AGPL-3.0-only

local libuci = require("uci")
local network = require("lime.network")
local utils = require("lime.utils")

wan = {}

wan.configured = false

function wan.configure(args)
	if wan.configured then return end
	wan.configured = true

	local uci = libuci:cursor()
	uci:set("network", "wan", "interface")
	uci:set("network", "wan", "proto", "dhcp")
	uci:save("network")
end

function wan.setup_interface(ifname, args)
	local uci = libuci:cursor()
	local vlanId = tostring(args[2] or "0")

	if vlanId ~= "0" then
		local vlanProto = args[3] or "8021q"
		local nameSuffix = args[4] or "_wan"

		local owrtDeviceName = network.sanitizeIfaceName(ifname.."_dev")

		--! Do not use . as separator as this will make netifd create an 802.1q interface anyway
		--! and sanitize ifname because it can contain dots as well (i.e. switch ports)
		local linuxName = ifname:gsub("[^%w-]", "-")..network.protoVlanSeparator..vlanId

		network.createDevice(owrtDeviceName, ifname, linuxName, vlanProto, { vid=vlanId })

		utils.log("lime.proto.wan.setup_interface(%s with VLAN ID %s, ...)", ifname, vlanId)
		uci:set("network", "wan", "device", linuxName)
	else
		utils.log("lime.proto.wan.setup_interface(%s, ...)", ifname)
		uci:set("network", "wan", "device", ifname)
	end

	uci:save("network")
end

return wan
