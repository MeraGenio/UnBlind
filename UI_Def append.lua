function G.UIDEF.UnBlind_current_blinds() -- called by the replaced bit of code.	see lovely.toml			♥
	return {n=G.UIT.ROOT, config={align = "bm", colour = G.C.CLEAR, padding = 0.1}, nodes={
		{n=G.UIT.R, config={align = "bm", colour = G.C.DYN_UI.BOSS_MAIN , r=1, padding = 0.1, w = 2, emboss = 0.05}, nodes={
			G.GAME.round_resets.blind_states['Small'] ~= 'Hide' and
			UnBlind_create_UIBox_blind('Small') or nil,
			G.GAME.round_resets.blind_states['Big'] ~= 'Hide' and
			UnBlind_create_UIBox_blind('Big') or nil,
			G.GAME.round_resets.blind_states['Boss'] ~= 'Hide' and
			UnBlind_create_UIBox_blind('Boss') or nil
		}}
	}}
end

function UnBlind_create_UIBox_blind(type) -- Main definition for the whole of the shop_sign replacement
	local run_info = true
	local disabled = false

	local blind_choice = {  config = G.P_BLINDS[G.GAME.round_resets.blind_choices[type] ],  }

	blind_choice.animation = AnimatedSprite(0,0, 0.75, 0.75, G.ANIMATION_ATLAS[blind_choice.config.atlas] or G.ANIMATION_ATLAS['blind_chips'],  blind_choice.config.pos)
	blind_choice.animation:define_draw_steps({   {shader = 'dissolve', shadow_height = 0.05},  {shader = 'dissolve'}  })
	local temp_blind = blind_choice.animation
	local extras = nil
	local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)

	G.GAME.orbital_choices = G.GAME.orbital_choices or {}
	G.GAME.orbital_choices[G.GAME.round_resets.ante] = G.GAME.orbital_choices[G.GAME.round_resets.ante] or {}

	if not G.GAME.orbital_choices[G.GAME.round_resets.ante][type] then
	local _poker_hands = {}
	for k, v in pairs(G.GAME.hands) do
			if v.visible then _poker_hands[#_poker_hands+1] = k end
	end

	G.GAME.orbital_choices[G.GAME.round_resets.ante][type] = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
	end

	if type == 'Small' then
		extras = UnBlind_create_UIBox_blind_tag(type)
	elseif type == 'Big' then
		extras = UnBlind_create_UIBox_blind_tag(type)
	else
		extras = {n=G.UIT.R, config={id = 'tag_container', align = "cm"}, nodes={
			{n=G.UIT.R, config={id = 'empty_tag_replacement', align = "cm", r = 0.1, padding = 0.05, can_collide = true}, nodes={
				{n=G.UIT.B, config={id = 'tag_desc', align = "cm", w = 0.75, h = 0.1}, nodes={ }},
			}}
		}}
	end

	G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
	local loc_target = localize{type = 'raw_descriptions', key = blind_choice.config.key, set = 'Blind', vars = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands')}}
	local loc_name = localize{type = 'name_text', key = blind_choice.config.key, set = 'Blind'}
	local text_table = loc_target
	local blind_col = get_blind_main_colour(G.GAME.round_resets.blind_choices[type])
	local blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante)*blind_choice.config.mult*G.GAME.starting_params.ante_scaling

	local blind_state = G.GAME.round_resets.blind_states[type]
	local _reward = true

	if G.GAME.modifiers.no_blind_reward and G.GAME.modifiers.no_blind_reward[type] then _reward = nil end
	if blind_state == 'Select' then blind_state = 'Current' end
	local run_info_colour = run_info and (blind_state == 'Defeated' and G.C.GREY or blind_state == 'Skipped' and mix_colours(G.C.BLUE, G.C.GREY, 0.5) or blind_state == 'Upcoming' and G.C.ORANGE or G.C.GOLD)
	local blind_state_text_colour =  (blind_state == 'Defeated' and G.C.UI.BACKGROUND_LIGHT or   blind_state == 'Skipped' and G.C.UI.BACKGROUND_LIGHT or blind_state == 'Upcoming' and G.C.WHITE or G.C.GOLD)

	-- blind tag animatiopn bs
	local discovered = true
	local blinds_to_be_alerted = {}
	local v = blind_choice

	temp_blind.float = true
	temp_blind.states.hover.can = true
	temp_blind.states.drag.can = false
	temp_blind.states.collide.can = true
	temp_blind.config = {blind = v, force_focus = true}
	if discovered and not v.alerted then 
		blinds_to_be_alerted[#blinds_to_be_alerted+1] = temp_blind
	end
	temp_blind.hover = function()
	if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then 
		if not temp_blind.hovering and temp_blind.states.visible then
			temp_blind.hovering = true
			temp_blind.hover_tilt = 3
			temp_blind:juice_up(0.05, 0.02)
			play_sound('chips1', math.random()*0.1 + 0.55, 0.12)
			temp_blind.config.h_popup = UnBlind_create_UIBox_blind_popup(v.config, number_format(blind_amt), blind_col)
			temp_blind.config.h_popup_config ={align = 'bm', offset = {x=0,y=0.1},parent = temp_blind}
			Node.hover(temp_blind)
			if temp_blind.children.alert then 
				temp_blind.children.alert:remove()
				temp_blind.children.alert = nil
				temp_blind.config.blind.alerted = true
				G:save_progress()
			end
			end
		end
		temp_blind.stop_hover = function() temp_blind.hovering = false; Node.stop_hover(temp_blind); temp_blind.hover_tilt = 0 end
	end

	local t =				--mix_colours(G.C.BLACK, G.C.L_BLACK, 0.5)		--G.C.DYN_UI.MAIN (red)		--G.C.DYN_UI.DARK (very similar to boss_main)		--black is too close to boss_main			--l_dark is too light
	{n=G.UIT.R, config={align = "cm", colour = G.C.DYN_UI.BOSS_DARK, r = 0.1, outline = 1, outline_colour = G.C.DYN_UI.BOSS_MAIN}, nodes={
		{n=G.UIT.R, config={align = "cm", padding = 0.09}, nodes={
			{n=G.UIT.C, config={id = 'blind_extras', align = "cl"}, nodes={
				extras,
			}},
			--blind tag and desc container
			{n=G.UIT.C, config={align = "cl", padding = 0}, nodes={
				{n=G.UIT.C, config={id = 'blind_desc', align = "cm", padding = 0.05 }, nodes={
					--blind tag pos + boss desc
					--BLIND CHIP animation here btw ♥
					{n=G.UIT.O, config={object = blind_choice.animation, focus_with_object = true}},
				}},
			}},
			--select blind container
			{n=G.UIT.C, config={align = "cl", padding = 0.05 }, nodes={
				--select blind "button" (defeated or upcoming)
				{n=G.UIT.C, config={
					id = 'select_blind_button',
					align = "cm",
					ref_table = blind_choice.config,
					colour = run_info_colour,
					minh = 0.75,
					minw = 0.3,
					padding = 0.0,
					r = 3,
					emboss = 0.08,
				},
				nodes={
					--min score
					{n=G.UIT.R, config={align = "cm", minw = 2.5}, nodes={
						--"reward: $$$$+"
						_reward and {n=G.UIT.C, config={align = "cm"}, nodes={
							{n=G.UIT.T, config={text = string.rep(localize("$"), blind_choice.config.dollars)..'+', scale = 0.32, colour = disabled and G.C.UI.TEXT_INACTIVE or blind_state_text_colour, shadow = not disabled}}
						}} or nil,
						{n=G.UIT.B, config={ w=0.1, h=0.1 }},
						--"☻ 1,350"
						{n=G.UIT.C, config={align = "cm", minh = 0.4}, nodes={
							{n=G.UIT.O, config={w=0.3,h=0.3, colour = G.C.BLUE, object = stake_sprite, hover = true, can_collide = false}},
							{n=G.UIT.B, config={h=0.1,w=0.05}},
							{n=G.UIT.T, config={text = number_format(blind_amt), scale = score_number_scale(0.47, blind_amt), colour = disabled and G.C.UI.TEXT_INACTIVE or blind_state_text_colour, shadow =  not disabled}}
						}},
					}},
				}}
			}},
		}}
	}}
	return t
end

function UnBlind_hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..tonumber(hex:sub(1,2)))/256, tonumber("0x"..tonumber(hex:sub(3,4)))/256, tonumber("0x"..tonumber(hex:sub(5,6)))/256
end


function UnBlind_create_UIBox_blind_popup(blind, vars, blind_col) --definition for the blind tooltip popup.	--called in main

	local blind_col_rgb = type(blind_col)=="number" and UnBlind_hex2rgb(blind_col) or type(blind_col)=="table" and blind_col or sendErrorMessage("colour calculations are not going how toy thought they would :/", "UnBlindError")
	local blind_col_lum = 0.2126*blind_col_rgb[1] + 0.7152*blind_col_rgb[2] + 0.0722*blind_col_rgb[3]
	local max_lum = 0.65

	if blind_col_lum > max_lum then
		blind_col = darken(blind_col, 0.2)
	end

	local blind_text = {}

	local _dollars = blind.dollars
	local loc_target = localize{type = 'raw_descriptions', key = blind.key, set = 'Blind', vars = vars or blind.vars}
	local loc_name = localize{type = 'name_text', key = blind.key, set = 'Blind'}


	 local ability_text = {}
	 if loc_target then 
		for k, v in ipairs(loc_target) do
			ability_text[#ability_text + 1] = {n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = (k ==1 and blind.name == 'The Wheel' and '1' or '')..v, scale = 0.35, shadow = true, colour = G.C.WHITE}}}}
		end
	 end
	 local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.4)
	 blind_text[#blind_text + 1] =
		{n=G.UIT.R, config={align = "cm", colour = G.C.CLEAR}, nodes={
			{n=G.UIT.R, config={align = "cm", emboss = 0.05, r = 0.1, minw = 2.5, padding = 0.07, colour = G.C.WHITE}, nodes={
				{n=G.UIT.R, config={align = "cm", maxw = 2.4}, nodes={
					{n=G.UIT.T, config={text = localize('ph_blind_score_at_least'), scale = 0.35, colour = G.C.UI.TEXT_DARK}},
				}},
				{n=G.UIT.R, config={align = "cm"}, nodes={			-- 
					{n=G.UIT.O, config={object = stake_sprite}},
					{n=G.UIT.O, config={object = DynaText({string = vars, scale = 0.52, colour = G.C.RED})}},
				}},
				{n=G.UIT.R, config={align = "cm"}, nodes={
					{n=G.UIT.T, config={text = localize('ph_blind_reward'), scale = 0.35, colour = G.C.UI.TEXT_DARK}},
					{n=G.UIT.O, config={object = DynaText({string = {_dollars and string.rep(localize('$'),_dollars) or '-'}, colours = {G.C.MONEY}, rotate = true, bump = true, silent = true, scale = 0.45})}},
				}},
			}},
		}}
	return
	 {n=G.UIT.ROOT, config={align = "cm", padding = 0.1, colour = G.C.BLACK, r = 0.1, emboss = 0.05, outline_colour = G.C.WHITE, outline = 1}, nodes={
		{n=G.UIT.R, config={align = "cm", emboss = 0.05, r = 0.1, minw = 2.5, padding = 0.1, colour = blind_col}, nodes={
			{n=G.UIT.O, config={object = DynaText({string = loc_name, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, spacing = 2, bump = true, scale = 0.4})}},
		}},
		{n=G.UIT.R, config={align = "cm"}, nodes=blind_text},
		ability_text[1] and {n=G.UIT.R, config={align = "cm", padding = 0.08, colour = mix_colours(blind_col, G.C.GREY, 0.8), r = 0.1, emboss = 0.05, minw = 2.5}, nodes=ability_text}
		or nil
	 }}
end

function UnBlind_create_UIBox_blind_tag(blind_choice) --Renders the tag that's availavle if the blind is skipped_rank	--called in main
	G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
	if not G.GAME.round_resets.blind_tags[blind_choice] then return nil end
	local _tag = Tag(G.GAME.round_resets.blind_tags[blind_choice], nil, blind_choice)
	local _tag_ui, _tag_sprite = _tag:generate_UI()
	_tag_sprite.states.collide.can = not not true
	return 
	{n=G.UIT.R, config={id = 'tag_container', ref_table = _tag, align = "cm"}, nodes={
		{n=G.UIT.R, config={id = 'tag_'..blind_choice, align = "cm", r = 0.1, padding = 0.05, can_collide = true, ref_table = _tag_sprite}, nodes={
			{n=G.UIT.C, config={id = 'tag_desc', align = "cm", minh = 0.8}, nodes={
				_tag_ui
			}},
		}}
	}}
end
