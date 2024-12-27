local entity_types = {
  "accumulator",
  "ammo-turret",
  "arithmetic-combinator",
  "artillery-turret",
  "artillery-wagon",
  "assembling-machine",
  "beacon",
  --"boiler",
  "cargo-wagon",
  "combat-robot",
  "constant-combinator",
  "construction-robot",
  "container",
  "corpse",
  "decider-combinator",
  "electric-energy-interface",
  "electric-turret",
  "fluid-turret",
  "fluid-wagon",
  "furnace",
  "gate",
  "generator",
  "heat-interface",
  "heat-pipe",
  "inserter",
  "lab",
  "lamp",
  "land-mine",
  "linked-belt",
  "linked-container",
  "loader-1x1",
  "loader",
  "locomotive",
  "logistic-robot",
  "market",
  "mining-drill",
  "offshore-pump",
  "programmable-speaker",
  "pump",
  "reactor",
  "roboport",
  "rocket-silo",
  "simple-entity-with-force",
  "simple-entity-with-owner",
  "simple-entity",
  "solar-panel",
  "spider-vehicle",
  "splitter",
  "technology",
  "train-stop",
  "transport-belt",
  "tree",
  "tree",
  "turret",
  "underground-belt",
  "unit-spawner",
  "unit",
  ---@ pictures
  --"electric-pole",
  "fish",
  "pipe-to-ground",
	"pipe",
  "radar",
  "wall",
  "logistic-container",
  "storage-tank",
  --@ animations
  "car",
  --"rail-signal",
  --"rail-chain-signal",
  "burner-generator",

  "straight-rail",
  "legacy-straight-rail",
  "legacy-curved-rail",
  "curved-rail-a",
  "curved-rail-b",
  "half-diagonal-rail",
  "rail-ramp",
  "rail-support",
  "elevated-straight-rail",
  "elevated-curved-rail-a",
  "elevated-curved-rail-b",
  "elevated-half-diagonal-rail",
}

---@param entity LuaEntityPrototype
local function reset_icon(entity)
  if not entity.icon then return end
  entity.icon = "__core__/graphics/empty.png"
  entity.icon_size = 1
  entity.icon_mipmaps = 1
end

local function reset_optional_properties(entity)
  --entity.open_sound = nil
  --entity.close_sound = nil
  entity.working_sound = nil
  entity.vehicle_impact_sound = nil
  entity.rotated_sound = nil
  entity.mining_sound = nil
  entity.mined_sound = nil
  entity.build_sound = nil  
  entity.water_reflection = nil
end

local exceptions_by_name = {
  ["tl-empty-smoke"] = true
}

local function ANIMATION()
  return {
    filename = "__core__/graphics/empty.png",
    size = 1,
    direction_count = 1,
  } 
end

---@param t any
local function is_table(t)
  return type(t) == 'table'
end

local function reset_sprite(sprite)
  local temp = table.deepcopy(sprite)
  for idx, _ in pairs(sprite) do
    sprite[idx] = nil -- void all fields
  end

  -- set to empty 1x1 sprite
  sprite.filename = "__core__/graphics/empty.png"
  sprite.size = 1

  if temp.direction_count then sprite.direction_count = 1 end

  if temp.direction_count and temp.direction_count > 1 then
    sprite.frame_sequence = {} -- the game should not load other frames in this case
    local num_frames = temp.frame_count or 1
    for _ = 1, num_frames do
      table.insert(sprite.frame_sequence, 1)
    end
    return
  end

  if temp.frame_count or temp.repeat_count then
      sprite.frame_count = 1
      sprite.repeat_count = 1
      sprite.run_mode = nil
      if temp.frame_sequence then
          sprite.frame_sequence = { 1 } -- the game should not load other frames in this case
      end
      if temp.stripes then
          sprite.stripes = {temp.stripes[1]}
          sprite.stripes[1].width_in_frames = 1
          sprite.stripes[1].height_in_frames = 1
      else
          sprite.line_length = 1
      end
  end
end

local function reset_animation(animation)
  if animation.layers then
    for _, layer in pairs(animation.layers) do
      reset_animation(layer)
    end
  else
    reset_sprite(animation)
  end
end

local function reset_animations(animations)
  if animations.animations then reset_animations(animations.animations) end
  if animations.animation then reset_animations(animations.animation) end
  if animations.fluid_animation then reset_animations(animations.fluid_animation) end
  if animations.north then reset_animation(animations.north) end
  if animations.south then reset_animation(animations.south) end
  if animations.east then reset_animation(animations.east) end
  if animations.west then reset_animation(animations.west) end

  if is_table(animations) and #animations > 0 and animations[1].frame_count then
    for _, animation in pairs(animations) do
      reset_animation(animation)
    end
  end

  if animations.frame_count then reset_animation(animations) end
  if animations.layers then reset_animation(animations) end
