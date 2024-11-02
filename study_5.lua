-- range
-- with the second "try this" added
-- see `long_press` below

g = grid.connect()

function init()
  grid_dirty = true
  range = {}
  counter = {}
  for i = 1,8 do
    range[i] = {x1 = 1, x2 = 1, held = 0} -- equivalent to range[i]["x1"], range[i]["x2"], range[i]["held"]
  end
  clock.run(grid_redraw_clock)
end

function grid_redraw_clock()
  while true do
    clock.sleep(1/30)
    if grid_dirty then
      grid_redraw()
      grid_dirty = false
    end
  end
end

function grid_redraw()
  g:all(0)
  for y = 1,8 do
    for x = range[y].x1, range[y].x2 do
      g:led(x,y,15)
    end
  end
  g:refresh()
end

function long_press(x,y)
  clock.sleep(0.5)
  range[y].x1 = x
  range[y].x2 = x
  grid_dirty = true
end

function g.key(x,y,z)
  if z == 1 then
    range[y].held = range[y].held + 1 -- tracks how many keys are down
    local difference = range[y].x2 - range[y].x1
    local original = {x1 = range[y].x1, x2 = range[y].x2} -- keep track of the original positions, in case we need to restore them
    if range[y].held == 1 then -- if there's one key down...
      range[y].x1 = x
      range[y].x2 = x
      if difference > 0 then -- and if there's a range...
        if x + difference <= 16 then -- and if the new start point can accommodate the range...
          counter[x] = clock.run(long_press, x, y)
          range[y].x2 = x + difference -- set the range's start point to the selectedc key.
        else -- otherwise, if there isn't enough room to move the range...
          -- restore the original positions.
          range[y].x1 = original.x1
          range[y].x2 = original.x2
        end
      end
    elseif range[y].held == 2 then -- if there's two keys down...
      range[y].x2 = x -- set an range endpoint.
    end
    if range[y].x2 < range[y].x1 then -- if our second press is before our first...
      range[y].x2 = range[y].x1 -- destroy the range.
    end
  elseif z == 0 then -- if a key is released...
    if counter[x] then
      clock.cancel(counter[x])
    end
    range[y].held = range[y].held - 1 -- reduce the held count by 1.
  end
  grid_dirty = true
end