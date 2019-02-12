require('randotracker\\helpers\\oot')
oot.sav.rupees = 99
print('------------')

-- This gets the visited rooms of a secne in a dungeon
--print(oot.sav.scene_flags:rawget(91).visited_rooms:rawget(i).get())

-- BUT this gets visited rooms in anyu part
--oot.ctx.room_clear_flags:rawget(i):get() 


local function parfavar(lol)
	print('--- ' .. lol .. ' ---')
	local npc = oot.ctx.actor_table[lol].first
	while npc ~= 'Null' do
		print(npc.id .. ' - ' .. npc.variable)
		npc = npc.next_actor
	end
	return 'Null'
end

parfavar('npc')
parfavar('prop1')
parfavar('prop2')
parfavar('bomb')
parfavar('enemy')
parfavar('item')

print('current scne ' .. oot.ctx.cur_scene)
for i = 0, 100 do
	if oot.sav.skulltula_flags:rawget(85):rawget(0):get() then print('skultula ' .. i) end
	--if oot.sav.scene_flags:rawget(91).room_clear_flags:rawget(i):get() then print('sav clear ' .. i) end
	--if oot.sav.scene_flags:rawget(91).collectible_flags:rawget(i):get() then print('sav coll ' .. i) end
	--if oot.sav.scene_flags:rawget(91).chest_flags:rawget(i):get() then print('sav chest ' .. i) end
	if oot.ctx.chest_flags:rawget(i):get() then print('chets ' .. i) end
	--if oot.ctx.switch_flags:rawget(i):get() then print('swithc ' .. i) end
	--if oot.ctx.temp_switch_flags:rawget(i):get() then print('temp cswtihc ' .. i) end
	if oot.ctx.room_clear_flags:rawget(i):get() then print('clear ' .. i) end
end