end

local function is_exception(e) return exceptions_by_name[e.name] end

local function make_inserter_hand_transparent(e)
  local function nothing()
    return {
      filename = "__core__/graphics/empty.png",
      width = 1,
      height = 1
    }
  end
  e.hand_base_picture = nothing()
  e.hand_closed_picture = nothing()
  e.hand_open_picture = nothing()
  e.hand_base_shadow = nothing()
  e.hand_closed_shadow = nothing()
  e.hand_open_shadow = nothing()
  e.draw_held_item = false
end

local function reset_animation_of_thing(e)
  if is_exception(e) then return end
  e.working_visualisations = nil
  if e.type == "inserter" then make_inserter_hand_transparent(e) end
  if e.type == "animation" then reset_animations(e) end
  if e.light_animation then reset_animations(e.light_animation) end
  if e.turret_animation then reset_animations(e.turret_animation) end
  if e.structure then reset_animations(e.structure) end
  if e.fire then reset_animations(e.fire) end
  if e.fire_glow then reset_animations(e.fire_glow) end
  if e.idle_animation then reset_animations(e.idle_animation) end
  if e.idle_animations then reset_animations(e.idle_animations) end
  if e.animations then reset_animations(e.animations) end
  if e.picture then reset_animations(e.picture) end
  if e.pictures then reset_animations(e.pictures) end
  if e.smoke_pictures then reset_animations(e.smoke_pictures) end
  if e.animation then reset_animations(e.animation) end
  if e.fluid_animation then reset_animations(e.fluid_animation) end
  if e.base_animation then reset_animations(e.base_animation) end
  if e.horizontal_animation then reset_animations(e.horizontal_animation) end
  if e.vertical_animation then reset_animations(e.vertical_animation) end
  if e.charge_animation then reset_animations(e.charge_animation) end
  if e.discharge_animation then reset_animations(e.discharge_animation) end
  if e.satellite_animation then reset_animations(e.satellite_animation) end
  if e.glow_animation then reset_animations(e.glow_animation) end
  if e.run_animation then reset_animations(e.run_animation) end
  if e.folded_animation then reset_animations(e.folded_animation) end
  if e.attacking_animation then reset_animations(e.attacking_animation) end
  if e.attack_parameters and e.attack_parameters.animation then reset_animations(e.attack_parameters.animation) end
  if e.ending_attack_animation then reset_animations(e.ending_attack_animation) end
  if e.energy_glow_animation then reset_animations(e.energy_glow_animation) end
  if e.base_picture then reset_animations(e.base_picture) end
  if e.folding_animation then reset_animations(e.folding_animation) end
  if e.prepared_alternative_animation then reset_animations(e.prepared_alternative_animation) end
  if e.prepared_animation then reset_animations(e.prepared_animation) end
  if e.preparing_animation then reset_animations(e.preparing_animation) end
  if e.starting_attack_animation then reset_animations(e.starting_attack_animation) end
  if e.animation_overlay then reset_animations(e.animation_overlay) end
  if e.graphics_set then reset_animation_of_thing(e.graphics_set) end
  if e.wet_mining_graphics_set then reset_animation_of_thing(e.wet_mining_graphics_set) end
  -- LE
  if e.alternative_attacking_frame_sequence then e.alternative_attacking_frame_sequence = nil end
  if e.run_animation then e.run_animation = ANIMATION() end
  if e.animation then e.animation = ANIMATION() end
  if e.direction_shuffle then e.direction_shuffle = nil end
  if e.animation_overlay then e.animation_overlay = ANIMATION() end
  if e.door_animation_down then e.door_animation_down = ANIMATION() end
  if e.door_animation_up then e.door_animation_up = ANIMATION() end
  if e.recharging_animation then e.recharging_animation = ANIMATION() end
  if e.base_patch then reset_animations(e.base_patch) end
  if e.base then reset_animations(e.base) end
  if e.light_animation then e.light_animation = ANIMATION() end
  if e.integration then e.integration = nil end
  if e.animations then e.animations = ANIMATION() end
  if e.off_animation then e.off_animation = ANIMATION() end
  if e.on_animation then e.on_animation = ANIMATION() end
  --if e.picture then e.picture = ANIMATION() end
  --if e.pictures then e.pictures = ANIMATION() end
end

for ___, type in pairs(entity_types) do
  if (data.raw[type]) == nil then
    log("Error: type " .. type .. " not found.")
  else
    for ___, entity in pairs(data.raw[type]) do
      reset_icon(entity)
      reset_animation_of_thing(entity)
      reset_optional_properties(entity)
    end
  end
end
