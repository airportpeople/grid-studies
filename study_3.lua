-- state machine
-- this is super similar to the last one
-- uses the same concepts, with an added
-- boolean `alt` state. a bit wonky tho.

g = grid.connect()

function init()
  grid_dirty = true

  toggled = {} -- meta-table to track the toggled state of each grid key
  alt = {} -- meta-table to track the alt state of each grid key
  counter = {}

  for x = 1,16 do -- 16 cols
    toggled[x] = {}
    alt[x] = {}
    counter[x] = {}
    for y = 1,8 do -- 8 rows
      toggled[x][y] = false
      alt[x][y] = false
      -- counters don't need futher initialization because they start as nil
    end
  end

  clock.run(grid_redraw_clock)
end

function g.key(x,y,z)
  if z == 1 then -- if a key is pressed...
    counter[x][y] = clock.run(long_press,x,y) -- start counting toward a long press.
  elseif z == 0 then -- if a key is released...
    if counter[x][y] then -- if the long press counter is still active...
      clock.cancel(counter[x][y]) -- kill the long press counter,
      short_press(x,y) -- because it's a short press.
    else -- if there was a long press...
      long_release(x,y) -- release the long press.
    end
  end
end

function long_press(x,y)
  clock.sleep(0.25) -- 0.25 second press = long press
  alt[x][y] = true
  counter[x][y] = nil -- set this to nil so key-up doesn't trigger a short press
  grid_dirty = true
end

function long_release(x,y)
  alt[x][y] = false
  grid_dirty = true
end

function short_press(x,y)
  toggled[x][y] = not toggled[x][y]
  grid_dirty = true
end

function grid_redraw()
  g:all(0)
  for x=1,16 do
    for y=1,8 do
      if toggled[x][y] and not alt[x][y] then
        g:led(x,y,15)
      elseif alt[x][y] then
        g:led(x,y,toggled[x][y] == true and 0 or 15)
      end
    end
  end
  g:refresh()
end

function grid_redraw_clock()
  while true do
    if grid_dirty then
      grid_redraw()
      grid_dirty = false
    end
    clock.sleep(1/30)
  end
end