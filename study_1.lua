g = grid.connect() -- 'g' represents a connected grid

function init()
  grid_dirty = false -- script initializes with no LEDs drawn

  momentary = {} -- meta-table to track the state of all the grid keys
  for x = 1,16 do -- for each x-column (16 on a 128-sized grid)...
    momentary[x] = {} -- create a table that holds...
    for y = 1,8 do -- each y-row (8 on a 128-sized grid)!
      momentary[x][y] = false -- the state of each key is 'off'
    end
  end
  
  clock.run(grid_redraw_clock) -- start the grid redraw clock
end

function grid_redraw_clock() -- our grid redraw clock
  while true do -- while it's running...
    clock.sleep(1/30) -- refresh at 30fps.
    if grid_dirty then -- if a redraw is needed...
      grid_redraw() -- redraw...
      grid_dirty = false -- then redraw is no longer needed.
    end
  end
end

function grid_redraw() -- how we redraw
  g:all(0) -- turn off all the LEDs
  for x = 1,16 do -- for each column...
    for y = 1,8 do -- and each row...
      if momentary[x][y] then -- if the key is held...
        g:led(x,y,15) -- turn on that LED!
      end
    end
  end
  g:refresh() -- refresh the hardware to display the LED state
end

function g.key(x,y,z)  -- define what happens if a grid key is pressed or released
  -- this is cool:
  momentary[x][y] = z == 1 and true or false -- if a grid key is pressed, flip it's table entry to 'on'
  -- what ^that^ did was use an inline condition to assign our momentary state.
  -- same thing as: if z == 1 then momentary[x][y] = true else momentary[x][y] = false end
  grid_dirty = true -- flag for redraw
end